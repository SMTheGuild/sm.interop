echo off
cls
tasklist /FI "IMAGENAME eq ScrapMechanic.exe" 2>NUL | find /I /N "ScrapMechanic.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Please close Scrap Mechanic before you update sm.interop
    pause
    exit
)

REM Don't validate because we're only overwriting previously overwritten files
REM start steam://validate/387990
REM echo Wait until Steam is done validating Scrap Mechanic
REM pause
Install.bat
