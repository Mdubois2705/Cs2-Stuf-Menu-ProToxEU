@echo off
title Installation de Menu Stuf
echo.
echo Installation de Menu Stuf
echo.
echo Ce programme copie le menu dans le dossier de ton choix, verifie
echo qu'AutoHotkey v2 est installe et cree un raccourci sur le bureau.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
