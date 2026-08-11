# For profiling, if needed:
# zmodload zsh/zprof
# zprof > /tmp/prof

# Enable Powerlevel10k instant prompt. Must stay at the top.
# Initialization code requiring console input (password prompts, [y/n] confirmations)
# must go above this block; everything else may go below.
# direnv export must be eager here (before p10k's instant-prompt cache
# takes over) so cwd env vars are set before any prompt renders. This is
# safe only because 00-tools-path.zsh (brew/fnm) already ran and finished
# mutating PATH — direnv's export snapshots PATH now as its restore
# baseline, so unload will preserve fnm's additions.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
