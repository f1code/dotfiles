#!/bin/sh

# Script to detect displays and enable them accordingly
# Source: https://github.com/codingtony/udev-monitor-hotplug/blob/master/usr/local/bin/monitor-hotplug.sh

# setup dual monitor with primary on HDMI
DEVICES=$(find /sys/class/drm/*/status)
#inspired by /etc/acpd/lid.sh and the function it sources
#
# displaynum=`ls /tmp/.X11-unix/* | sed s#/tmp/.X11-unix/X##`
# display=":$displaynum.0"
# export DISPLAY=":$displaynum.0"
#
# # from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
# export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')


#this while loop declare the $HDMI1 $VGA1 $LVDS1 and others if they are plugged in
while read l
do
  dir=$(dirname $l);
  status=$(cat $l);
  dev=$(echo $dir | cut -d\- -f 2-);

  if [ $(expr match  $dev "HDMI") != "0" ]
  then
#REMOVE THE -X- part from HDMI-X-n
    dev=HDMI${dev#HDMI-?-}
  else
    dev=$(echo $dev | tr -d '-')
  fi

  if [ "connected" == "$status" ]
  then
    echo $dev "connected"
    declare $dev="yes";

  fi
done <<< "$DEVICES"

if [ ! -z "$HDMI1" -a ! -z "$VGA1" ]
then
  echo "HDMI1 and VGA1 are plugged in"
  xrandr --output eDP1 --off --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1 
elif [ ! -z "$HDMI1" -a -z "$VGA1" ]; then
  echo "HDMI1 is plugged in, but not VGA1"
  xrandr --output VGA1 --off --output eDP1 --off --output HDMI1 --auto --primary
elif [ -z "$HDMI1" -a ! -z "$VGA1" ]; then
  echo "VGA1 is plugged in, but not HDMI1"
  xrandr --output HDMI1 --off --output eDP1 --off --output VGA1 --auto --primary
else
  echo "No external monitors are plugged in"
  xrandr --output HDMI1 --off --output VGA1 --off --output eDP1 --auto --primary
fi

# if xrandr --query | grep HDMI1 | grep disconnected; then 
#     xrandr --output eDP1 --auto --primary 
# else
#     xrandr --output eDP1 --off --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1
#     #xrandr --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1
# fi
# While we are at it, let's restart xcape
killall xcape
xcape -e "ISO_Level3_Shift=BackSpace" -t 250
# xcape -e "Overlay1_Enable=BackSpace" -t 250
