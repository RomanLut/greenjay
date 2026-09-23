@echo off
setlocal EnableExtensions

rem Build the "greenjay-builder" Docker image: Debian + Wine + Keil C51.
rem
rem Needs, locally (both are git-ignored):
rem   tools\silabs\KeilC51_Install.exe  Keil C51 installer
rem   docker\keil.lic                   Keil PK51 License ID Code (LIC), one line
rem                                     (or pass the LIC as the first argument)
rem
rem Remove everything again with:  docker rmi greenjay-builder

set "ROOT=%~dp0"

if not exist "%ROOT%tools\silabs\KeilC51_Install.exe" (
    echo ERROR: tools\silabs\KeilC51_Install.exe not found.
    exit /b 1
)

set "KEIL_LIC=%~1"
if not defined KEIL_LIC if exist "%ROOT%docker\keil.lic" set /p KEIL_LIC=<"%ROOT%docker\keil.lic"
if not defined KEIL_LIC (
    echo WARNING: no Keil LIC given - the linker stays limited to 2 KB and firmware builds will fail.
    echo          Put the LIC into docker\keil.lic or pass it as an argument.
)

docker build -f "%ROOT%docker\Dockerfile" --build-arg "KEIL_LIC=%KEIL_LIC%" -t greenjay-builder "%ROOT%."
if errorlevel 1 (
    echo.
    echo Docker image build failed.
    exit /b 1
)

echo.
echo Image greenjay-builder is ready. Run BuildFirmware.bat to build.
exit /b 0
