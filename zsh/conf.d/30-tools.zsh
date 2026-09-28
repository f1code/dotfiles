# Non-PATH tool setup. Runs after 10-prezto.zsh so it can override
# aliases prezto sets up (e.g. gs). PATH-mutating tools (brew, fnm) live
# in 00-path-setup.zsh instead, since they must run before instant-prompt.

# Zoxide (smarter cd). Use "cdi" for interactive jump
cached_eval zoxide zoxide init zsh --cmd cd

# SCM Puff [https://github.com/mroth/scmpuff]
cached_eval scmpuff scmpuff init -s --aliases=false
alias gs="scmpuff_status"

cached_eval wt wt config shell init zsh
emulate zsh -c 'cached_eval direnv direnv hook zsh'

# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
