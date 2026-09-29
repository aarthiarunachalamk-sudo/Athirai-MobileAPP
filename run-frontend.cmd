@echo off
title ATHIRAI Flutter
cd /d C:\ATHIRAI\frontend
echo Starting ATHIRAI in Chrome at http://localhost:8080
echo Press r for hot reload once the app starts.
call "C:\Users\Admin\Downloads\flutter\bin\flutter.bat" run -d chrome --web-port 8080
echo Flutter stopped. Review any errors above.
pause
