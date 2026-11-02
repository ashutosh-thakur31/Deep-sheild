@echo off
title DeepShield Launcher
echo ============================================================
echo           DEEPSHIELD CYBERSECURITY PLATFORM
echo ============================================================
echo.
echo [1/3] Checking Python environment...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not found in PATH! Please install Python.
    pause
    exit /b 1
)

echo [2/3] Starting Flask Backend on http://localhost:5000 ...
start "DeepShield Backend API" cmd /k "cd /d "%~dp0" && python main.py"

echo [3/3] Starting React Frontend on http://localhost:5173 ...
start "DeepShield Frontend" cmd /k "cd /d "%~dp0frontend" && npm.cmd run dev"

echo.
echo ============================================================
echo DeepShield is starting up!
echo - Backend API:  http://localhost:5000
echo - Frontend UI:  http://localhost:5173
echo ============================================================
echo.
timeout /t 5 >nul
start http://localhost:5173
exit /b 0

