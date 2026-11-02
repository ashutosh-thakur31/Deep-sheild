@echo off
title DeepShield Frontend UI
cd /d "%~dp0frontend"
echo ============================================================
echo   Starting DeepShield React UI on http://localhost:5173
echo ============================================================
npm.cmd run dev
pause

