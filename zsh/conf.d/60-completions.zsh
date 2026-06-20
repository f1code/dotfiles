# Completions and FZF - not needed in Warp (it has its own)
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && return

# Custom fpath entries (must come before compinit)
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)

# FZF key bindings and completions
load_plugin "fzf/shell/key-bindings.zsh"
load_plugin "fzf/shell/completion.zsh"

[[ -n "$functions[bashcompinit]" ]] || \
  autoload -Uz bashcompinit && bashcompinit
[[ -f "/opt/homebrew/bin/aws_completer" ]] && \
  complete -C '/opt/homebrew/bin/aws_completer' aws
