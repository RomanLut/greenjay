# Greenjay firmware builder: Debian + Wine + Keil C51 (AX51/LX51/OHX51).
#
# Built by BuildDockerImage.bat from the repository root. The Keil installer
# (tools/silabs/KeilC51_Install.exe) and the Keil license (LIC) are supplied
# locally and are never committed.

FROM debian:trixie-slim

RUN dpkg --add-architecture i386 && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wine wine32:i386 make procps xvfb xdotool fluxbox ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV WINEDEBUG=-all \
    WINEPREFIX=/root/.wine \
    WINEARCH=win32 \
    KEIL_PATH=/root/.wine/drive_c/Keil_v5/C51/BIN

RUN wineboot --init && wineserver -w

# Fixed volume serial: part of the machine identity the Keil license (CID) is bound to.
RUN printf 'GJ00B11D' > /root/.wine/drive_c/.windows-serial

COPY tools/silabs/KeilC51_Install.exe /tmp/KeilC51_Install.exe
COPY docker/install-keil.sh /usr/local/bin/install-keil.sh
RUN sh /usr/local/bin/install-keil.sh /tmp/KeilC51_Install.exe && rm /tmp/KeilC51_Install.exe

ARG KEIL_LIC
COPY docker/add-license.sh /usr/local/bin/add-license.sh
RUN sh /usr/local/bin/add-license.sh "$KEIL_LIC"

COPY docker/keil.sh docker/build-firmware.sh /usr/local/bin/

WORKDIR /src
ENTRYPOINT ["sh", "/usr/local/bin/build-firmware.sh"]
