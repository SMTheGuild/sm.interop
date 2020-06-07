echo off > nul
xcopy . ..\..\..\User_76561199055839592\Mods\sm.interop /y /s /EXCLUDE:buildexclude
copy description_build.json ..\..\..\User_76561199055839592\Mods\sm.interop\description.json
pause
