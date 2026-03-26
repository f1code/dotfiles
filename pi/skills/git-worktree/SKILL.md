---
name: git-worktree
description: Create a git worktree for a specified branch. Fuzzy-matches the branch name against existing branches, confirms with the user if multiple matches, then checks out the worktree.
---

# Git Worktree

Creates a git worktree under `<worktree root>/<branch-slug>` for a given branch.

## Workflow

1. **Determine the worktree root**.
   **READ the local project instructions to find if there is a different convention for the worktree root.**
   If the project specifies an absolute path, use it as-is.
   Otherwise, default to `../<project>.worktrees` (relative to the repo root).

2. **List all branches** and fuzzy-match the user's input:
   ```bash
   git branch -a --format='%(refname:short)'
   ```
   Filter the list to branches whose name contains the user's search term (case-insensitive substring match). **Prioritize local branches** — show them first and prefer them over remote equivalents. Strip `origin/` prefixes for display but track which are remote-only.

3. **If multiple matches**, prompt the user using the `question` tool to pick one. **If exactly one match, proceed without prompting.** If no matches, tell the user.

4. **Determine the worktree directory name**: take the branch name (without `origin/`), replace `/` with `_` to form a directory-safe slug. The worktree path is `<worktree root>/<slug>`.

5. **Create the worktree**:
   ```bash
   mkdir -p <worktree root>
   git worktree add <worktree root>/<slug> <branch>
   ```
   - If the branch is remote-only (e.g. `origin/feature/foo`), use the short name without `origin/` so git creates a local tracking branch automatically:
     ```bash
     git worktree add <worktree root>/<slug> <branch-without-origin>
     ```

6. **Report success** with the worktree path so the user can `cd` into it.

## Notes

- If the worktree directory already exists, inform the user and do not overwrite.
- If the user's search term matches exactly one branch, skip confirmation and proceed directly.
