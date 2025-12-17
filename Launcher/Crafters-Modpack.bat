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
REM Eliminar backslash final de SCRIPT_DIR si existe para consistencia
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "INSTALL_DIR=%APPDATA%\.minecraft-1.20.1-crafters"
set "TEMP_DIR=%TEMP%\CraftersTemp"

REM URLs de Fallback (Solo se usan si no se encuentran archivos locales)
set "PACK_URL=https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/pack.toml"
set "URL_PACKWIZ=https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
REM Ajustar URL si es necesario, pero priorizaremos local
set "URL_SKLAUNCHER=https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/Launcher/SKlauncher.jar"

set "BOOTSTRAP_FILE=packwiz-installer-bootstrap.jar"
set "LAUNCHER_FILE=SKlauncher.jar"

echo.
echo [1/6] Preparando directorios...
echo      - Directorio de Instalacion: %INSTALL_DIR%

REM Crear carpeta temporal y limpiar
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
del /q "%TEMP_DIR%\*.*" 2>nul

REM Crear carpeta de instalacion si no existe
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [2/6] Verificando herramientas...

REM ---------------------------------------------------------
REM 1. OBTENCION DE BOOTSTRAP (Local > Descarga)
REM ---------------------------------------------------------
set "BOOTSTRAP_PATH="
REM Buscar localmente
if exist "%SCRIPT_DIR%\%BOOTSTRAP_FILE%" set "BOOTSTRAP_PATH=%SCRIPT_DIR%\%BOOTSTRAP_FILE%"
if exist "%SCRIPT_DIR%\..\%BOOTSTRAP_FILE%" set "BOOTSTRAP_PATH=%SCRIPT_DIR%\..\%BOOTSTRAP_FILE%"
if exist "%INSTALL_DIR%\%BOOTSTRAP_FILE%" set "BOOTSTRAP_PATH=%INSTALL_DIR%\%BOOTSTRAP_FILE%"

if defined BOOTSTRAP_PATH (
    echo      - Usando Bootstrap local: %BOOTSTRAP_PATH%
    copy /Y "%BOOTSTRAP_PATH%" "%INSTALL_DIR%\%BOOTSTRAP_FILE%" >nul
) else (
    echo      - Descargando Bootstrap desde Internet...
    curl -L -o "%INSTALL_DIR%\%BOOTSTRAP_FILE%" "%URL_PACKWIZ%"
)

REM Validar Bootstrap
if not exist "%INSTALL_DIR%\%BOOTSTRAP_FILE%" goto ErrorBootstrap
for %%I in ("%INSTALL_DIR%\%BOOTSTRAP_FILE%") do if %%~zI LSS 1000 goto ErrorBootstrap
goto CheckLauncher

:ErrorBootstrap
echo [ERROR] No se pudo obtener el Bootstrap (packwiz).
pause
exit /b 1

REM ---------------------------------------------------------
REM 2. OBTENCION DE SKLAUNCHER (Local > Descarga)
REM ---------------------------------------------------------
:CheckLauncher
set "LAUNCHER_PATH="
REM Buscar localmente en orden de prioridad
if exist "%SCRIPT_DIR%\%LAUNCHER_FILE%" set "LAUNCHER_PATH=%SCRIPT_DIR%\%LAUNCHER_FILE%"
if exist "%SCRIPT_DIR%\..\%LAUNCHER_FILE%" set "LAUNCHER_PATH=%SCRIPT_DIR%\..\%LAUNCHER_FILE%"
if exist "%INSTALL_DIR%\%LAUNCHER_FILE%" set "LAUNCHER_PATH=%INSTALL_DIR%\%LAUNCHER_FILE%"

if defined LAUNCHER_PATH (
    echo      - Usando SKLauncher local: %LAUNCHER_PATH%
    copy /Y "%LAUNCHER_PATH%" "%INSTALL_DIR%\%LAUNCHER_FILE%" >nul
) else (
    echo      - Descargando SKLauncher desde Internet...
    curl -L -o "%INSTALL_DIR%\%LAUNCHER_FILE%" "%URL_SKLAUNCHER%"
)

