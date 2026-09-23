#!/bin/sh
# Unattended install of Keil C51 under Wine.
# The installer has no working silent mode, so drive its wizard with xdotool on
# a virtual 1280x800 display; the dialog is always centred at the same place.
set -e
INSTALLER="$1"

rm -rf /tmp/.X0-lock /tmp/.X11-unix
Xvfb :0 -screen 0 1280x800x24 >/dev/null 2>&1 &
export DISPLAY=:0
sleep 2
fluxbox >/dev/null 2>&1 &
sleep 1

wine "$INSTALLER" >/dev/null 2>&1 &
# Poll rather than "search --sync": windows vanishing mid-scan make that fail.
i=0
until xdotool search --name "Setup Keil C51" >/dev/null 2>&1; do
    i=$((i + 1)); [ $i -gt 60 ] && { echo "Keil installer did not start"; exit 1; }
    sleep 2
done
sleep 3

click() { xdotool mousemove "$1" "$2" click 1; sleep "${3:-2}"; }
field() { click 690 "$1" 0.3; xdotool type --delay 20 "$2"; }

click 810 543              # Welcome: Next
click 359 493 0.5          # License: "I agree"
click 810 543              # License: Next
click 810 543              # Folder (C:\Keil_v5): Next
field 381 "Greenjay"       # Customer information
field 420 "Builder"
field 459 "Personal"
field 496 "builder@localhost"
click 810 543              # Next: starts copying files

i=0
until [ -f "$KEIL_PATH/Ohx51.exe" ] && [ -f /root/.wine/drive_c/Keil_v5/TOOLS.INI ]; do
    i=$((i + 1)); [ $i -gt 120 ] && { echo "Keil install timed out"; exit 1; }
    sleep 2
done
sleep 10
click 353 357 0.5          # Finish page: untick "Show Release Notes"
click 810 543              # Finish

wineserver -k || true
pkill Xvfb || true
rm -rf /tmp/.X0-lock /tmp/.X11-unix

for t in AX51.exe LX51.exe Ohx51.exe; do
    [ -f "$KEIL_PATH/$t" ] || { echo "missing $KEIL_PATH/$t"; exit 1; }
done
echo "Keil C51 installed."
