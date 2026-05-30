# For profiling, if needed:
# zmodload zsh/zprof
# zprof > /tmp/prof

# Enable Powerlevel10k instant prompt. Must stay at the top.
# Initialization code requiring console input (password prompts, [y/n] confirmations)
# must go above this block; everything else may go below.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
