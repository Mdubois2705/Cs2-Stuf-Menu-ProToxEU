@echo off
title Mise a jour du menu CS2 Stuff
echo.
echo Mise a jour du menu CS2 Stuff
echo.
echo Ferme d'abord le script : clic droit sur l'icone verte H de la barre des taches, puis Quitter.
echo Tes stuffs, favoris, profils et reglages ne seront pas touches.
echo.
pause
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update.ps1"
echo.
pause
