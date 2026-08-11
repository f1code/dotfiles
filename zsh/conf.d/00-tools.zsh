# Tool setup — must run before 01-instant-prompt.zsh's eager `direnv
# export`, which snapshots PATH as direnv's restore baseline. If PATH-
# mutating tools (brew, fnm) haven't run yet, direnv unload wipes their
# PATH additions. Keep this file silent: it runs during p10k's
# instant-prompt window, so any stdout/stderr trips p10k's console-output
# warning.

# Homebrew
if (( ${+commands[brew]} )); then
  eval "$(brew shellenv)"
else
  test -d /home/linuxbrew/.linuxbrew && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# FNM (replaces nvm, install with brew)
if [ -d ~/.local/share/fnm ]; then
  export FNM_PATH=~/.local/share/fnm
  export PATH=$PATH:$FNM_PATH
fi
cleanup_fnm() {
  if [[ -n "$FNM_MULTISHELL_PATH" && -d "$FNM_MULTISHELL_PATH" ]]; then
    rm -rf "$FNM_MULTISHELL_PATH"
  fi
}
trap cleanup_fnm EXIT
eval "$(fnm env --use-on-cd --log-level quiet)"

# Rust
[ -f ~/.cargo/env ] && . ~/.cargo/env

# Zoxide (smarter cd). Use "cdi" for interactive jump
eval "$(zoxide init zsh --cmd cd)"

# SCM Puff [https://github.com/mroth/scmpuff]
eval "$(scmpuff init -s --aliases=false)"
alias gs="scmpuff_status"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
