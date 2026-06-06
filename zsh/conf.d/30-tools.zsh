# FNM (replaces nvm, install with brew)
if [ -d ~/.local/share/fnm ]; then
  export FNM_PATH=~/.local/share/fnm
  export PATH=$PATH:$FNM_PATH
fi
eval "$(fnm env --use-on-cd --log-level quiet)"

# Rust
[ -f ~/.cargo/env ] && . ~/.cargo/env

# Zoxide (smarter cd).  Use "cdi" for interactive jump
eval "$(zoxide init zsh --cmd cd)"

# SCM Puff [https://github.com/mroth/scmpuff]
eval "$(scmpuff init -s --aliases=false)"
alias gs="scmpuff_status"
