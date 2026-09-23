#!/bin/sh
# Activate the Keil PK51 License ID Code (LIC) through uVision's
# File > License Management dialog. Besides the LIC0= line in TOOLS.INI the
# dialog stores activation data in the Wine registry, which the command-line
# tools check, so editing TOOLS.INI alone is not enough.
set -e
LIC="$1"
INI=/root/.wine/drive_c/Keil_v5/TOOLS.INI

if [ -z "$LIC" ]; then
    echo "No KEIL_LIC given: tools stay in evaluation mode (2 KB code limit)."
    exit 0
fi

rm -rf /tmp/.X0-lock /tmp/.X11-unix
Xvfb :0 -screen 0 1280x800x24 >/dev/null 2>&1 &
export DISPLAY=:0
sleep 2
fluxbox >/dev/null 2>&1 &
sleep 1

wine /root/.wine/drive_c/Keil_v5/UV4/UV4.exe >/dev/null 2>&1 &
# Poll rather than "search --sync": windows vanishing mid-scan make that fail.
i=0
until xdotool search --onlyvisible --name "Vision" >/dev/null 2>&1; do
    i=$((i + 1)); [ $i -gt 60 ] && { echo "uVision did not start"; exit 1; }
    sleep 2
done
sleep 8

click() { xdotool mousemove "$1" "$2" click 1; sleep "${3:-1}"; }

xdotool key Escape; sleep 0.5
click 22 40                # File menu
click 102 226 3            # License Management...
click 458 399 0.3          # New License ID Code field
xdotool type --delay 20 "$LIC"; sleep 0.3
click 662 399 2            # Add LIC
click 479 513 2            # Close
xdotool key alt+F4
sleep 3

wineserver -k || true
pkill Xvfb || true
rm -rf /tmp/.X0-lock /tmp/.X11-unix

grep -q "^LIC0=$LIC" "$INI" || { echo "LIC was not accepted (is the CID right?)"; exit 1; }
echo "Keil license activated."
