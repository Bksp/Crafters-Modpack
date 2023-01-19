@echo off
color b
title Instalador de mods y hakeando tu PC
RMDIR /Q/S %appdata%\.minecraft\mods > NUL
xcopy .minecraft\* %appdata%\.minecraft\* /S /C /K /Y
echo ////////////////////////////////
echo Copia completa de todos los mods
echo ////////////////////////////////
@pause