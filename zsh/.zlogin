
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    #exec startx
    ssh-agent startx
fi

