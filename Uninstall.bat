@ECHO off
CLS

REM Check if Scrap Mechanic is running
tasklist /FI "IMAGENAME eq ScrapMechanic.exe" 2>NUL | find /I /N "ScrapMechanic.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Please close Scrap Mechanic before you uninstall sm.interop
    pause
    exit
)

start steam://validate/387990
echo Wait until Steam is done validating Scrap Mechanic
