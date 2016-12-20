# Third Party extensions {{{

# Source Prezto.
# Not really using much of it right now - mostly the git aliases and some of the completion setup
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  zstyle ':prezto:module:editor' key-bindings 'emacs'
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# FZF extensions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# }}}

# RBEnv - loaded by prezto


# Environment Variables {{{
##################################################

# Prompt parts, allow populating the prompt from the subsections
right_prompt_parts=()
left_prompt_parts=()
top_prompt_parts=()
[[ -f "$ZDOTDIR/env.local" ]] && . $ZDOTDIR/env.local

export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
export GOPATH=$HOME/Projects/go
# Set path here, not in .zshenv, because it would get overwritten by 
# /etc/profile
export PATH="$PATH:$HOME/bin:$HOME/.meteor:$HOME/.npm/bin:$GOROOT/bin" 
[[ -n "$MAMPROOT" ]] && export PATH="$PATH:$MAMPROOT/Library/bin"
[[ "$TERM" = "xterm" ]] && export TERM=xterm-256color
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
export GOPATH=$HOME/Projects/go
export PATH="$PATH:$HOME/bin:$HOME/.meteor:$HOME/.npm/bin:$GOPATH/bin:$HOME/.gem/ruby/2.3.0/bin:$HOME/.config/composer/vendor/bin" 

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

# Git {{{
##################################################

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
# check-for-changes enables the %u format, to show unstaged changes
zstyle ':vcs_info:*' check-for-changes true
fmt_git_unstaged="%{${fg[red]}%}%u"
zstyle ':vcs_info:git*' formats "%{${fg[green]}%}(%{${fg[green]}%}%b ${fmt_git_unstaged}%{${fg[green]}%})%{$reset_color%}"
precmd() {
    # running this in a pre-command will populate the vcs info message
    # variable that we will then use in the prompt
    vcs_info
}
right_prompt_parts[2]=$'${vcs_info_msg_0_}'

# }}}

# Prompt {{{
##################################################

# date / time
top_prompt_parts+=("%{$fg[yellow]%}[%D{%a %b %d %T}]")
# user / host
top_prompt_parts+=("%{$fg_bold[green]%}<%n@%m>")
# last command status
top_prompt_parts+=("%{$fg_bold[magenta]%}[%?]")
# git
top_prompt_parts+=''
# newline
top_prompt_parts+="%{$reset_color%}"$'\n'

# directory and %
left_prompt_parts=("%{$fg_bold[blue]%}%~" "%#" "%{$reset_color%}")

function set-rps1-from-parts {
    RPS1="${(j::)right_prompt_parts}"
}

function set-ps1-from-parts {
 #   PS1="${(j: :)left_prompt_parts}%{$reset_color%}"
    PS1=$'\n'"${(j: :)top_prompt_parts}${(j: :)left_prompt_parts}%{$reset_color%}"
}

setopt prompt_subst
set-rps1-from-parts
set-ps1-from-parts

# }}}

# Aliases {{{
##################################################

# Commented those out since they are in prezto already
# alias l='ls -CF'
# alias la='ls -A'
# alias ll='ls -alF'
# alias ls='ls --color=auto'
#
# alias df='df -h'
# alias du='du -h'
which nvim >/dev/null && alias vi=nvim
alias pacmanro='sudo pacman -Rs `pacman -Qtdq`'
# having some issues with vim + xterm, it puts some garabage in the screen
# So I switched to neovim for the time being, though it seems to have some issues with the clipboard at times... ugh
#alias vi=vim
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

# Directory aliases

hash -d pg-timesheet=~/Projects/RSD/pg-timesheet/glue-full-timer-timesheet-app
hash -d ef-theme=~/www/ef/web/B0nfir3-content/themes/electric_factory_theme
hash -d arc-theme=~/www/arcapital/web/wp-content/themes/arccapital
hash -d go-nico=~/Projects/go/src/github.com/nicocrm

# }}}

~/bin/qotd.sh

# vim: fdm=marker
