#!/bin/bash

# Script to put the laptop on sleep when lid closed, if there is no external display connected
# To install: copy to /etc/acpi

case "$3" in
  close)
    logger "Lid closed"
  HAS_EXTERNAL=`DISPLAY=:0 su nico -c "/usr/bin/xrandr --query" |
    grep connected | 
    grep -v disconnected |
    grep -v eDP`
  if ! [ -z "$HAS_EXTERNAL" ]; then exit 1; fi
  /bin/grep -q open /proc/acpi/button/lid/LID/state && exit 2
  DISPLAY=:0 su nico -c /usr/bin/i3lock
  /bin/systemctl suspend
    ;;
  *)
    logger "ACPI action undefined $3"
    ;;
esac
