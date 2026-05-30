#!/usr/bin/env python3
"""
git-rewrite-time — rewrite commit timestamps to avoid a configurable time window.

Usage:
    python git-rewrite-time.py --avoid-range 9-17 --user alice@example.com --max-age 5
"""

import argparse
import random
import re
import shutil
import subprocess
import sys
from datetime import datetime, timedelta, timezone


MAX_RETRIES = 10
OFFSET_HOURS = 4  # max distance from avoid-window bound (was 2h, widened to rescue tight-anchor cases)


# ---------------------------------------------------------------------------
# Argument parsing & validation
# ---------------------------------------------------------------------------

def parse_avoid_range(value: str) -> tuple[int, int]:
    """Parse 'HH-HH' or 'H-H' into (lower, upper) ints."""
    m = re.fullmatch(r"(\d{1,2})-(\d{1,2})", value)
    if not m:
        raise argparse.ArgumentTypeError(
            f"Invalid avoid-range '{value}'. Expected format: HH-HH (e.g. 9-17)"
        )
    lower, upper = int(m.group(1)), int(m.group(2))
    for h in (lower, upper):
        if not (0 <= h <= 23):
            raise argparse.ArgumentTypeError(
                f"Hour {h} out of range (0-23) in avoid-range '{value}'"
            )
    if lower >= upper:
        raise argparse.ArgumentTypeError(
            f"Avoid range must not span midnight (got {lower}-{upper}). "
            "Use two invocations if needed."
        )
    return lower, upper


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Rewrite git commit timestamps to avoid a time window."
    )
    p.add_argument(
        "--avoid-range", required=True, type=parse_avoid_range,
        metavar="HH-HH",
        help="Hour range to avoid, inclusive (24h clock, e.g. 9-17).",
    )
    p.add_argument(
        "--user", required=True,
        help="Author email whose commits will be rewritten.",
    )
    p.add_argument(
        "--max-age", required=True, type=int, metavar="MONTHS",
        help="Only consider commits from the last N months.",
    )
    p.add_argument(
        "-y", "--yes", action="store_true",
        help="Skip confirmation prompt.",
    )
    return p.parse_args()


# ---------------------------------------------------------------------------
# Git helpers
# ---------------------------------------------------------------------------

def check_git_filter_repo() -> None:
    """Exit with instructions if git-filter-repo is not available."""
    probe = subprocess.run(
        ["git", "filter-repo", "--version"],
        capture_output=True,
    )
    if probe.returncode != 0:
        sys.exit(
            "Error: git-filter-repo is not installed.\n"
            "Install it with:  pip install git-filter-repo\n"
            "            or:   brew install git-filter-repo"
        )


def git(*args: str) -> str:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"git {' '.join(args)} failed:\n{result.stderr.strip()}")
    return result.stdout.strip()


def parse_git_timestamp(ts: str) -> datetime:
    """Parse git's ISO-strict format: '2026-04-10 14:32:01 +0200'."""
    return datetime.strptime(ts, "%Y-%m-%d %H:%M:%S %z")


def format_git_timestamp(dt: datetime) -> str:
    """Format for git filter-repo fast-import: '<unix-timestamp> <tz-offset>'."""
    return f"{int(dt.timestamp())} {dt.strftime('%z')}"


def get_commits(user: str, since: datetime) -> list[dict]:
    """
    Return all commits on the current branch newer than `since`, newest-first.
    Each entry has: hash, author_email, author_date, committer_date, subject.
    """
    sep = "\x1f"
    fmt = sep.join(["%H", "%ae", "%ai", "%ci", "%s"])
    since_str = since.strftime("%Y-%m-%d %H:%M:%S")
    raw = git("log", f"--format={fmt}", f"--after={since_str}")
    if not raw:
        return []

    commits = []
    for line in raw.splitlines():
        parts = line.split(sep, 4)
        if len(parts) != 5:
            continue
        h, email, adate, cdate, subject = parts
        commits.append({
            "hash": h,
            "author_email": email,
            "author_date": parse_git_timestamp(adate),
            "committer_date": parse_git_timestamp(cdate),
            "subject": subject,
        })
    return commits


# ---------------------------------------------------------------------------
# Time-slot generation
# ---------------------------------------------------------------------------

def in_avoid_window(dt: datetime, lower: int, upper: int) -> bool:
    return lower <= dt.hour <= upper


