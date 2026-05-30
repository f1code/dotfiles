# General Rules - Projects can override

## Reviewing or giving feedback

- Be extremely concise.  Sacrifice grammar for the sake of brevity.

## Shell Commands

- When searching in bash, use `rg` instead of `grep`

## Planning

- Write the plan as a markdown file under docs/plans/, named `YYYY-MM-DD-<short-description>.md`
- Do not make any code changes (write/edit/bash) until instructed to proceed
- When a plan is implemented, move the file to the "implemented" subfolder
- Plan should include: goal, proposed changes (with file paths), and open questions
- Do not commit plans unless asked specifically

## Git

 - Do not try to use interactive rebase
 - When creating a git worktree, always load the `using-git-worktrees` skill first

## Tests

 - Never delete, skip, or disable existing tests to force them to pass. Fix the underlying code instead. Only remove tests when explicitly instructed.
