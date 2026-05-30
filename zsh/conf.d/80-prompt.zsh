# Powerlevel10k prompt - not needed in Warp
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && return

# To customize prompt, run `p10k configure` or edit ~/.config/dotfiles/zsh/.p10k.zsh
[[ ! -f ~/.config/dotfiles/zsh/.p10k.zsh ]] || source ~/.config/dotfiles/zsh/.p10k.zsh
