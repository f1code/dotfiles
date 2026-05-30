# after installing something run this to redo the completions
alias rebuild-completions='rm -f ~/.cache/prezto/zcompdump ~/.cache/prezto/zcompdump.zwc; exec zsh'

if [[ -o interactive ]] && [[ -z "$CURSOR_AGENT" ]] && [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
