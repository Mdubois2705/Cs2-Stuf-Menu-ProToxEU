@echo off
chcp 65001 >nul
title Menu Stuf - retour a la version precedente
set "B=%~dp0data\backup\stuff_menu.ahk.bak"
echo.
if not exist "%B%" (
  echo Aucune ancienne version enregistree : rien a restaurer.
  echo.
  pause
  exit /b 1
)
echo Ferme d'abord le menu : clic droit sur l'icone pres de l'horloge, puis Quitter.
echo.
pause
copy /Y "%B%" "%~dp0stuff_menu.ahk" >nul
if errorlevel 1 (
  echo Echec de la restauration.
) else (
  echo Ancienne version restauree. Tes stuffs n'ont pas ete touches. Relance le menu.
)
echo.
pause
