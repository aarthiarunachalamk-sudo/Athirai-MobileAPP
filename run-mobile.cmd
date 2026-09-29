@echo off
title ATHIRAI Android
cd /d C:\ATHIRAI\frontend
echo Connecting Android phone to the local backend over USB...
"C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe" -s 10BEA511UQ0015J reverse tcp:8000 tcp:8000
if errorlevel 1 goto end
echo Starting ATHIRAI on your Android phone. Keep USB connected.
call "C:\Users\Admin\Downloads\flutter\bin\flutter.bat" run -d 10BEA511UQ0015J --dart-define=API_BASE_URL=http://127.0.0.1:8000
:end
echo Mobile session stopped. Review any errors above.
pause
