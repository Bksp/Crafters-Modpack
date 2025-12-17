@echo off
title CRAFTERS BUILDER - ADMIN
cd /d "%~dp0"
color 0b
cls

echo ========================================================
echo   CRAFTERS MODPACK - BUILDER ^& EXPORT
echo   [Logica: Refresh - Detect - Clean - Export]
echo ========================================================
echo.

:: --- 1. REFRESH INICIAL (Detectar Cambios) ---
echo [1/5] Registrando nuevos archivos (Refresh Inicial)...
:: Esto mete los nuevos .jar al indice temporalmente
packwiz.exe refresh

:: --- 2. DETECCION CURSEFORGE (Asociaciones) ---
echo [2/5] Buscando asociaciones en CurseForge...
:: Packwiz escanea los archivos registrados para ver si existen en la nube
packwiz.exe curseforge detect

:: --- 3. LIMPIEZA DE SEGURIDAD (Sanitizacion) ---
echo [3/5] Limpiando carpetas privadas (mods_github)...
:: Borramos los .toml generados erroneamente en tus carpetas locales
if exist "mods_github\*.toml" del /q "mods_github\*.toml"
if exist "shaderpacks\*.toml" del /q "shaderpacks\*.toml"
if exist "resourcepacks\*.toml" del /q "resourcepacks\*.toml"

:: --- 4. REFRESH FINAL (Aplicar Cambios) ---
echo [4/5] Actualizando indices finales (Refresh Final)...
:: OBLIGATORIO: Ahora que borramos .tomls y creamos otros, 
:: debemos actualizar el indice para el export.
packwiz.exe refresh

if %errorlevel% neq 0 (
    color 0c
    echo.
    echo [ERROR] El refresh final fallo. Revisa el pack.toml.
    pause
    exit /b
)

:: --- 5. EXPORTAR ZIP ---
echo [5/5] Exportando version final...

:: Leer version
for /f "tokens=2 delims==" %%a in ('findstr "version" pack.toml') do set "RAW_VER=%%a"
set "VERSION=%RAW_VER:"=%"
set "VERSION=%VERSION: =%"

if not exist "Exports" mkdir "Exports"
set "ZIP_NAME=Exports\Crafters-Modpack-v%VERSION%.zip"

packwiz.exe curseforge export --output "%ZIP_NAME%"

if %errorlevel% equ 0 (
    color 0a
    echo.
    echo ========================================================
    echo   BUILD EXITOSO
    echo ========================================================
    echo   Archivo: %ZIP_NAME%
) else (
    color 0c
    echo [ERROR] Fallo la exportacion.
)

echo.
pause