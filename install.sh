#!/bin/sh

cd ~/.dotfiles
for i in gsimplecal dunst fontconfig i3; do
    ln -sf ~/.dotfiles/$i ~/.config/$i 
done
for i in zshenv tmux.conf npmrc xprofile xinitrc remmina; do
    ln -sf ~/.dotfiles/$i ~/.$i 
done
for i in bin/*; do
    ln -sf ~/.dotfiles/$i ~/$i 
done
