umask 002

################################################
# Environment: {

export PATH="$PATH:$HOME/bin" 

# Base16 Shell
# BASE16_SHELL="$HOME/.config-perso/base16-shell/base16-default.dark.sh"
# [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Make a prompt: Date, User@Host, Last command exit code, Git branch
#                Current directory, $ sign
# Remember escape sequences have to be wrapped in \[ and \] so readline can
# correctly calculate the prompt length
export PS1='\n\[\e[0;33m\][\d \t] \[\e[1;32m\]\u@\h \[\e[1;35m\][${PIPESTATUS[@]}]\[\e[0;32m\]$(__git_ps1)\n\[\e[1;34m\]\w \$\[\e[m\] '

export EDITOR=vim

# }
################################################
