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

:: --- 2.1 MODS PRIVADOS (GitHub Raw) ---
echo [2.1/4] Registrando mods privados (mods_github)...
for %%f in ("mods_github\*.jar") do (
    echo      - Procesando: %%~nxf
    REM Agregamos (o actualizamos) el mod usando la URL Raw de GitHub
    REM Esto crea/actualiza el archivo .toml en la carpeta "mods"
    packwiz.exe url add "https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/mods_github/%%~nxf" --meta-folder mods --force
)

:: REFRESH FINAL: Calcula hashes de TODOS los archivos actuales
echo      - Calculando hashes...
packwiz.exe refresh

    :: --- 2.5. ZIP DE OVERRIDES (Configs manuales) ---
    echo      - Preparando archivos de override...
    if exist "temp_overrides" rd /s /q "temp_overrides"
    mkdir "temp_overrides\config"
    mkdir "temp_overrides\shaderpacks"
    
    xcopy /E /I /Y "config" "temp_overrides\config" >nul
    copy /Y "shaderpacks\*.txt" "temp_overrides\shaderpacks" >nul
    
    echo      - Comprimiendo overrides (config + shader txt)...
    powershell -Command "Compress-Archive -Path 'temp_overrides\*' -DestinationPath config_overrides.zip -Force"
    
    rd /s /q "temp_overrides"
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
