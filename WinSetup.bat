@echo off
setlocal enabledelayedexpansion
title Ghost Spectre Minimalist Automation
color 0b

:: 1. Admin & Internet Check
net session >nul 2>&1 || (echo [!] Please Right-Click and Run as Admin! && pause && exit)
echo [*] Checking Internet...
:loop
ping -n 1 8.8.8.8 >nul || (timeout /t 5 && goto loop)

:: 2. Initialize Winget
echo [*] Initializing Windows Package Manager...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" >nul 2>&1
winget source update >nul 2>&1

:: 3. The App Suite
echo [*] Installing Browsers...
winget install --id Microsoft.Edge -e --silent --accept-package-agreements
winget install --id Mozilla.Firefox -e --silent --accept-package-agreements

echo [*] Installing Search & Launcher...
winget install --id BiniSoft.Listary -e --silent --accept-package-agreements
winget install --id voidtools.Everything -e --silent --accept-package-agreements

echo [*] Installing Media & Downloads...
winget install --id Stremio.Stremio -e --silent --accept-package-agreements
winget install --id Daum.PotPlayer -e --silent --accept-package-agreements
winget install --id Neat.NeatDownloadManager -e --silent --accept-package-agreements

echo [*] Installing Optimization & Modding Tools...
winget install --id TechPowerUp.ThrottleStop -e --silent --accept-package-agreements
winget install --id Google.PlatformTools -e --silent --accept-package-agreements

:: 4. Snappy Driver (Desktop Folder)
set "SDIO_PATH=%USERPROFILE%\Desktop\SnappyDriver"
if not exist "%SDIO_PATH%" (
    echo [*] Setting up Snappy Driver...
    mkdir "%SDIO_PATH%"
    winget install --id GlennDelahoy.SnappyDriverInstallerOrigin --location "%SDIO_PATH%" --accept-package-agreements
)

:: 5. Automate ThrottleStop Startup
echo [*] Setting ThrottleStop to start on Login...
set "TS_EXE=C:\Program Files\ThrottleStop\ThrottleStop.exe"
if exist "%TS_EXE%" (
    schtasks /create /tn "ThrottleStop_Startup" /tr "'%TS_EXE%'" /sc onlogon /rl highest /f
)

:: 6. Create Weekly Update Script & Task
(
echo @echo off
echo winget upgrade --all --silent --include-unknown --accept-package-agreements --accept-source-agreements
) > "%USERPROFILE%\Desktop\WeeklyUpdate.bat"

schtasks /create /tn "WeeklyAppUpdate" /tr "%USERPROFILE%\Desktop\WeeklyUpdate.bat" /sc weekly /d SUN /st 11:00 /rl highest /f

echo.
echo --------------------------------------------------
echo [+] DONE! Everything is ready.
echo  - Browsers: Edge and Firefox are installed.
echo  - Search: Alt + Space for Listary.
echo  - ThrottleStop: Set to run automatically on boot.
echo --------------------------------------------------
pause
exit
