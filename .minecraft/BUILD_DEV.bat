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

:: LIMPIEZA TOTAL: Borramos metadatos antiguos de mods para regenerarlos desde cero
:: Esto evita los duplicados (ej. bountiful.pw.toml vs bountiful-ver.pw.toml)
if exist "mods\*.pw.toml" del /q "mods\*.pw.toml"

:: LIMPIEZA PRIVADOS: Eliminar jars privados de mods/ para que "detect" los ignore
for %%f in ("mods_github\*.jar") do (
    if exist "mods\%%~nxf" del /q "mods\%%~nxf"
)

:: Detectar enlaces a CurseForge para mods normales (evita re-descargas)
:: Solo detectara los jars que quedaron (los publicos) y creara sus .pw.toml
packwiz.exe curseforge detect

:: --- 2.1 MODS PRIVADOS (GitHub Raw) ---
echo [2.1/4] Registrando mods privados (mods_github)...

:: Generar Timestamp para evitar cache de GitHub Raw
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "TIMESTAMP=%datetime:~0,14%"

for %%f in ("mods_github\*.jar") do (
    echo      - Procesando: %%~nxf
    
    :: 1. Copiar a carpeta mods (CRITICO: Para que packwiz calcule el hash del archivo REAL)
    copy /Y "%%f" "mods\%%~nxf" >nul

    :: 2. Agregar a packwiz con parametro de version para romper cache
    :: Sintaxis: packwiz url add [Nombre] [URL]
    packwiz.exe url add "%%~nxf" "https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/mods_github/%%~nxf?v=%TIMESTAMP%" --meta-folder mods --force
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
    if exist "shaderpacks\*.txt" copy /Y "shaderpacks\*.txt" "temp_overrides\shaderpacks" >nul
    
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



:: --- 3. VALIDACION GIT (CRITICO) ---
color 0e
echo.
echo [3/3] VERIFICACION DE SINCRONIZACION
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
pause
exit
