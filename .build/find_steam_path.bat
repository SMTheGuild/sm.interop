@echo OFF > NUL

REM Try Common paths first
SET ScrapMechanicPath=C:\Program Files\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :returnpath
SET ScrapMechanicPath=C:\Program Files (x86)\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :returnpath
SET ScrapMechanicPath=D:\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :returnpath
SET ScrapMechanicPath=B:\Steam\steamapps\common\Scrap Mechanic
IF EXIST "%ScrapMechanicPath%" GOTO :returnpath

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
    GOTO :EOF
)

SET SteamPath=%SteamPath:/=\%
SET SteamPath=%SteamPath:"=%
SET ScrapMechanicPath=%SteamPath%\steamapps\common\Scrap Mechanic
SET ScrapMechanicPath=%ScrapMechanicPath:"=%
IF EXIST "%ScrapMechanicPath%" goto :returnpath

:returnpath
echo %ScrapMechanicPath%
:EOF