def pick_new_author_time(
    orig_a: datetime,
    orig_c: datetime,
    lower: int,
    upper: int,
    parent_committer: datetime | None,
    child_committer: datetime | None,
    reserve_below: int = 0,
) -> datetime | None:
    """
    Compute the legal interval(s) for a new author_date directly, then sample
    uniformly from it.  Returns None if no legal interval exists.

    Constraints:
      - On the same calendar date as `orig_a`.
      - In `[lower-2h, lower)` (before) or `(upper, upper+3h]` (after) author hours.
      - When applied as a delta to `orig_c`, the resulting committer_date must
        sit strictly between `parent_committer` and `child_committer`.
      - `reserve_below` minutes are kept at the bottom of each legal interval to
        leave headroom for downstream same-segment commits not yet placed.
    """
    tz = orig_a.tzinfo
    shift = orig_c - orig_a  # added to author to produce committer
    parent_a = (parent_committer - shift) if parent_committer else None
    child_a = (child_committer - shift) if child_committer else None

    def at(h: int, m: int) -> datetime:
        return datetime(orig_a.year, orig_a.month, orig_a.day, h, m, 0, tzinfo=tz)

    intervals: list[tuple[datetime, datetime]] = []
    if lower > 0:
        intervals.append((
            at(max(lower - OFFSET_HOURS, 0), 0),
            at(lower, 0) - timedelta(minutes=1),
        ))
    if upper < 23:
        intervals.append((
            at(upper + 1, 0),
            at(min(upper + OFFSET_HOURS + 1, 23), 59),
        ))

    legal: list[tuple[datetime, datetime]] = []
    for lo, hi in intervals:
        if parent_a is not None:
            lo = max(lo, parent_a + timedelta(minutes=1))
        if child_a is not None:
            hi = min(hi, child_a - timedelta(minutes=1))
        if lo <= hi:
            legal.append((lo, hi))

    if not legal:
        return None

    weights: list[float] = []
    for lo, hi in legal:
        secs = (hi - lo).total_seconds() + 1
        # Bias toward "after" intervals when commits remain below: their
        # constraints propagate by additive committer shifts; placing the
        # current commit late preserves headroom for older commits.
        if reserve_below > 0 and lo.hour > upper:
            secs *= (1 + reserve_below)
        weights.append(secs)
    (lo, hi) = random.choices(legal, weights=weights, k=1)[0]

    # Partition the chosen interval into (reserve_below + 1) equal slots and
    # sample from the topmost slot.  The newest commit is pushed near `hi`,
    # leaving the lower slots free for downstream commits in the segment.
    n_slots = reserve_below + 1
    slot_span = (hi - lo) / n_slots
    sub_lo = lo + slot_span * reserve_below
    sub_hi = hi
    span_seconds = int((sub_hi - sub_lo).total_seconds())
    return sub_lo + timedelta(seconds=random.randint(0, max(span_seconds, 0)))


# ---------------------------------------------------------------------------
# Planning
# ---------------------------------------------------------------------------

def months_ago(n: int) -> datetime:
    return datetime.now(tz=timezone.utc) - timedelta(days=30 * n)


def build_plan(
    commits: list[dict],
    user: str,
    lower: int,
    upper: int,
) -> tuple[list[dict], list[str]]:
    """
    Walk commits newest→oldest (by committer_date, which is linear).  For `user`
    commits whose author_date falls inside the avoid window, generate a
    replacement time that respects the surrounding immovable anchors.

    An "anchor" is any commit that will NOT be rewritten:
      - a commit by another author, OR
      - a `user` commit whose author_date is already outside the avoid window.

    Other in-window `user` commits between C and its anchor do not constrain C
    (they'll be slotted into the remaining space when their turn comes).

    Returns (plan_rows, warnings).
    plan_rows: [{hash, old_author, new_author, old_committer, new_committer, subject}]
    """
    n = len(commits)

    # Pre-compute which commits will be rewritten.
    needs_rewrite = [
        c["author_email"] == user and in_avoid_window(c["author_date"], lower, upper)
        for c in commits
    ]

    # For each position i, find the next-older (j > i) anchor's committer_date.
    next_anchor_below: list[datetime | None] = [None] * n
    for i in range(n):
        for j in range(i + 1, n):
            if not needs_rewrite[j]:
                next_anchor_below[i] = commits[j]["committer_date"]
                break

    # For each rewrite commit, count how many other rewrite commits sit between
    # it and the next anchor below (i.e. in the same segment, older than it).
    same_segment_below: list[int] = [0] * n
    for i in range(n):
        if not needs_rewrite[i]:
            continue
        cnt = 0
        for j in range(i + 1, n):
            if not needs_rewrite[j]:
                break  # hit anchor; segment ends
            cnt += 1
        same_segment_below[i] = cnt

    # `effective_committer[i]` = committer_date after any rewrite at position i.
    # Updated in place as we settle commits newest→oldest.
    effective_committer = [c["committer_date"] for c in commits]

    plan_rows: list[dict] = []
    warnings: list[str] = []

    for i, commit in enumerate(commits):
        if not needs_rewrite[i]:
            continue

        # Child = next-newer commit's settled committer_date (already finalised).
        child_time = effective_committer[i - 1] if i > 0 else None
        # Parent = next-older anchor's committer_date.
        parent_time = next_anchor_below[i]

        # Compute legal interval directly and sample once — no retry loop needed.
        new_author = pick_new_author_time(
            orig_a=commit["author_date"],
            orig_c=commit["committer_date"],
            lower=lower,
            upper=upper,
            parent_committer=parent_time,
            child_committer=child_time,
            reserve_below=same_segment_below[i],
        )
        keep_committer = False

        # Fallback (option F): if we can't satisfy the committer-ordering
        # constraint, preserve the original committer_date and rewrite only the
        # author_date.  This handles rebase batches where many commits share an
        # exact committer_date (sub-second precision lost) and any author shift
        # would propagate into a sub-minute window between anchors.
        if new_author is None:
            new_author = pick_new_author_time(
                orig_a=commit["author_date"],
                orig_c=commit["committer_date"],
                lower=lower,
                upper=upper,
                parent_committer=None,
                child_committer=None,
                reserve_below=0,
            )
            keep_committer = True

        if new_author is None:
            lo = parent_time.strftime("%Y-%m-%d %H:%M") if parent_time else "start"
            hi = child_time.strftime("%Y-%m-%d %H:%M") if child_time else "end"
            warnings.append(
                f"WARNING: could not find valid slot for {commit['hash'][:7]} "
                f"(anchor window: {lo} – {hi}). Skipping."
            )
            continue

        delta = new_author - commit["author_date"]
        if keep_committer:
            new_committer = commit["committer_date"]
        else:
            new_committer = commit["committer_date"] + delta

        if new_author is None:
            lo = parent_time.strftime("%Y-%m-%d %H:%M") if parent_time else "start"
            hi = child_time.strftime("%Y-%m-%d %H:%M") if child_time else "end"
            warnings.append(
                f"WARNING: could not find valid slot for {commit['hash'][:7]} "
                f"(anchor window: {lo} – {hi}). Skipping."
            )
            continue

        effective_committer[i] = new_committer
        plan_rows.append({
            "hash": commit["hash"],
            "old_author": commit["author_date"],
            "new_author": new_author,
            "old_committer": commit["committer_date"],
            "new_committer": new_committer,
            "subject": commit["subject"],
        })

    return plan_rows, warnings


