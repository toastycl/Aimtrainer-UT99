@echo off
setlocal
where py >nul 2>nul
if errorlevel 1 (
    echo Python 3.10 or newer is required. Install Python with the Windows py launcher.
    pause
    exit /b 1
)
py -3 "%~dp0tools\start_aimtrainer.py" --ut-root "%~dp0."
if errorlevel 1 pause
