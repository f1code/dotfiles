
# System scripts
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

[ -f ~/.xprofile ] && source ~/.xprofile
[ -f ~/.dotfiles/Xresources ] && xrdb -merge -I$HOME/.dotfiles ~/.dotfiles/Xresources
numlockx on
dunst &
# Note xsetroot does not work with Compton
hsetroot -solid '#111111'
exec i3
#exec awesome
#xsetroot -cursor_name left_ptr&
#exec xmonad
