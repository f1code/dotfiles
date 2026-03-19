#!/usr/bin/env bash
# Launch a new pi instance in a Zellij floating pane
# Usage: launch.sh <pane-name> <working-directory> <prompt>
set -euo pipefail

PANE_NAME="${1:?Usage: launch.sh <pane-name> <cwd> <prompt>}"
CWD="${2:?}"
PROMPT="${3:?}"

if [ -z "${ZELLIJ:-}" ]; then
  echo "ERROR: Not inside a Zellij session" >&2
  exit 1
fi

zellij run \
  --name "$PANE_NAME" \
  --floating \
  --cwd "$CWD" \
  -- pi "$PROMPT"

echo "Launched pi in floating pane '$PANE_NAME'"
