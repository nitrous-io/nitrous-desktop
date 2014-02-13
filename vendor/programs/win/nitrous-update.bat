@echo off
setlocal EnableExtensions

set process_id=%1
set app_path=%2
set archive_path=%3

set tmp_path=%TEMP%\nitrous-desktop-update
set backup_path=%app_path%.previous

:wait_for_app_termination

for /f "tokens=2 usebackq" %%A in (`tasklist /nh /fi "PID eq %process_id%" 2^>^&1`) do (
  if %%A==%process_id% (
    ping -n 2 127.0.0.1 > NUL
    goto wait_for_app_termination
  ) else (
    goto install_app
  )
)

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
