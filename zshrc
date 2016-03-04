# Local Variables {{{
##################################################

# Prompt parts, allow populating the prompt from the subsections
right_prompt_parts=()
left_prompt_parts=()
top_prompt_parts=()

# }}}

# Shell Options {{{
##################################################
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# append history (so history from multiple sessions is preserved) but ignore duplicates
setopt appendhistory hist_ignore_all_dups
# report status of background jobs
setopt notify
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nico/.zshrc'

autoload -U colors && colors
autoload -Uz compinit && compinit
# End of lines added by compinstall
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

# Options for VIM mode {{{
##################################################
bindkey -v

# restore some bindings
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# map jk for escape in insert mode
bindkey -M viins 'jk' vi-cmd-mode

# add a mode indication in the prompt
function zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    right_prompt_parts[1]="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    set-rps1-from-parts 
    zle reset-prompt
}

# not really needed for line-init, and it messes up multiline prompts
#zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=20          # Reduce timeout when switching edit mode
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

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'

alias df='df -h'
alias du='du -h'

# }}}

# vim: fdm=marker
