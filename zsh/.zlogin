
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    #exec startx
    startx
fi

