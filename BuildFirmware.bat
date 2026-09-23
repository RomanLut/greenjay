@echo off
setlocal EnableExtensions

rem Build firmware inside the greenjay-builder Docker image (see BuildDockerImage.bat).
rem
rem   BuildFirmware.bat                                   all targets
rem   BuildFirmware.bat single_target VARIANT=A MCU=H FETON_DELAY=5 BRUSHED_PHASE=1
rem   BuildFirmware.bat clean
rem
rem Arguments are passed to make in src\. HEX files end up in src\build\hex.

set "ROOT=%~dp0"

docker image inspect greenjay-builder >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker image greenjay-builder not found. Run BuildDockerImage.bat first.
    exit /b 1
)

docker run --rm -v "%ROOT%src:/src" greenjay-builder %*
if errorlevel 1 (
    echo.
    echo Build failed. Logs are in src\build\log.
    exit /b 1
)

echo.
echo HEX files are in %ROOT%src\build\hex
exit /b 0
