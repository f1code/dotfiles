#!/usr/bin/env python3

# Script to fix the network and use the USB device, if available, on resume

import os
import json
import sys
import re

if len(sys.argv) > 1 and sys.argv[1] != "post":
    sys.exit(1)

with os.popen("ip -j link") as f:
    devices = json.load(f)

onboard = [w for w in devices if re.match(r"wlp[^u]*", w["ifname"])]
usb = [w for w in devices if re.match(r"wlp.*u.*", w["ifname"])]

if not onboard:
    print("No onboard wifi detected")
    sys.exit(2)

onboard = onboard[0]
if not usb:
    print("No USB wifi detected")
    if "UP" not in onboard["flags"]:
        print("Restarting onboard")
        os.system(f"sudo systemctl restart netctl-auto@{onboard['ifname']}")
else:
    usb = usb[0]
    if "UP" in onboard["flags"]:
        print("Stopping onboard")
        os.system(f"sudo systemctl stop netctl-auto@{onboard['ifname']}")
    if "UP" not in usb["flags"]:
        print("Restarting usb")
        os.system(f"sudo systemctl restart netctl-auto@{usb['ifname']}")
