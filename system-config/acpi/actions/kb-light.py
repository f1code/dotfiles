#!/usr/bin/env python3

import dbus
import sys

def kb_light_toggle():
    bus = dbus.SystemBus()
    kbd_backlight_proxy = bus.get_object('org.freedesktop.UPower', '/org/freedesktop/UPower/KbdBacklight')
    kbd_backlight = dbus.Interface(kbd_backlight_proxy, 'org.freedesktop.UPower.KbdBacklight')
    current = kbd_backlight.GetBrightness()
    maximum = kbd_backlight.GetMaxBrightness()
    if current == 0:
        kbd_backlight.SetBrightness(1)
    else:
        kbd_backlight.SetBrightness(0)


if __name__ ==  '__main__':
    kb_light_toggle()
