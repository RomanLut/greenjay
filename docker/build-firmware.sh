#!/bin/sh
# Container entrypoint: run src/Makefile with the Keil tools called through Wine.
# All arguments are passed to make (default target: all). Runs one job per CPU;
# a -jN argument overrides that.
#
# The sources are mounted at /src. Building directly on the Windows bind mount
# is I/O bound, so build in a container-local copy and copy only the hex files
# and logs back to /src/build.
set -e
[ $# -eq 0 ] && set -- all

if [ "$1" = clean ]; then
    rm -rf /src/build/*
    exit 0
fi

mkdir -p /work
tar -C /src --exclude=./build -cf - . | tar -C /work -xf -
cd /work

status=0
make -j"$(nproc)" \
    "KEIL_PATH=$KEIL_PATH" \
    "AX51=sh /usr/local/bin/keil.sh AX51.exe" \
    "LX51=sh /usr/local/bin/keil.sh LX51.exe" \
    "OX51=sh /usr/local/bin/keil.sh Ohx51.exe" \
    "$@" || status=$?

mkdir -p /src/build/hex /src/build/log
[ -d build/hex ] && cp build/hex/* /src/build/hex/ 2>/dev/null || true
[ -d build/log ] && cp build/log/* /src/build/log/ 2>/dev/null || true
exit $status
