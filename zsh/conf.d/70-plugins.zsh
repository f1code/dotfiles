# Plugins - not needed in Warp (it has its own)
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && return

# 1. FZF Tab (replaces zsh-autocomplete)
zstyle -d ':completion:*' format
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
load_plugin "fzf-tab/fzf-tab.zsh"

# 2. Autosuggestions (must be after fzf-tab)
load_plugin "zsh-autosuggestions/zsh-autosuggestions.zsh"
# Ctrl+Space to accept the full suggestion
bindkey '^ ' autosuggest-accept
bindkey '^@' autosuggest-accept
# Accept just the next word
bindkey '\e ' forward-word

# 3. Syntax highlighting (must be last)
load_plugin "zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
