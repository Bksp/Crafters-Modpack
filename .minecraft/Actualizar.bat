@echo off
title ACTUALIZADOR CRAFTERS MODPACK
color 0B
cls
echo ========================================================
echo   CONECTANDO CON GITHUB PARA ACTUALIZAR MODS...
echo ========================================================
echo.

:: Comprobamos si existe el archivo necesario
if not exist .\packwiz-installer-bootstrap.jar (
    color 0C
    echo [ERROR] No encuentro el archivo 'packwiz-installer-bootstrap.jar'.
    echo Asegurate de que este archivo .bat este en la misma carpeta que el .jar
    pause
    exit
)

:: Ejecuta la actualizacion usando la ruta relativa .\
:: Esta es la URL RAW de tu pack.toml
java -jar .\packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/pack.toml

echo.
echo ========================================================
echo   TODO LISTO. YA PUEDES ABRIR EL LAUNCHER.
echo ========================================================
echo.
pause