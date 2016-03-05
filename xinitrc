[ -f ~/.xprofile ] && source ~/.xprofile
[ -f ~/.Xresources ] && xrdb -merge -I$HOME ~/.Xresources
exec i3
#exec awesome
#xsetroot -cursor_name left_ptr&
#exec xmonad
