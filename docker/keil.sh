#!/bin/sh
# Run a Keil tool under Wine with its own TEMP directory: AX51 keeps its
# intermediate data in a fixed %TEMP%\__AX51_2 file, so parallel make jobs
# sharing one TEMP corrupt each other's output. Wine ignores TEMP from the
# Linux environment, so set it inside cmd.
# Usage: keil.sh AX51.exe|LX51.exe|Ohx51.exe [arguments...]
tool="$1"; shift
tmp=$(mktemp -d /tmp/keil.XXXXXX)
wtmp="Z:$(echo "$tmp" | tr / '\\')"
wine cmd /c "set TEMP=$wtmp&& set TMP=$wtmp&& C:\\Keil_v5\\C51\\BIN\\$tool $*"
status=$?
rm -rf "$tmp"
exit $status
