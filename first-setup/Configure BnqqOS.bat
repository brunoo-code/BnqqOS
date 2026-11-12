@echo off
setlocal EnableExtensions DisableDelayedExpansion
title BnqqOS - Setup Toolkit
color 0B
set "logdir=%LOCALAPPDATA%\BnqqOS"
if not exist "%logdir%\" mkdir "%logdir%"
if not exist "%logdir%\" exit /b 1
set "log=%logdir%\setup.log"

:menu
cls
echo ============================================================
echo   ____  _   _  ___   ___   ___  ____
echo  ^| __ )^| \ ^| ^|/ _ \ / _ \ / _ \/ ___^|
echo  ^|  _ \^|  \^| ^| ^| ^| ^| ^| ^| ^| ^| ^| \___ \
echo  ^| ^|_) ^| ^|\  ^| ^|_^| ^| ^|_^| ^| ^|_^| ^|___) ^|
echo  ^|____/^|_^| \_^|\__\_\\__\_\\___/^|____/
echo  BnqqOS / First Setup
echo ============================================================
echo.
echo  FIRST SETUP
echo  [1] Prepare for gaming
echo  [2] Windows Update and optional drivers
echo  [3] Windows activation
echo  [4] Identify graphics hardware
echo  [5] Open setup log
echo.
echo  SYSTEM CHECKS
echo  [6] Review power plans
echo  [7] Inspect background services
echo  [8] Open Game Mode settings
echo  [9] Open full BNQQ Toolkit
echo.
echo  [0] Exit
echo.
choice /c 1234567890 /n /m "Select an option: "
if errorlevel 255 exit /b 1
if errorlevel 10 exit /b 0
if errorlevel 9 goto toolkit
if errorlevel 8 goto gamemode
if errorlevel 7 goto services
if errorlevel 6 goto power
if errorlevel 5 goto openlog
if errorlevel 4 goto gpu
if errorlevel 3 goto activation
if errorlevel 2 goto updates
if errorlevel 1 goto prepare
exit /b 0

:prepare
echo.
echo Visual C++ x64 and x86 runtimes are included on x64 Windows.
echo Choose the optional apps. Installers may show prompts.
where winget.exe >nul 2>&1
if errorlevel 1 (
    echo WinGet is unavailable. Update App Installer in Microsoft Store, then retry.
    echo [%date% %time%] WinGet unavailable>>"%log%"
    goto back
)
winget --version >nul 2>&1
if errorlevel 1 (
    echo WinGet could not start. Update App Installer in Microsoft Store, then retry.
    goto back
)
set "failures=0"
choice /c YN /n /m "Start setup? [Y/N] "
if errorlevel 2 goto menu
echo.>>"%log%"
echo [%date% %time%] Setup started>>"%log%"
call :install Microsoft.VCRedist.2015+.x64
call :install Microsoft.VCRedist.2015+.x86
call :optional WinRAR RARLab.WinRAR
call :optional Chrome Google.Chrome
call :optional Steam Valve.Steam
choice /c YN /n /m "Open the official VALORANT installer page for Riot Client? [Y/N] "
if errorlevel 2 goto summary
start "" "https://playvalorant.com/en-us/download/"
echo [%date% %time%] Riot installer page requested>>"%log%"

:summary
echo.
echo Package steps with errors: %failures%
echo Setup log: "%log%"
echo Open Windows Update from the menu and install applicable updates.
echo Restart if Windows Update or an installer requests it.
goto back

:optional
choice /c YN /n /m "Install %~1? [Y/N] "
if errorlevel 2 exit /b 0

:install
echo.
echo Checking %~1 ...
winget install --id "%~1" --exact --source winget --no-upgrade --accept-source-agreements
set "result=%errorlevel%"
echo [%date% %time%] %~1 exit code %result%>>"%log%"
if "%result%"=="0" exit /b 0
rem APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE (0x8A15002B)
if "%result%"=="-1978335189" (
    echo Already installed. No applicable upgrade.
    exit /b 0
)
set /a failures+=1 >nul
echo WinGet reported exit code %result%. See the output above.
exit /b 0

:updates
start "" ms-settings:windowsupdate
goto menu

:activation
start "" ms-settings:activation
goto menu

:gpu
powershell.exe -NoProfile -Command "Get-CimInstance Win32_VideoController | Format-Table Name, DriverVersion -AutoSize"
echo Use Windows Update or your PC or graphics manufacturer's official support page.
goto back

:power
echo.
powercfg.exe /getactivescheme
powercfg.exe /list
echo.
choice /c YN /n /m "Open Windows Power Options? [Y/N] "
if errorlevel 2 goto menu
start "" control.exe /name Microsoft.PowerOptions
goto menu

:services
echo.
powershell.exe -NoProfile -Command "Get-CimInstance Win32_Service -Filter \"Name='SysMain' OR Name='WSearch' OR Name='DiagTrack' OR Name='wuauserv' OR Name='WinDefend'\" | Sort-Object Name | Format-Table Name, DisplayName, StartMode, State -AutoSize"
goto back

:gamemode
start "" ms-settings:gaming-gamemode
goto menu

:toolkit
set "optimizer=%ProgramFiles%\BnqqOS\BNQQ_Optimizer.exe"
if not exist "%optimizer%" set "optimizer=%~dp0BNQQ_Optimizer.exe"
if not exist "%optimizer%" (
    echo The full BNQQ Toolkit is not included in this build.
    goto back
)
start "" "%optimizer%"
if errorlevel 1 (
    echo The BNQQ Toolkit did not start.
    goto back
)
goto menu

:openlog
if exist "%log%" (
    start "" notepad.exe "%log%"
    goto menu
)
echo Run Prepare for gaming to create the log.

:back
echo.
pause
goto menu
