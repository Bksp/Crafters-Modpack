@echo off
setlocal enabledelayedexpansion
title CRAFTERS MODPACK - CLIENTE
cls

REM ========================================================
REM   CRAFTERS MODPACK - CLIENTE
REM   [Ruta: .minecraft-1.20.1-crafters]
REM ========================================================

REM Directorios clave
set "SCRIPT_DIR=%~dp0"
REM Quitar slash final si existe
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "MODPACK_NAME=.minecraft-1.20.1-crafters"
set "TARGET_DIR=%APPDATA%\%MODPACK_NAME%"

REM URLs
set "PACK_URL=https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/pack.toml?v=%RANDOM%"
set "URL_PACKWIZ=https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
set "URL_SKLAUNCHER=https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/Launcher/SKlauncher.jar"

REM Nombres de archivo
set "BOOTSTRAP_FILE=packwiz-installer-bootstrap.jar"
set "LAUNCHER_FILE=SKlauncher.jar"

echo [1/5] Preparando entorno...
echo      - Directorio: %TARGET_DIR%

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

REM ---------------------------------------------------------
REM 1. OBTENER SKLAUNCHER (EN CARPETA DE INSTALACION)
REM ---------------------------------------------------------
set "LAUNCHER_EXE=%TARGET_DIR%\%LAUNCHER_FILE%"

REM Si existe localmente junto al script, lo copiamos a AppData (Offline Support)
if exist "%SCRIPT_DIR%\%LAUNCHER_FILE%" (
    echo [INFO] Copiando SKLauncher local a AppData...
    copy /Y "%SCRIPT_DIR%\%LAUNCHER_FILE%" "%LAUNCHER_EXE%" >nul
)

if not exist "%LAUNCHER_EXE%" (
    echo [AVISO] Descargando SKLauncher en AppData...
    curl -L -o "%LAUNCHER_EXE%" "%URL_SKLAUNCHER%"
)

if not exist "%LAUNCHER_EXE%" (
    echo [ERROR CRITICO] No se pudo descargar SKLauncher.
    pause
    exit /b 1
)

REM ---------------------------------------------------------
REM 2. ACTUALIZAR PACK (Packwiz)
REM ---------------------------------------------------------
echo.
echo [2/5] Verificando actualizador...
if not exist "%TARGET_DIR%\%BOOTSTRAP_FILE%" (
    echo      - Descargando Bootstrap...
    curl -L -o "%TARGET_DIR%\%BOOTSTRAP_FILE%" "%URL_PACKWIZ%"
)

echo.
echo [3/5] Actualizando Mods...
cd /d "%TARGET_DIR%"
java -jar "%BOOTSTRAP_FILE%" -g -s client "%PACK_URL%"

if %errorlevel% neq 0 (
    echo [ERROR] Fallo la actualizacion. Revisa tu conexion.
    set /p "RETRY=Deseas continuar de todas formas? (S/N): "
    if /i "!RETRY!" neq "S" exit /b 1
)


REM ---------------------------------------------------------
REM 2.5 ARREGLO MANUAL DE ARCHIVOS (Hash Fix)
REM ---------------------------------------------------------
echo.
echo.
echo [INFO] Descargando y aplicando configuraciones globales (Overrides)...

REM Descargamos el ZIP generado por BUILD_DEV (contiene config/ y ajustes de shaders)
curl -L -o "%TARGET_DIR%\config_overrides.zip" "https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/config_overrides.zip?v=%RANDOM%"

if exist "%TARGET_DIR%\config_overrides.zip" (
    echo      - Limpiando configuraciones antiguas...
    if exist "%TARGET_DIR%\config" rmdir /s /q "%TARGET_DIR%\config"
    if exist "%TARGET_DIR%\shaderpacks\*.txt" del /q "%TARGET_DIR%\shaderpacks\*.txt"

    echo      - Extrayendo configuraciones nuevas...
    powershell -Command "Expand-Archive -Path '%TARGET_DIR%\config_overrides.zip' -DestinationPath '%TARGET_DIR%' -Force"
    del "%TARGET_DIR%\config_overrides.zip"
) else (
    echo [ALERTA] No se pudo descargar config_overrides.zip
)


REM ---------------------------------------------------------
REM 3. GESTION DE MODS PRIVADOS (Packwiz Managed)
REM ---------------------------------------------------------
REM Antes se copiaban manualmente. Ahora estan integrados en Packwiz.
REM Esta seccion queda vacia porque el paso 2 ya los descargo.

REM ---------------------------------------------------------
REM 4. INYECCION DE PERFIL (launcher_profiles.json)
REM ---------------------------------------------------------
if not exist "launcher_profiles.json" (
    echo [ALERTA] No se encontro perfil. Se creara uno nuevo.
)

REM ---------------------------------------------------------
REM 5. LANZAMIENTO
REM ---------------------------------------------------------
echo.
echo [5/5] Iniciando SKLauncher...
echo      - Ejecutable: %LAUNCHER_EXE%
echo      - Directorio: %TARGET_DIR%

REM Asegurarnos de estar en el directorio correcto
cd /d "%TARGET_DIR%"

REM Ejecutar EL JAR QUE ESTA EN APPDATA, no el del script
start "" javaw -jar "%LAUNCHER_EXE%" --workDir "%TARGET_DIR%"

timeout /t 3 >nul
exit