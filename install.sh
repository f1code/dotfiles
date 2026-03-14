#!/bin/sh

$DOTFILES=~/.config/dotfiles
ln -s $DOTFILES/ghostty ~/.config
ln -s $DOTFILES/karabiner ~/.config
ln -s $DOTFILES/zellij ~/.config
cp $DOTFILES/zshenv ~
# for i in bin/*; do
#     ln -sf ~/.dotfiles/$i ~/$i 
# done
