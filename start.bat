@echo off
title SENTINEL PRO - Backend Server
color 0B
echo.
echo  ==========================================
echo   SENTINEL PRO v2.0.0 - Starting Server
echo  ==========================================
echo.

cd /d "%~dp0backend"

IF NOT EXIST venv (
    echo [1/3] Creating virtual environment...
    python -m venv venv
)

echo [2/3] Installing dependencies...
call venv\Scripts\activate.bat
pip install -r requirements.txt --quiet

echo [3/3] Starting Flask server...
echo.
echo  Server: http://localhost:5000
echo  Admin:  admin / admin123
echo.
python app.py

pause
