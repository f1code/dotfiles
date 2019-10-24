#!/bin/sh

case "$1" in
  button/volumedown) CMD="amixer sset Master 5%- unmute" ;;
  button/volumeup) CMD="amixer sset Master 5%+ unmute" ;;
  button/mute) CMD="amixer sset Master toggle" ;;
esac
sudo -u nico XDG_RUNTIME_DIR=/run/user/1000 $CMD
