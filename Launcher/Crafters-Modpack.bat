@echo off
setlocal
title CRAFTERS MODPACK - CLIENTE
color 0b
cls

REM ========================================================
REM   CRAFTERS MODPACK - CLIENTE
REM   [Ruta: .minecraft-1.20.1-crafters]
REM ========================================================

REM Definir directorios y archivos
set "SCRIPT_DIR=%~dp0"
set "INSTALL_DIR=%APPDATA%\.minecraft-1.20.1-crafters"
set "TEMP_DIR=%TEMP%\CraftersTemp"

set "PACK_URL=https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/pack.toml"
set "URL_PACKWIZ=https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
set "URL_SKLAUNCHER=https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/Launcher/SKlauncher.jar"

set "BOOTSTRAP_FILE=packwiz-installer-bootstrap.jar"
set "LAUNCHER_FILE=SKlauncher.jar"

echo.
echo [1/6] Preparando directorios...

REM Crear carpeta temporal y limpiar
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
del /q "%TEMP_DIR%\*.*" 2>nul

REM Crear carpeta de instalacion si no existe
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [2/6] Verificando herramientas en %TEMP_DIR%...

REM --- Descarga de Bootstrap (Logica Plana sin bloques IF complejos) ---
if exist "%INSTALL_DIR%\%BOOTSTRAP_FILE%" goto CheckBootstrapSize
echo      - Descargando Packwiz Bootstrap...
curl -L -o "%TEMP_DIR%\%BOOTSTRAP_FILE%" "%URL_PACKWIZ%"
copy /Y "%TEMP_DIR%\%BOOTSTRAP_FILE%" "%INSTALL_DIR%\" >nul
goto CheckBootstrapSize

:CheckBootstrapSize
if not exist "%INSTALL_DIR%\%BOOTSTRAP_FILE%" goto ErrorBootstrap
REM Validar tamaño (mas de 1KB)
for %%I in ("%INSTALL_DIR%\%BOOTSTRAP_FILE%") do if %%~zI LSS 1000 goto ErrorBootstrap
goto CheckLauncher

:ErrorBootstrap
echo [ERROR] No se pudo descargar el Bootstrap o esta corrupto.
echo Intenta borrar la carpeta %INSTALL_DIR% manualmente.
pause
exit /b 1

REM --- Descarga de Launcher ---
:CheckLauncher
if exist "%INSTALL_DIR%\%LAUNCHER_FILE%" goto CheckLauncherSize
echo      - Descargando SKLauncher...
curl -L -o "%TEMP_DIR%\%LAUNCHER_FILE%" "%URL_SKLAUNCHER%"
copy /Y "%TEMP_DIR%\%LAUNCHER_FILE%" "%INSTALL_DIR%\" >nul
goto CheckLauncherSize

:CheckLauncherSize
if not exist "%INSTALL_DIR%\%LAUNCHER_FILE%" goto ErrorLauncher
REM Validar tamaño (mas de 1MB)
for %%I in ("%INSTALL_DIR%\%LAUNCHER_FILE%") do if %%~zI LSS 1000000 goto ErrorLauncher
goto UpdateModpack

:ErrorLauncher
echo [ERROR] No se pudo descargar SKLauncher (Error 404 o sin conexion).
echo Verificado URL: %URL_SKLAUNCHER%
pause
exit /b 1

REM --- Actualizacion ---
:UpdateModpack
echo.
echo [3/6] Iniciando actualizacion...
cd /d "%INSTALL_DIR%"

REM Verificar JAVA
java -version >nul 2>&1
if %errorlevel% neq 0 goto ErrorJava

REM Ejecutar Packwiz
java -jar "%BOOTSTRAP_FILE%" -g -s client "%PACK_URL%"
if %errorlevel% neq 0 goto ErrorUpdate
goto CopyLocalMods

:ErrorJava
echo [ERROR CRITICO] Java no detectado. Instala Java 17+.
pause
exit /b 1

:ErrorUpdate
echo [ERROR] Fallo al actualizar el modpack. Revisa tu conexion.
pause
exit /b 1

REM --- Copia de Mods Locales ---
:CopyLocalMods
echo.
echo [4/6] Fusionando mods locales...

if not exist "%SCRIPT_DIR%mods_github" goto CheckDevMods
echo      - Detectada carpeta mods_github junto al script.
xcopy /E /I /Y "%SCRIPT_DIR%mods_github" "%TEMP_DIR%\mods_github" >nul
goto ApplyMods

:CheckDevMods
if not exist "%SCRIPT_DIR%..\.minecraft\mods_github" goto NoLocalMods
echo      - Detectada carpeta mods_github en entorno DEV.
xcopy /E /I /Y "%SCRIPT_DIR%..\.minecraft\mods_github" "%TEMP_DIR%\mods_github" >nul
goto ApplyMods

:ApplyMods
echo      - Moviendo mods a la instalacion...
if not exist "%INSTALL_DIR%\mods" mkdir "%INSTALL_DIR%\mods"
move /Y "%TEMP_DIR%\mods_github\*.jar" "%INSTALL_DIR%\mods\" >nul
echo      - Mods privados instalados.
goto Launch

:NoLocalMods
echo      - No se encontraron mods privados para instalar.

REM --- Lanzar ---
:Launch
echo.
echo [5/6] Limpiando temporales...
rd /s /q "%TEMP_DIR%" 2>nul

echo.
echo [6/6] Abriendo Launcher...
start "" "%INSTALL_DIR%\%LAUNCHER_FILE%"
timeout /t 3 >nul
exit