# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Third Party extensions {{{

# Source Prezto.
# Not really using much of it right now - mostly the git aliases and some of the completion setup
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  zstyle ':prezto:module:editor' key-bindings 'emacs'
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# FZF extensions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Z
# [ -f "${ZDOTDIR}/z.sh" ] && source "${ZDOTDIR}/z.sh"

export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PATH:$PYENV_ROOT/bin"
eval "$(pyenv init --path)"

export PATH="$HOME/.poetry/bin:$PATH"

# }}}


# Environment Variables {{{
##################################################

[[ -f "$ZDOTDIR/env.local" ]] && . $ZDOTDIR/env.local

# Set path here, not in .zshenv, because it would get overwritten by 
# /etc/profile
export PATH="$PATH:$HOME/bin:$HOME/.npm/bin:$HOME/.local/bin" 
[[ "$TERM" = "xterm" ]] && export TERM=xterm-256color
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"

# }}}

# Shell Options {{{
##################################################

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# report status of background jobs
setopt notify

zstyle :compinstall filename '/home/nico/.zshrc'

# Globbing
setopt extended_glob

# Colors
autoload -U colors && colors

# Completion
fpath=($ZDOTDIR/salesforce-cli-zsh-completion $fpath)
autoload -Uz compinit && compinit
# use menus for completion
zstyle ':completion:*' menu select
# let's use the tag name as group name
zstyle ':completion:*' group-name ''
setopt completealiases

# ZMV command and corresponding alias (use it to move multiple files)
autoload -U zmv
alias mmv='noglob zmv -W'

# History
# append history (so history from multiple sessions is preserved) but ignore duplicates
setopt appendhistory hist_ignore_all_dups 
# don't want to share history between sessions (this is set by default by prezto)
unsetopt share_history
# show only past commands beginning with the current input
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward

# Use Emacs key bindings (tried VI but ended up being too much trouble)
bindkey -e
# }}}

# Aliases {{{
##################################################

alias netctl='sudo netctl'
# Commented those out since they are in prezto already
# alias l='ls -CF'
# alias la='ls -A'
# alias ll='ls -alF'
# alias ls='ls --color=auto'
#
# alias df='df -h'
# alias du='du -h'
# which nvim >/dev/null && alias vi=nvim
alias pacmanro='sudo pacman -Rs `pacman -Qtdq`'
# having some issues with vim + xterm, it puts some garabage in the screen
# So I switched to neovim for the time being, though it seems to have some issues with the clipboard at times... ugh
alias vi=nvim
# Don't need that one anymore since I actually use xterm now... hah
#alias ssh="TERM=xterm ssh"
# These are defined by prezto:
alias pu=pushd
alias po=popd
alias d="dirs -v"
if [[ -n "$MAMPROOT" ]]; then
    alias php=/Applications/MAMP/bin/php/php7.0.10/bin/php
fi
# There are also useful aliases like 1, 2, 3

# Git aliases
# Git branch gone delete
alias gbgd="git fetch --all --prune && git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs git branch -d"
# Git branch gone delete, even if not merged
alias gbgD="git fetch --all --prune && git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs git branch -D"
alias gcv="git commit --no-verify"

# locally installed node packages
alias lbower="./node_modules/.bin/bower"
alias lgulp="./node_modules/.bin/gulp"
alias lgrunt="./node_modules/.bin/grunt"

# Remove interactive aliases
unalias rm
unalias mv
unalias ln

# Global aliases
alias -g G="|grep"
alias -g L="|less"
alias -g NUL="> /dev/null 2>&1"
alias -g BR='$(git branch --show-current)'
alias -g BR:M='$(git branch --show-current):master'

# Directory aliases

hash -d pg-timesheet=~/Projects/RSD/pg-timesheet/glue-full-timer-timesheet-app
hash -d ef-theme=~/www/ef/web/B0nfir3-content/themes/electric_factory_theme
hash -d arc-theme=/var/lib/www/arcapital/web/wp-content/themes/arccapital
hash -d go-nico=~/Projects/go/src/github.com/nicocrm

# }}}

# vim: fdm=marker

# To customize prompt, run `p10k configure` or edit ~/.dotfiles/zsh/.p10k.zsh.
[[ ! -f ~/.dotfiles/zsh/.p10k.zsh ]] || source ~/.dotfiles/zsh/.p10k.zsh
