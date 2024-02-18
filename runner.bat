@echo off
color b
title Instalador de mods y hackeando tu PC

REM Eliminar la carpeta "mods" si existe
if exist "%appdata%\.minecraft\mods" (
    RMDIR /Q/S "%appdata%\.minecraft\mods" > NUL
    echo Eliminada la carpeta "mods"
)

REM Copiar los archivos
xcopy ".minecraft\*" "%appdata%\.minecraft\*" /S /C /K /Y

echo ////////////////////////////////
echo Copia completa de todos los mods
echo ////////////////////////////////
