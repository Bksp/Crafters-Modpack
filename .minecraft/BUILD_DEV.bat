@echo off
title CRAFTERS BUILDER - DEV
cd /d "%~dp0"
color 0b
cls

echo ========================================================
echo   CRAFTERS MODPACK - BUILDER TOOL
echo   [Refresca indices y prepara para Commit]
echo ========================================================
echo.

:: --- 1. LIMPIEZA DE METADATOS (Forzar Local) ---
echo [1/4] Limpiando metadatos para forzar archivos locales...
:: Eliminamos .toml en carpetas que suelen tener contenido custom
:: para que packwiz los re-indexe como archivos del repo y no de Curseforge.
if exist "mods_github\*.toml" del /q "mods_github\*.toml"
if exist "shaderpacks\*.toml" del /q "shaderpacks\*.toml"
if exist "resourcepacks\*.toml" del /q "resourcepacks\*.toml"

:: --- 2. PACKWIZ REFRESH (Nucleo) ---
echo [2/4] Actualizando indices de Packwiz...

:: Detectar enlaces a CurseForge para mods normales (evita re-descargas)
packwiz.exe curseforge detect

:: REFRESH FINAL: Calcula hashes de TODOS los archivos actuales
echo      - Calculando hashes...
packwiz.exe refresh

    :: --- 2.5. ZIP DE OVERRIDES (Configs manuales) ---
    echo      - Creando config_overrides.zip (Ignorando hashes)...
    powershell -Command "Compress-Archive -Path config, shaderpacks\*.txt -DestinationPath config_overrides.zip -Force"
    if exist "config_overrides.zip" echo      - Zip generado correctamente.

if %errorlevel% neq 0 (
    color 0c
    echo [ERROR] Packwiz fallo al refrescar. Revisa la consola.
    pause
    exit /b
)

:: --- 3. EXPORTAR ZIP ---
echo [3/4] Generando ZIP de exportacion...

:: Leer version desde pack.toml
set "VERSION=UNKNOWN"
:: Buscamos la linea que contiene "version ="
for /f "tokens=2 delims==" %%a in ('findstr /c:"version =" pack.toml') do (
    set "RAW_VER=%%a"
    goto :FoundVersion
)

:FoundVersion
if defined RAW_VER (
    :: Limpiar comillas y espacios
    set "VERSION=%RAW_VER:"=%"
    set "VERSION=%VERSION: =%"
    echo      - Version detectada: [%VERSION%]
)

if not exist "Exports" mkdir "Exports"
set "ZIP_NAME=Exports\Crafters-Modpack-v%VERSION%.zip"

packwiz.exe curseforge export --output "%ZIP_NAME%"

:: --- 4. VALIDACION GIT (CRITICO) ---
color 0e
echo.
echo [4/4] VERIFICACION DE SINCRONIZACION
echo ========================================================
echo   ATENCION: Para arreglar el error "Hash invalid":
echo   1. Revisa los archivos modificados abajo via GIT.
echo   2. Debes hacer COMMIT y PUSH de TODO, especialmente:
echo      - pack.toml
echo      - index.toml
echo      - Cualquier archivo de config/shader modificado.
echo ========================================================
echo.
echo [ESTADO ACTUAL DE GIT]:
git status -s
echo.
echo ========================================================
echo SI VES ARCHIVOS ARRIBA, EJECUTA EN TU TERMINAL:
echo    git add .
echo    git commit -m "Update modpack v%VERSION%"
echo    git push
echo ========================================================
echo.
pause
exit
