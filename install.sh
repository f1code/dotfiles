#!/bin/bash

DOTFILES=$HOME/.config/dotfiles
ln -s $DOTFILES/ghostty ~/.config
ln -s $DOTFILES/karabiner ~/.config
ln -s $DOTFILES/zellij ~/.config
mkdir -p ~/.config/herdr && ln -s $DOTFILES/herdr/config.toml ~/.config/herdr/
ln -s $DOTFILES/opencode ~/.config
cp $DOTFILES/zshenv ~/.zshenv
# for i in bin/*; do
#     ln -sf ~/.dotfiles/$i ~/$i 
# done
