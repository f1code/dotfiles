# Load local environment / secrets (not committed)
# Create ~/.zshrc.local on each machine for machine-specific settings
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local
#
# write profiling (first enable in 00-path-setup.zsh)
# zprof