REM Validar Launcher
if not exist "%INSTALL_DIR%\%LAUNCHER_FILE%" goto ErrorLauncher
for %%I in ("%INSTALL_DIR%\%LAUNCHER_FILE%") do if %%~zI LSS 1000000 goto ErrorLauncher
goto UpdateModpack

:ErrorLauncher
echo [ERROR] No se pudo obtener SKLauncher.
echo Intenta colocar 'SKlauncher.jar' en la misma carpeta que este script.
pause
exit /b 1

REM ---------------------------------------------------------
REM 3. ACTUALIZACION DEL MODPACK
REM ---------------------------------------------------------
:UpdateModpack
echo.
echo [3/6] Iniciando actualizacion (Packwiz)...
cd /d "%INSTALL_DIR%"

java -jar "%BOOTSTRAP_FILE%" -g -s client "%PACK_URL%"
if %errorlevel% neq 0 goto ErrorUpdate
goto CopyLocalMods

:ErrorUpdate
echo.
echo [ERROR] Fallo la actualizacion.
echo POSIBLES CAUSAS:
echo 1. 'Hash invalid': El desarrollador modifico archivos sin actualizar el indice (pack.toml).
echo 2. Sin internet: Verifica tu conexion.
echo.
echo Quieres intentar iniciar de todas formas? (Puede crashear)
set /p "CONTINUE=Escribe S para Si, N para No: "
if /i "%CONTINUE%"=="S" goto CopyLocalMods
exit /b 1

REM ---------------------------------------------------------
REM 4. GESTION DE MODS PRIVADOS (mods_github -> mods)
REM ---------------------------------------------------------
:CopyLocalMods
echo.
echo [4/6] Gestionando mods privados...

REM Definir origen de mods locales
set "LOCAL_MODS_SOURCE="
if exist "%SCRIPT_DIR%\mods_github" set "LOCAL_MODS_SOURCE=%SCRIPT_DIR%\mods_github"
if exist "%SCRIPT_DIR%\..\.minecraft\mods_github" set "LOCAL_MODS_SOURCE=%SCRIPT_DIR%\..\.minecraft\mods_github"

if defined LOCAL_MODS_SOURCE (
    echo      - Fuente de mods detectada: %LOCAL_MODS_SOURCE%
    
    REM Copiar a carpeta de instalacion temporalmente (mods_github) para luego mover
    xcopy /E /I /Y "%LOCAL_MODS_SOURCE%" "%INSTALL_DIR%\mods_github" >nul
    
    REM Mover de mods_github a mods (aplanando estructura)
    if not exist "%INSTALL_DIR%\mods" mkdir "%INSTALL_DIR%\mods"
    
    echo      - Moviendo archivos .jar a la carpeta mods...
    move /Y "%INSTALL_DIR%\mods_github\*.jar" "%INSTALL_DIR%\mods\" >nul
    
    REM Limpiar carpeta auxiliar si quedo vacia o con basura
    rd /s /q "%INSTALL_DIR%\mods_github" 2>nul
    
    echo      - Mods privados instalados exitosamente.
) else (
    echo      - No se encontraron mods locales (mods_github). Omitiendo.
)

REM ---------------------------------------------------------
REM 5. LANZAMIENTO
REM ---------------------------------------------------------
:Launch
echo.
echo [5/6] Limpiando temporales...
rd /s /q "%TEMP_DIR%" 2>nul

echo.
echo [6/6] Abriendo Launcher...
echo      - Instancia: %INSTALL_DIR%

REM Iniciar SKLauncher apuntando al directorio de trabajo correcto
start "" "%INSTALL_DIR%\%LAUNCHER_FILE%" --workDir "%INSTALL_DIR%"

timeout /t 3 >nul
exit