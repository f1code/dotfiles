#
# Login shell only. Environment variables that must be set once per session.
# Runs before .zshrc. New panes in Zellij/tmux inherit this—no duplicates.
#

#
# Paths
#

path=(
  # local bin
  $HOME/.local/bin
  $path
  # dart pub binaries
  $HOME/.pub-cache/bin
  # Go shared installation
  /usr/local/go/bin
  # User Go bin directory
  $HOME/go/bin
  # unversioned python commands
  /opt/homebrew/opt/python@3/libexec/bin
  # opencode
  $HOME/.opencode/bin
)

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
