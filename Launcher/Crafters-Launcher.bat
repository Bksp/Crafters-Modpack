@echo off
setlocal enabledelayedexpansion
title CRAFTERS MODPACK - PLAY

REM ========================================================
REM   CRAFTERS MODPACK - SOLO LANZAR
REM ========================================================

set "MODPACK_NAME=.minecraft-1.20.1-crafters"
set "TARGET_DIR=%APPDATA%\%MODPACK_NAME%"
set "LAUNCHER_FILE=SKlauncher.jar"
set "LAUNCHER_EXE=%TARGET_DIR%\%LAUNCHER_FILE%"

if not exist "%LAUNCHER_EXE%" (
    echo [ERROR] No se encuntra el launcher en: %LAUNCHER_EXE%
    echo Por favor, ejecuta Crafters-Update.bat primero para instalarlo.
    pause
    exit /b 1
)

echo Ejecutando SKLauncher desde AppData...
start "" javaw -jar "%LAUNCHER_EXE%" --workDir "%TARGET_DIR%"
timeout /t 10 >nul
exit