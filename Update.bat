echo off
cls
tasklist /FI "IMAGENAME eq ScrapMechanic.exe" 2>NUL | find /I /N "ScrapMechanic.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Please close Scrap Mechanic before you update sm.interop
    pause
    exit
)
start steam://validate/387990
echo Wait until Steam is done validating Scrap Mechanic
pause
Install.bat
