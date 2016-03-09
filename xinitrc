[ -f ~/.xprofile ] && source ~/.xprofile
[ -f ~/.Xresources ] && xrdb -merge -I$HOME ~/.Xresources
numlockx on
dunst &
# Note xsetroot does not work with Compton
hsetroot -solid '#111111'
exec i3
#exec awesome
#xsetroot -cursor_name left_ptr&
#exec xmonad
