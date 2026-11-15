@echo off
title Desinstallation de Menu Stuf
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
echo.
pause
