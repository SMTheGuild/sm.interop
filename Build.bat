@echo off > NUL

echo Verifying game file integrity...
start steam://validate/387990
echo Wait until game files are verified
pause

REM Find Scrap Mechanic installation path
for /f "tokens=*" %%i in ('.build\find_steam_path.bat') do set ScrapMechanicPath=%%i

REM Run scripts that merge new content with Scrap Mechanic
php .build\merge_iconmaps.php "%ScrapMechanicPath%"
php .build\merge_tools.php "%ScrapMechanicPath%"
php .build\append_scripts.php "%ScrapMechanicPath%"

REM Copy files to Build directory
xcopy . ..\..\..\User_76561199055839592\Mods\sm.interop /y /s /EXCLUDE:.build\buildexclude
copy .build\description.json ..\..\..\User_76561199055839592\Mods\sm.interop\description.json
pause
