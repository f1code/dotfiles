# herdr

`config.toml` symlinked from `~/.config/herdr/config.toml`.

## Direct keys

`ctrl+alt` chords skip the prefix. Kitty binds no `ctrl+alt` keys; its `kitty_mod` is `alt+shift`, so avoid that family.

| Key | Action |
|---|---|
| `ctrl+alt+]` / `ctrl+alt+[` | next / previous pane |
| `ctrl+alt+w` | close pane |
| `ctrl+alt+o` | last workspace (plugin) |

## Plugin: last-workspace

`plugins/last-workspace/` toggles between the two most recently focused workspaces. Herdr has no built-in "last workspace" action; `previous_workspace` follows sidebar order.

- `workspace.focused` hook records `<current> <previous>` ids in `~/.local/state/herdr/plugins/local.last-workspace/<session>`.
- `toggle` action focuses the previous id. No-op if none; fails with `workspace_not_found` if it was closed.

Link once per machine:

```sh
herdr plugin link ~/.config/dotfiles/herdr/plugins/last-workspace
herdr server reload-config
```

Debug:

```sh
herdr plugin log list --plugin local.last-workspace
```

## Gotchas

- Rectangle (alternate defaults) takes `ctrl+opt` + arrows, Enter, Backspace, C D E F G T U I J K, `=`, `-`, plus custom B and N.
- Karabiner remaps `§` to `` ` `` only bare, with Option, or with Shift. `ctrl+alt+backtick` never reached herdr.
- `kitten show-key -m kitty` shows what kitty sends. `kitten @ send-key --match id:<win> ctrl+alt+o` sends a key to the herdr window for testing.
