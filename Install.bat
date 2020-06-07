@ECHO off
CLS

REM Check if Scrap Mechanic is running
tasklist /FI "IMAGENAME eq ScrapMechanic.exe" 2>NUL | find /I /N "ScrapMechanic.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Please close Scrap Mechanic before you install sm.interop
    pause
    exit
)

ECHO Finding Steam installation path
(for /f "usebackq tokens=1,2,*" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam" /v UninstallString`) do set SteamPath32=%%c)>nul 2>&1
(for /f "usebackq tokens=1,2,*" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam" /v UninstallString`) do set SteamPath64=%%c)>nul 2>&1
SET SteamPath=%SteamPath64%%SteamPath32%
SET SteamPath=%SteamPath:\uninstall.exe=%

IF NOT EXIST %SteamPath% (
    ECHO Steam is not installed on this system
    EXIT
)

ECHO Found Steam folder at %SteamPath%
set ScrapMechanicPath=%SteamPath%\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" goto :found

:enter
ECHO.
ECHO Could not find Scrap Mechanic folder. Please enter the Scrap Mechanic installation folder manually.
ECHO To exit this script, do not enter anything and press enter.
set /p ScrapMechanicPath="Scrap Mechanic folder: "
IF "%ScrapMechanicPath%" == "" EXIT
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
IF NOT "%VersionPath%" == "" GOTO :install
ECHO There is no sm.interop gamefile mod for your current Scrap Mechanic version (yet) (Found unknown hash: %ScrapMechanicHash%)
ECHO Do you want to use the latest version
SET /p UseLatest="Type y or n: "
IF UseLatest == "y" (
    SET VersionPath=v0.4.5
    GOTO :install
)
EXIT

:install
ECHO Installing sm.interop game files for version %VersionPath%
xcopy "GamefileMod\%VersionPath%" "%ScrapMechanicPath%" /y /s
ECHO Game files installed!
PAUSE
