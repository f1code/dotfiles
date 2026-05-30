# FNM (replaces nvm, install with brew)
eval "$(fnm env --use-on-cd --log-level quiet)"

# Rust
[ -f ~/.cargo/env ] && . ~/.cargo/env

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# SCM Puff [https://github.com/mroth/scmpuff]
eval "$(scmpuff init -s --aliases=false)"
alias gs="scmpuff_status"
