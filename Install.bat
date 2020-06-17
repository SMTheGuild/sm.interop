@ECHO off
CLS

REM Check if Scrap Mechanic is running
tasklist /FI "IMAGENAME eq ScrapMechanic.exe" 2>NUL | find /I /N "ScrapMechanic.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Please close Scrap Mechanic before you install sm.interop
    pause
    GOTO :EOF
)

REM Try Common paths first
SET ScrapMechanicPath=C:\Program Files\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :found
SET ScrapMechanicPath=C:\Program Files (x86)\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :found
SET ScrapMechanicPath=D:\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :found
SET ScrapMechanicPath=B:\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :found

REM Try by finding the Steam installation path
FOR /f "delims=" %%a in ('reg query HKCU\Software\Valve\Steam /v SteamPath') DO SET SteamPath=%%a
SET SteamPath=%SteamPath:~26%
SET SteamPath=%SteamPath: =%
IF NOT EXIST "%SteamPath%" (
    FOR /f "delims=" %%a in ('reg query HKCU\Software\WOW6432Node\Valve\Steam /v SteamPath') DO SET SteamPath=%%a
    SET SteamPath=%SteamPath:~26%
    SET SteamPath=%SteamPath: =%
)
IF NOT EXIST "%SteamPath%" (
    FOR /f "delims=" %%a in ('reg query HKLM\SOFTWARE\WOW6432Node\Valve\Steam /v InstallPath') DO SET SteamPath=%%a
    SET SteamPath=%SteamPath:~26%
    SET SteamPath=%SteamPath: =%
)
IF NOT EXIST "%SteamPath%" (
    ECHO Could not find the Steam installation path
    GOTO :enter
)

ECHO Found Steam folder at %SteamPath%
SET ScrapMechanicPath=%SteamPath%\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" goto :found

:enter
ECHO.
ECHO Could not find Scrap Mechanic folder. Please enter the Scrap Mechanic installation folder manually.
ECHO To exit this script, do not enter anything and press enter.
SET /p ScrapMechanicPath="Scrap Mechanic folder: "
SET ScrapMechanicPath=%ScrapMechanicPath:"=%
IF "%ScrapMechanicPath%" == "" goto :EOF
IF NOT EXIST "%ScrapMechanicPath%" goto :enter

:found
ECHO Found Scrap Mechanic folder at: %ScrapMechanicPath%
ECHO Checking game version...

%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -c "(get-filehash -a md5 \"%ScrapMechanicPath%\Release\ScrapMechanic.exe\").Hash" > sm_hash.txt
SET /p ScrapMechanicHash=<sm_hash.txt
DEL sm_hash.txt

SET VersionPath=
IF "%ScrapMechanicHash%" == "DF6B87CF0D3B22236F264D5F9E6D4D8E" SET VersionPath=v0.4.5
IF "%ScrapMechanicHash%" == "3509749C8EC5490826715CE93D871C38" SET VersionPath=v0.4.5
IF "%ScrapMechanicHash%" == "1DA5EC95282C0A2E1562A97C0EA5F98C" SET VersionPath=v0.4.6
IF NOT "%VersionPath%" == "" GOTO :install
ECHO There is no sm.interop gamefile mod for your current Scrap Mechanic version (yet) (Found unknown hash: %ScrapMechanicHash%)
ECHO Do you want to use the latest version
SET /p UseLatest="Type y or n: "
IF UseLatest == "y" (
    SET VersionPath=v0.4.5
    GOTO :install
)
goto :EOF

:install
ECHO Installing sm.interop game files for version %VersionPath%
xcopy "GamefileMod\%VersionPath%" "%ScrapMechanicPath%" /y /s
ECHO Game files installed!
PAUSE

:EOF
