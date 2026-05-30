# Dotfiles

Personal dotfiles and CLI config.
Mostly cross-platform but geared for macOS.

## Install

```sh
git clone --recurse-submodules <repo-url> ~/.config/dotfiles
cd ~/.config/dotfiles
./install.sh
```

If you cloned without submodules:

```sh
git submodule update --init --recursive
```

## What's Here

- `zsh/` - Zsh and Prezto setup
- `ghostty/` - Ghostty terminal config
- `karabiner/` - Karabiner-Elements config
- `zellij/` - Zellij config and layouts
- `opencode/` - opencode config and plugins
- `bin/` - helper scripts
