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

# Source a tool's init output from cache instead of spawning it every shell.
# Keyed on the resolved binary path, since Homebrew upgrades change the Cellar
# path but keep the bottle's old mtime.
cached_eval() {
  local name=$1; shift
  local bin=${commands[$1]:-$1}
  [[ -x $bin ]] || return 1
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh stamp="# ${bin:A} $*" line out
  [[ -s $cache ]] && read -r line < $cache
  if [[ $line == $stamp && ! $bin -nt $cache ]]; then
    source $cache
    return
  fi
  # Empty output would poison the cache (brew shellenv prints nothing when
  # PATH already starts with its dirs).
  out=$("$@") && [[ -n $out ]] || return 1
  mkdir -p ${cache:h} 2>/dev/null
  { print -r -- "$stamp"$'\n'"$out" >| $cache.$$ && mv -f $cache.$$ $cache } 2>/dev/null \
    || rm -f $cache.$$
  eval "$out"
}
