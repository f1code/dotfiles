#!/usr/bin/env bash
# rewrite-author.sh — rewrite author and committer name+email on commits
#                     that match a specific old email, leaving others untouched.
#
# Usage:
#   ./rewrite-author.sh "old@email.com" ["New Name" "new@email.com"]
#
# New name/email default to the current repo's git config values.
#
# WARNING: this rewrites history. Force-push will be required afterwards:
#   git push --force-with-lease origin <branch>

set -euo pipefail

OLD_EMAIL="${1:-}"
NEW_NAME="${2:-$(git config user.name)}"
NEW_EMAIL="${3:-$(git config user.email)}"

if [[ -z "$OLD_EMAIL" || -z "$NEW_NAME" || -z "$NEW_EMAIL" ]]; then
  echo "Usage: $0 \"old@email.com\" [\"New Name\" \"new@email.com\"]"
  echo "       New name/email default to git config user.name / user.email"
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Count matching commits for a helpful summary
MATCH_COUNT=$(git log --format='%ae' | grep -cF "$OLD_EMAIL" || true)

echo "Branch:  $CURRENT_BRANCH"
echo "Matching email: $OLD_EMAIL ($MATCH_COUNT commits)"
echo "Rewrite to:     $NEW_NAME <$NEW_EMAIL>"
echo "All other commits will be left untouched."
echo ""
read -r -p "Proceed? [y/N] " confirm
if [[ "${confirm,,}" != "y" ]]; then
  echo "Aborted."
  exit 0
fi

git filter-branch --env-filter "
  if [ \"\$GIT_AUTHOR_EMAIL\" = \"$OLD_EMAIL\" ]; then
    export GIT_AUTHOR_NAME=\"$NEW_NAME\"
    export GIT_AUTHOR_EMAIL=\"$NEW_EMAIL\"
  fi
  if [ \"\$GIT_COMMITTER_EMAIL\" = \"$OLD_EMAIL\" ]; then
    export GIT_COMMITTER_NAME=\"$NEW_NAME\"
    export GIT_COMMITTER_EMAIL=\"$NEW_EMAIL\"
  fi
" --tag-name-filter cat -- HEAD

echo ""
echo "Done. To publish the rewritten history:"
echo "  git push --force-with-lease origin <branch>"
