echo off
cls
echo Send install.log to Xesau#1681 on Discord
echo Press a key to continue...
CALL :g > null

goto :eof
:g
cmd.exe /c install.bat debug > install.log
