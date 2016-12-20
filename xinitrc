
# System scripts
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

[ -f ~/.xprofile ] && source ~/.xprofile
[ -f ~/.dotfiles/Xresources ] && xrdb -merge -I$HOME/.dotfiles ~/.dotfiles/Xresources
# default numlock on
# numlockx on
# notification daemon
dunst &
dropbox &
nm-applet &
# Note xsetroot does not work with Compton
hsetroot -solid '#111111'
# use caps as super
#setxkbmap -option caps:super
# map backspace instead 
#setxkbmap -option caps:backspace
# Load xmodmap, keyboard options are in there.
#xmodmap ~/.dotfiles/xmodmap.us
#xmodmap ~/.dotfiles/xmodmap.colemak
xkbcomp ~/.dotfiles/xkb-colemak.xkb $DISPLAY
# auto repeat for backspace
#xset r 66  
# default to headset
pactl set-default-sink 1

exec i3
#exec awesome
#xsetroot -cursor_name left_ptr&
#exec xmonad
