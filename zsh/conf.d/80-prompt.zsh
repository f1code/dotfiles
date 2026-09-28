# not needed in Warp
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && return

cached_eval starship starship init zsh --print-full-init
