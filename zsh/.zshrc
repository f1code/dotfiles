# For profiling, if needed:
# zmodload zsh/zprof
#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# Source Prezto. {{{

# after installing something run this to redo the completions
alias rebuild-completions='rm -f ~/.cache/prezto/zcompdump ~/.cache/prezto/zcompdump.zwc; exec zsh'
if [[ -o interactive ]] && [[ -z "$CURSOR_AGENT" ]] && [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# }}}


# PATH is set in .zprofile (login shell only) to avoid duplicates in Zellij panes.
#
# Aliases {{{
##################################################

alias vi=nvim
alias z=zellij
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

  hash -d p=~/prancer
  hash -d d=~/data-hub
  alias -g BRTICK='$(git branch --show-current | tr / - | cut -d - -f 2-3)'
  alias load-reports="dkce backend python manage.py initialize_reports --override=True"
  alias load-glossaries="dkce backend python manage.py initialize_prancer_glossary --override=True"
  alias shell-plus-sql="dkce backend python manage.py shell_plus --print-sql"
  wipe-db-prancer() {
    # optionally, pass the dump file to use
    # default uses dbs/develop.dmp
    readonly dumpfile=~/prancer/dbs/${1:?develop}.dmp.gz
    echo "Using dump file $dumpfile"
    unsetopt pushdignoredups
    # optionally, pass a prancer version suffix to use as directory to switch to
    # (or . to not switch directory)
    # default uses ~/prancer
    if [[ "$2" == "." ]]; then
      prancer_dir=.
    else
      prancer_dir="$HOME/prancer/${2:-develop}"
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

# Directory aliases

hash -d dot=~/.config/dotfiles
hash -d vim=~/.config/nvim

# }}}

# Ghostty - we don't need these on warp {{{
##################################################
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
  # List potential plugin locations
  local -a plugin_dirs=(
    "/opt/homebrew/share"                  # macOS Homebrew
    "/opt/homebrew/opt"                    # macOS Homebrew - alternate for fzf
    "/usr/share"                           # Linux Native (Ubuntu/Debian/Arch)
    "/home/linuxbrew/.linuxbrew/share"     # Linux Homebrew
  )

  # Function to find and source a plugin
  load_plugin() {
    local subpath=$1
    for dir in $plugin_dirs; do
      if [[ -f "$dir/$subpath" ]]; then
        source "$dir/$subpath"
        return 0
      fi
    done
    if [[ "$2" != "quiet" ]]; then
      echo "Could not load plugin $subpath!"
    fi
    return 1
  }

  # FZF extensions
  # On Linux (APT), these are in /usr/share/doc/fzf/examples/
  # On macOS, these are in /opt/homebrew/opt/fzf/shell/
  load_plugin "doc/fzf/examples/key-bindings.zsh" quiet || load_plugin "fzf/shell/key-bindings.zsh"
  load_plugin "doc/fzf/examples/completion.zsh" quiet   || load_plugin "fzf/shell/completion.zsh"

  [[ -n "$functions[bashcompinit]" ]] || \
    autoload -Uz bashcompinit && bashcompinit
  [[ -f "/opt/homebrew/bin/aws_completer" ]] && \
    complete -C '/opt/homebrew/bin/aws_completer' aws

  # 1. FZF Tab (Replaces zsh-autocomplete)
  # Clear and Set Styles
  zstyle -d ':completion:*' format
  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
  zstyle ':completion:*' menu no
  # preview directory's content with eza when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
  # custom fzf flags
  # NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
  zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
  # To make fzf-tab follow FZF_DEFAULT_OPTS.
  # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  # switch group using `<` and `>`
  zstyle ':fzf-tab:*' switch-group '<' '>'
  load_plugin "fzf-tab/fzf-tab.zsh"

  # 2. Autosuggestions (must be after fzf-tab)
  load_plugin "zsh-autosuggestions/zsh-autosuggestions.zsh"
  # Bind Ctrl+Space to accept the suggestion
  bindkey '^ ' autosuggest-accept
  bindkey '^@' autosuggest-accept
  # This accepts just the next word of the ghost text
  bindkey '\e ' forward-word

  # 3. Syntax highlighting - must be last
  load_plugin "zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # To customize prompt, run `p10k configure` or edit ~/.config/dotfiles/zsh/.p10k.zsh.
  [[ ! -f ~/.config/dotfiles/zsh/.p10k.zsh ]] || source ~/.config/dotfiles/zsh/.p10k.zsh

fi
# }}}

# zprof > /tmp/prof
