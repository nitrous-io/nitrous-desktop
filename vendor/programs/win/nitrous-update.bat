@echo off
setlocal EnableExtensions

set process_id=%1
set app_path=%2
set archive_path=%3

set tmp_path=%TEMP%\nitrous-desktop-update
set backup_path=%app_path%.previous

echo %process_id%
echo %app_path%
echo %archive_path%
echo %tmp_path%
echo %backup_path%

:wait_for_app_termination
set app_alive=0
for /f "usebackq" %%A in (`tasklist /nh /fi "PID eq %process_id%"`) do set app_alive=1

if NOT %app_alive%==1 goto install_app

REM wait 1 second
ping -n 2 127.0.0.1 > NUL

goto wait_for_app_termination

:install_app
rd /s /q %tmp_path%
md %tmp_path%

%app_path%"\tools\unzip" %archive_path% -d %tmp_path%
move %app_path% %backup_path%
move %tmp_path%"\Nitrous Desktop" %app_path%

rd /s /q %backup_path%
del %archive_path%
rd /s /q %tmp_path%

start "" %app_path%"\NitrousDesktop.exe"

exit 0
