#!/bin/sh
# State file holds "<current> <previous>" workspace ids, one per herdr session.
set -eu

state="$HERDR_PLUGIN_STATE_DIR/${HERDR_SESSION:-default}"
cur=
prev=
[ -f "$state" ] && read -r cur prev < "$state" || true

case "$1" in
record)
    new="$HERDR_WORKSPACE_ID"
    [ "$new" = "$cur" ] && exit 0
    printf '%s %s\n' "$new" "$cur" > "$state.$$"
    mv "$state.$$" "$state"
    ;;
toggle)
    [ -n "$prev" ] || exit 0
    exec "$HERDR_BIN_PATH" workspace focus "$prev" > /dev/null
    ;;
*)
    echo "usage: $0 record|toggle" >&2
    exit 2
    ;;
esac
