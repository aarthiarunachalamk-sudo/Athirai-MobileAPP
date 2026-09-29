@echo off
title ATHIRAI Backend
cd /d C:\ATHIRAI\backend
echo Starting ATHIRAI backend at http://127.0.0.1:8000
"C:\Users\Admin\AppData\Local\Programs\Python\Python313\python.exe" -u manage.py runserver 127.0.0.1:8000 --noreload
echo Backend stopped. Review any errors above.
pause
