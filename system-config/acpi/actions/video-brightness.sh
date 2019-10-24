#!/bin/sh
bl_dev=/sys/class/backlight/intel_backlight
step=1000

case "$2" in
  BRTDN) echo $(($(< $bl_dev/brightness) - $step)) >$bl_dev/brightness;;
  BRTUP) echo $(($(< $bl_dev/brightness) + $step)) >$bl_dev/brightness;;
esac
