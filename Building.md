# Building the firmware

The firmware is assembled with the Keil 8051 toolchain (AX51/LX51/OHX51). These instructions build it in
Docker on Windows: Keil runs under Wine inside a Linux container, so nothing is installed on Windows itself.
All 1584 targets build in about 15 minutes, and the output is identical to the files in [hex/](hex/).

To build with a native Simplicity Studio installation instead, see [src/Build-Instructions.md](src/Build-Instructions.md).

## Requirements

- Windows with [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Linux containers)
- A free Silicon Labs account (needed to download the compiler and get the license key)

## 1. Download the compiler

Download the **Keil C51** installer (`KeilC51_Install.exe`, Keil C51 V9.59) from Silicon Labs:

- Page: [8-bit Microcontroller Studio](https://www.silabs.com/software-and-tools/8-bit-8051-microcontroller-software-studio), "Download Keil"
- Direct link (sign-in required): <https://www.silabs.com/documents/login/software/KeilC51_Install.exe>

Save it as `tools\silabs\KeilC51_Install.exe`. The Docker image build runs this installer unattended, and the
automation is written for this exact installer.

## 2. Get the free license key

Without a license the Keil linker is limited to 2 KB of code, and the firmware is about 4.6 KB
(`ERROR L250: CODE SIZE LIMIT IN RESTRICTED VERSION EXCEEDED`). Silicon Labs gives out a free,
unrestricted Keil PK51 license for its 8-bit MCUs.

1. **Product key (PSN).** Fill in the form at <https://www.silabs.com/developers/keil-pk51>. The key, in the form
   `XXXXX-XXXXX-XXXXX`, is shown on the page after you submit.
2. **License ID Code (LIC).** Fill in <https://www.keil.com/license/install.htm> with:
   - Computer ID (CID): `CGQ01-K2G7M`. Every build of the Docker image has this CID, so you don't need to
     look it up.
   - Product Serial # (PSN): the key from step 1.

   Keil emails the LIC from `licmgr@keil.com`, in the form `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`.
3. Save the LIC as a single line in `docker\keil.lic`.

`tools\silabs\` and `docker\keil.lic` are git-ignored and never leave your machine.

## 3. Build the Docker image (once)

```
BuildDockerImage.bat
```

This creates the `greenjay-builder` image: Debian with Wine, Keil C51 installed, and the license activated.
It takes a few minutes. You can also pass the LIC as an argument (`BuildDockerImage.bat <LIC>`) instead of using `docker\keil.lic`.

## 4. Build the firmware

```
BuildFirmware.bat
```

This builds all targets. The HEX files are written to `src\build\hex` and the logs to `src\build\log`.
Any arguments are passed to `make`:

```
BuildFirmware.bat single_target VARIANT=A MCU=H FETON_DELAY=5 BRUSHED_PHASE=1
BuildFirmware.bat clean
```

## Removing everything

```
docker rmi greenjay-builder
```

Running `BuildDockerImage.bat` again later recreates the image with the same CID, so the same LIC keeps working.
