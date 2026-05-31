# Shared helpers for zsh config

# Find and source a plugin from common share dirs
# Note, on Linux some programs like fzf are installed from Homebrew, even
# though they are available natively, to ensure a stable path
local -a plugin_dirs=(
  "/opt/homebrew/share"                  # macOS Homebrew
  "/opt/homebrew/opt"                    # macOS Homebrew - alternate for fzf
  "/usr/share"                           # Linux Native (Ubuntu/Debian/Arch)
  "/home/linuxbrew/.linuxbrew/share"     # Linux Homebrew
  "/home/linuxbrew/.linuxbrew/opt"  # Linux Homebrew - alternate
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
