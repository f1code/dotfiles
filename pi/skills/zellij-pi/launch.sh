#!/usr/bin/env bash
# Launch a new pi instance in a Zellij floating pane
# Usage: launch.sh <pane-name> <working-directory> "<prompt>" [pi-flags...]
# Extra args after the prompt are passed as flags to pi (e.g. --thinking high)
set -euo pipefail

PANE_NAME="${1:?Usage: launch.sh <pane-name> <cwd> <prompt> [pi-flags...]}"
CWD="${2:?}"
PROMPT="${3:?}"
shift 3
PI_FLAGS=("$@")

if [ -z "${ZELLIJ:-}" ]; then
  echo "ERROR: Not inside a Zellij session" >&2
  exit 1
fi

zellij run \
  --name "$PANE_NAME" \
  --floating \
  --cwd "$CWD" \
  -- pi "${PI_FLAGS[@]}" "$PROMPT"

echo "Launched pi in floating pane '$PANE_NAME'"
