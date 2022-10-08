#!/bin/sh

# Script to detect displays and enable them accordingly
# Source: https://github.com/codingtony/udev-monitor-hotplug/blob/master/usr/local/bin/monitor-hotplug.sh

# setup dual monitor with primary on HDMI
# DEVICES=$(find /sys/class/drm/*/status)
DEVICES=$(xrandr | grep '\<connected\>' | cut -d ' ' -f 1)
#inspired by /etc/acpd/lid.sh and the function it sources
#
# displaynum=`ls /tmp/.X11-unix/* | sed s#/tmp/.X11-unix/X##`
# display=":$displaynum.0"
# export DISPLAY=":$displaynum.0"
#
# # from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
# export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')


#this while loop declare the $HDMI1 $VGA1 $LVDS1 and others if they are plugged in
while read dev
do
  devvar=$(echo $dev | tr -d '-')

  echo "$dev connected ($devvar)"
  declare $devvar="$dev";
done <<< "$DEVICES"
LIDOPEN=`grep open /proc/acpi/button/lid/LID/state`
if [ ! -z "$HDMI2" ]; then
  HDMI=HDMI2
elif [ ! -z "$HDMI1" ]; then
  HDMI=HDMI1
else
  HDMI=
fi


if [ ! -z "$HDMI" -a ! -z "$DP1" -a -z "$LIDOPEN" ]; then
  echo "$HDMI is plugged in, DP1 is plugged in, lid is closed - using DP1 as primary"
  PRIMARY=DP1
  xrandr --output DP1 --auto --primary --output $HDMI --auto --right-of DP1 --output eDP1 --off
elif [ ! -z "$HDMI" ]; then
  if [ ! -z "$LIDOPEN" ]; then
    echo "$HDMI is plugged in, lid is open - using $HDMI as primary"
    PRIMARY=$HDMI
    xrandr --output $HDMI --auto --primary --output eDP1 --auto --left-of $HDMI
  else
    echo "$HDMI is plugged in, lid is closed - using $HDMI as primary"
    PRIMARY=$HDMI
    xrandr --output $HDMI --auto --primary --output eDP1 --off
  fi
fi
if [ ! -z "$DVII11" -a -z "$PRIMARY" ]; then
  echo "Using displaylink $DVII11 1 as primary"
  xrandr --output "$DVII11" --auto --primary --output eDP1 --off
  PRIMARY=$DVII11
fi
if [ ! -z "$DVII22" -a ! -z "$PRIMARY" ]; then
  echo "Using displaylink $DVII22 as secondary"
  xrandr --output "$DVII22" --auto --primary --right-of $PRIMARY
fi
if [ -z "$PRIMARY" ]; then
  echo "No external monitors are plugged in - using eDP1 as primary"
  PRIMARY=eDP1
  xrandr --output HDMI2 --off --output HDMI1 --off --output eDP1 --auto --primary
fi


# if xrandr --query | grep HDMI1 | grep disconnected; then
#     xrandr --output eDP1 --auto --primary
# else
#     xrandr --output eDP1 --off --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1
#     #xrandr --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1
# fi
# While we are at it, let's reset the keyboard layout and restart xcape
killall xcape
setxkbmap us; xkbcomp ~/.dotfiles/xkb-colemak.xkb $DISPLAY
xcape -e "ISO_Level3_Shift=BackSpace;Alt_L=Return" -t 250
# xcape -e "Overlay1_Enable=BackSpace" -t 250
