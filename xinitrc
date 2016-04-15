
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
numlockx on
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
xmodmap ~/.dotfiles/xmodmap.us
#xmodmap ~/.dotfiles/xmodmap.norman
# auto repeat for backspace
#xset r 66  
# default to headset
pactl set-default-sink 1
# Allow tapping caps key for escape
# Not too sure about the Shift one but left shift was getting 
# hit too much by mistake
exec xcape -e "Mode_switch=Escape;Shift_R=Return" -t 350

exec i3
#exec awesome
#xsetroot -cursor_name left_ptr&
#exec xmonad
