IF NOT "%1" == "debug" (
  ECHO OFF
  CLS
)

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
for /f "tokens=* delims= " %%a in ("%SteamPath%") do set SteamPath=%%a
IF NOT EXIST "%SteamPath%" (
    FOR /f "delims=" %%a in ('reg query HKCU\Software\WOW6432Node\Valve\Steam /v SteamPath') DO SET SteamPath=%%a
    SET SteamPath=%SteamPath:~26%
    for /f "tokens=* delims= " %%a in ("%SteamPath%") do set SteamPath=%%a
)
IF NOT EXIST "%SteamPath%" (
    FOR /f "delims=" %%a in ('reg query HKLM\SOFTWARE\WOW6432Node\Valve\Steam /v InstallPath') DO SET SteamPath=%%a
    SET SteamPath=%SteamPath:~26%
    for /f "tokens=* delims= " %%a in ("%SteamPath%") do set SteamPath=%%a
)
IF NOT EXIST "%SteamPath%" (
    ECHO Could not find the Steam installation path
    GOTO :enter
)

SET SteamPath=%SteamPath:/=\%
SET SteamPath=%SteamPath:"=%
ECHO Found Steam folder at %SteamPath%
SET ScrapMechanicPath=%SteamPath%\steamapps\common\Scrap Mechanic
SET ScrapMechanicPath=%ScrapMechanicPath:"=%
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
ECHO Installing sm.interop game files
xcopy "GamefileMod" "%ScrapMechanicPath%" /y /s
ECHO Game files installed!
PAUSE

:EOF
