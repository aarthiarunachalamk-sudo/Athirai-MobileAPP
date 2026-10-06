@echo off
title ATHIRAI Backend
cd /d C:\ATHIRAI\backend

echo Setting up USB reverse for connected Android devices...
if exist "C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
    "C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000 2>nul
)

echo Starting ATHIRAI backend on 0.0.0.0:8000 (accessible via 127.0.0.1, 10.0.2.2, and 192.168.0.104)
"C:\Users\Admin\AppData\Local\Programs\Python\Python313\python.exe" -u manage.py runserver 0.0.0.0:8000 --noreload
echo Backend stopped. Review any errors above.
pause