# ---------------------------------------------------------------------------
# Confirmation prompt
# ---------------------------------------------------------------------------

def print_plan(plan: list[dict], user: str, max_age: int, lower: int, upper: int) -> None:
    print(
        f"\nFound commits by {user} in the last {max_age} month(s). "
        f"{len(plan)} fall inside avoid window ({lower:02d}:00–{upper:02d}:00):\n"
    )
    for row in plan:
        old = row["old_author"].strftime("%Y-%m-%d %H:%M")
        new = row["new_author"].strftime("%Y-%m-%d %H:%M")
        print(f"  {row['hash'][:7]}  {old}  →  {new}  {row['subject'][:60]}")
    print()


def confirm() -> bool:
    ans = input("Proceed? [y/N] ").strip().lower()
    return ans == "y"


# ---------------------------------------------------------------------------
# Apply rewrites via git filter-repo
# ---------------------------------------------------------------------------

def apply_rewrites(plan: list[dict]) -> None:
    """
    Invoke git filter-repo with an inline --commit-callback that rewrites
    author/committer dates for the targeted commits in a single pass.
    """
    mapping: dict[str, tuple[str, str]] = {
        row["hash"]: (
            format_git_timestamp(row["new_author"]),
            format_git_timestamp(row["new_committer"]),
        )
        for row in plan
    }

    # Inline snippet executed by git filter-repo for every commit.
    # `commit.original_id` is the pre-rewrite SHA1 as bytes.
    inline = "\n".join([
        f"_mapping = {repr(mapping)}",
        "_h = commit.original_id.decode('ascii') if commit.original_id else None",
        "if _h and _h in _mapping:",
        "    _a, _c = _mapping[_h]",
        "    commit.author_date = _a.encode()",
        "    commit.committer_date = _c.encode()",
    ])

    result = subprocess.run(
        ["git", "filter-repo", "--force", "--commit-callback", inline],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.exit(
            f"git filter-repo failed:\n{result.stderr.strip()}\n{result.stdout.strip()}"
        )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    args = parse_args()
    lower, upper = args.avoid_range

    check_git_filter_repo()

    cutoff = months_ago(args.max_age)
    all_commits = get_commits(args.user, cutoff)

    if not all_commits:
        print(f"No commits by {args.user} found in the last {args.max_age} month(s).")
        sys.exit(0)

    plan, warnings = build_plan(all_commits, args.user, lower, upper)

    for w in warnings:
        print(w, file=sys.stderr)

    if not plan:
        print(
            f"No commits by {args.user} fall inside the avoid window "
            f"({lower:02d}:00–{upper:02d}:00). Nothing to do."
        )
        sys.exit(0)

    print_plan(plan, args.user, args.max_age, lower, upper)

    if not args.yes and not confirm():
        print("Aborted.")
        sys.exit(0)

    apply_rewrites(plan)

    print(f"\nRewritten: {len(plan)} commits")
    print(f"Skipped (no valid slot): {len(warnings)} commits")
    print('Done. Run `git log --format="%h %ai %s"` to verify.')


if __name__ == "__main__":
    main()
