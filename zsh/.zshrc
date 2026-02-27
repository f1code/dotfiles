# For profiling, if needed:
# zmodload zsh/zprof
#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# Source Prezto.
if [[ -o interactive ]] && [[ -z "$CURSOR_AGENT" ]] && [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


path=(
  $path
  # dart pub binaries
  $HOME/.pub-cache/bin
  # unversioned python commands
  /opt/homebrew/opt/python@3/libexec/bin
)

# Shell Options {{{
##################################################


# }}}

# Aliases {{{
##################################################

alias vi=nvim
alias cp='nocorrect cp'
alias ln='nocorrect ln'
alias mv='nocorrect mv'
alias rm='nocorrect rm'
alias cpi="${aliases[cp]:-cp} -i"
alias lni="${aliases[ln]:-ln} -i"
alias mvi="${aliases[mv]:-mv} -i"
alias rmi="${aliases[rm]:-rm} -i"
alias rg='rg -S'
if command -v eza >/dev/null 2>&1; then 
  alias ls='eza --icons=always --hyperlink'
  alias ll='eza -l --icons=always --hyperlink'
  alias la='eza -la --icons=always --hyperlink'
fi

# Global aliases
alias -g G="|grep"
alias -g L="|less"
alias -g NUL="> /dev/null 2>&1"
alias -g BR='$(git branch --show-current)'
alias -g BR:M='$(git branch --show-current):master'

# ZMV command and corresponding alias (use it to move multiple files)
autoload -U zmv
alias mmv='noglob zmv -W'

# SCM Puff [https://github.com/mroth/scmpuff]
eval "$(scmpuff init -s --aliases=false)"
alias gs="scmpuff_status"

# Docker
alias dk='docker'
alias dkr='docker run'
alias dkR='docker run -it --rm'
alias dkps='docker ps'
alias dkpsa='docker ps -a'

# Docker Compose (c)
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

# FNM (replaces, nvm, install with brew)
eval "$(fnm env --use-on-cd --log-level quiet)"

# 4G
if [[ -d "$HOME/prancer" ]]; then
  # Customize to your needs...
  [[ -s "${HOME}/tools/k8s/aliases.sh" ]] && source "${HOME}/tools/k8s/aliases.sh"

  alias load-reports="dkce backend python manage.py initialize_reports --override=True"
  alias load-glossaries="dkce backend python manage.py initialize_prancer_glossary --override=True"
  alias shell-plus-sql="dkce backend python manage.py shell_plus --print-sql"
  wipe-db-prancer() {
    # optionally, pass the dump file to use
    # default uses dbs/develop.dmp
    readonly dumpfile=~/dbs/${1:?develop}.dmp.gz
    echo "Using dump file $dumpfile"
    unsetopt pushdignoredups
    # optionally, pass a prancer version suffix to use as directory to switch to
    # (or . to not switch directory)
    # default uses ~/prancer
    if [[ "$2" == "." ]]; then
      prancer_dir=.
    else
      prancer_dir="$HOME/prancer${2:+_$2}"
    fi
    if [ ! -f "$dumpfile" ]; then
      echo "File $dumpfile does not exist!"
      return 1
    fi
    pushd $prancer_dir
    docker compose stop backend celery celery-beat db-builder && \
      docker compose exec db psql -U prancer -d postgres -c 'drop database if exists prancer with (force)' && \
      docker compose exec db psql -U prancer -d postgres -c 'create database prancer' && \
      gunzip -c $dumpfile | docker compose exec -T db psql -U prancer -d prancer && \
      docker compose up -d && \
      docker compose logs -f db-builder
    popd
  }
fi

# }}}

. "$HOME/.local/bin/env"


# Ghostty - we don't need these on warp {{{
##################################################
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  # FZF extensions
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  autoload bashcompinit && bashcompinit
  autoload -Uz compinit && compinit
  complete -C '/opt/homebrew/bin/aws_completer' aws

  # 1. Autosuggestions
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  # Bind Ctrl+Space to accept the suggestion
  bindkey '^ ' autosuggest-accept
  # This accepts just the next word of the ghost text
  bindkey '\e ' forward-word

  # 2. Autocomplete
  # --- zsh-autocomplete tuning ---
  # Add a slight 100ms delay so the menu doesn't flash wildly while you type fast
  zstyle ':autocomplete:*' delay 0.1
  
  # Limit the dropdown menu height (the default can take up half your screen)
  zstyle ':autocomplete:*' list-lines 10

  # Let zsh-autosuggestions handle the "ghost text", keep autocomplete to the menu
  zstyle ':autocomplete:*' insert-unambiguous no
  source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

  # DISABLE THE "EXPANSION" GROUP
  # This stops zsh from making you tab through the expanded path of ~ or $VAR
  zstyle ':completion:*' completer _complete _complete:-fuzzy _correct _approximate _ignored

  # --- Keybinding fixes (Must go AFTER sourcing autocomplete) ---
  # Make Up/Down arrows search your history instead of jumping into the menu.
  # (You will use Tab and Shift-Tab to navigate the dropdown menu instead).
  bindkey '\e[A' up-line-or-history    # Up Arrow
  bindkey '\e[B' down-line-or-history  # Down Arrow

  # Force 'Enter' to always run the command you typed. 
  # (Without this, if a menu item is highlighted, Enter just inserts the word).
  bindkey '\r' accept-line
  bindkey '^M' accept-line

  # 3. Syntax highlighting - must be last
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
# }}}

# To customize prompt, run `p10k configure` or edit ~/.config/dotfiles/zsh/.p10k.zsh.
[[ ! -f ~/.config/dotfiles/zsh/.p10k.zsh ]] || source ~/.config/dotfiles/zsh/.p10k.zsh

# zprof
