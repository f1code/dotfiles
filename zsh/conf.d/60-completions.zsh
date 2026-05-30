# Completions and FZF - not needed in Warp (it has its own)
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && return

# Find and source a plugin from common share dirs
local -a plugin_dirs=(
  "/opt/homebrew/share"                  # macOS Homebrew
  "/opt/homebrew/opt"                    # macOS Homebrew - alternate for fzf
  "/usr/share"                           # Linux Native (Ubuntu/Debian/Arch)
  "/home/linuxbrew/.linuxbrew/share"     # Linux Homebrew
)
load_plugin() {
  local subpath=$1
  for dir in $plugin_dirs; do
    if [[ -f "$dir/$subpath" ]]; then
      source "$dir/$subpath"
      return 0
    fi
  done
  if [[ "$2" != "quiet" ]]; then
    echo "Could not load plugin $subpath!"
  fi
  return 1
}

# FZF key bindings and completions
# On Linux (APT): /usr/share/doc/fzf/examples/
# On macOS:       /opt/homebrew/opt/fzf/shell/
load_plugin "doc/fzf/examples/key-bindings.zsh" quiet || load_plugin "fzf/shell/key-bindings.zsh"
load_plugin "doc/fzf/examples/completion.zsh"   quiet || load_plugin "fzf/shell/completion.zsh"

[[ -n "$functions[bashcompinit]" ]] || \
  autoload -Uz bashcompinit && bashcompinit
[[ -f "/opt/homebrew/bin/aws_completer" ]] && \
  complete -C '/opt/homebrew/bin/aws_completer' aws
