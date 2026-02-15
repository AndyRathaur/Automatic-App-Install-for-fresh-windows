@echo off
setlocal enabledelayedexpansion
title Ghost Spectre Master Automation 2026
color 0b

:: 1. Admin & Internet Check
net session >nul 2>&1 || (echo [!] Please Right-Click and Run as Admin! && pause && exit)
echo [*] Checking Internet...
:loop
ping -n 1 8.8.8.8 >nul || (timeout /t 5 && goto loop)

:: 2. Initialize Winget
echo [*] Initializing Windows Package Manager...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" >nul 2>&1
winget source update --accept-source-agreements >nul 2>&1

:: 3. The App Suite (Browsers, Search, Media)
echo [*] Installing Essentials...
winget install --id Microsoft.Edge -e --silent --accept-package-agreements --accept-source-agreements
winget install --id Mozilla.Firefox -e --silent --accept-package-agreements --accept-source-agreements
winget install --id voidtools.Everything -e --silent --accept-package-agreements --accept-source-agreements
winget install --id Flow-Launcher.Flow-Launcher -e --silent --accept-package-agreements --accept-source-agreements
winget install --id Stremio.Stremio -e --silent --accept-package-agreements --accept-source-agreements
winget install --id Daum.PotPlayer -e --silent --accept-package-agreements --accept-source-agreements

:: 4. Performance & Modding Tools (Using your Verified IDs)
echo [*] Installing Performance Tools...
winget install --id JavadMotallebi.NeatDownloadManager -e --silent --accept-package-agreements --accept-source-agreements
winget install --id GlennDelahoy.SnappyDriverInstallerOrigin -e --silent --accept-package-agreements --accept-source-agreements
winget install --id TechPowerUp.ThrottleStop -e --silent --accept-package-agreements --accept-source-agreements
winget install --id Google.PlatformTools -e --silent --accept-package-agreements --accept-source-agreements

:: 5. Create Desktop Shortcuts for Portable/Non-standard Apps
echo [*] Creating Desktop Shortcuts...
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -Command"

:: Create Flow Launcher Shortcut
%PS% "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(\"$env:USERPROFILE\Desktop\Flow Launcher.lnk\"); $s.TargetPath = \"$env:AppData\Local\FlowLauncher\Flow.Launcher.exe\"; $s.Save()"

:: Create ThrottleStop & SDIO Shortcuts (Search Winget Package Folder)
%PS% "$ws = New-Object -ComObject WScript.Shell; $pkgs = \"$env:LocalAppdata\Microsoft\WinGet\Packages\"; $s1 = $ws.CreateShortcut(\"$env:USERPROFILE\Desktop\ThrottleStop.lnk\"); $f1 = Get-ChildItem -Path $pkgs -Filter ThrottleStop.exe -Recurse | Select-Object -First 1; if($f1){$s1.TargetPath = $f1.FullName; $s1.Save()}"
%PS% "$ws = New-Object -ComObject WScript.Shell; $pkgs = \"$env:LocalAppdata\Microsoft\WinGet\Packages\"; $s2 = $ws.CreateShortcut(\"$env:USERPROFILE\Desktop\SDIO.lnk\"); $f2 = Get-ChildItem -Path $pkgs -Filter SDIO*.exe -Recurse | Select-Object -First 1; if($f2){$s2.TargetPath = $f2.FullName; $s2.Save()}"

:: 6. Automate ThrottleStop Startup Task
echo [*] Setting ThrottleStop to start on Login...
%PS% "$f = Get-ChildItem -Path \"$env:LocalAppdata\Microsoft\WinGet\Packages\" -Filter ThrottleStop.exe -Recurse | Select-Object -First 1; if($f){ schtasks /create /tn 'ThrottleStop_Startup' /tr \"`\"$($f.FullName)`\"\" /sc onlogon /rl highest /f }"

:: 7. Create Weekly Update Script & Task
(
echo @echo off
echo winget upgrade --all --silent --include-unknown --accept-package-agreements --accept-source-agreements
) > "%USERPROFILE%\Desktop\WeeklyUpdate.bat"
schtasks /create /tn "WeeklyAppUpdate" /tr "%USERPROFILE%\Desktop\WeeklyUpdate.bat" /sc weekly /d SUN /st 11:00 /rl highest /f

echo.
echo --------------------------------------------------
echo [+] DONE! Everything is ready.
echo  - Press Alt + Space for Flow Launcher.
echo  - ADB/Fastboot ready in CMD.
echo  - NDM, SDIO, and ThrottleStop are on your Desktop.
echo --------------------------------------------------
:: Launch Flow Launcher to finish setup
start "" "%AppData%\Local\FlowLauncher\Flow.Launcher.exe"
pause
exit
