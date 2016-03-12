
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    #exec startx
    startx
fi

