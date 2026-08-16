# PATH is set in .zprofile (login shell only) to avoid duplicates in Zellij panes.

# General
alias oc=opencode
alias vi=nvim
alias zj=zellij
alias cp='nocorrect cp'
alias ln='nocorrect ln'
alias mv='nocorrect mv'
alias rm='nocorrect rm'
alias cpi="${aliases[cp]:-cp} -i"
alias lni="${aliases[ln]:-ln} -i"
alias mvi="${aliases[mv]:-mv} -i"
alias rmi="${aliases[rm]:-rm} -i"
alias rg='rg -S'
alias kssh='kitten ssh'
alias gs="scmpuff_status"

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=always --hyperlink=auto'
  alias ll='eza -l --icons=always --hyperlink=auto'
  alias la='eza -la --icons=always --hyperlink=auto'
fi

# Global aliases
alias -g G="|grep"
alias -g L="|less"
alias -g NUL="> /dev/null 2>&1"
alias -g BR='$(git branch --show-current)'
alias -g BR:M='$(git branch --show-current):master'

# ZMV (move multiple files with glob patterns)
autoload -U zmv
alias mmv='noglob zmv -W'

# Docker
alias dk='docker'
alias dkr='docker run'
alias dkR='docker run -it --rm'
alias dkps='docker ps'
alias dkpsa='docker ps -a'

# Docker Compose
alias dkc='docker compose'
alias dkcb='docker compose build'
alias dkcB='docker compose build --no-cache'
alias dkce='docker compose exec'
alias dkcl='docker compose logs'
alias dkcs='docker compose start'
alias dkcS='docker compose restart'
alias dkcu='docker compose up'
alias dkcU='docker compose up -d'
alias dkcx='docker compose stop'

# Directory aliases
hash -d dot=~/.config/dotfiles
hash -d vim=~/.config/nvim
