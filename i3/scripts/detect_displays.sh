#!/bin/sh

# setup dual monitor with primary on HDMI
if xrandr --query | grep HDMI1 | grep disconnected; then 
    xrandr --output eDP1 --auto --primary 
else
    xrandr --output eDP1 --off --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1
    #xrandr --output HDMI1 --auto --primary --output VGA1 --auto --right-of HDMI1
fi
