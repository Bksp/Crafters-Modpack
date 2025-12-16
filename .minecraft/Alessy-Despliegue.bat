@echo off
setlocal EnableDelayedExpansion
title AUTOMATIZADOR DE MODPACK - MODO DEV V2
color 0b
cls

echo ========================================================
echo   INICIANDO SECUENCIA DE DESPLIEGUE AUTOMATICO V2
echo ========================================================
echo.

:: 1. DETECTAR Y REFRESCAR PACKWIZ
echo [1/5] Detectando nuevos mods (CurseForge)...
:: El comando detect a veces falla si el mod no esta en CF, permitimos que falle y continue.
call .\packwiz.exe curseforge detect
echo.

echo [Refrescando indices...]
call .\packwiz.exe refresh
if %errorlevel% neq 0 (
    color 0c
    echo [ERROR CRITICO] Fallo al hacer 'packwiz refresh'. Revisa errores arriba.
    pause
    exit /b
)

:: 2. INCREMENTAR VERSION (Metodo Archivo Temporal Seguro)
echo [2/5] Incrementando version en pack.toml...

set "psFile=%temp%\bump_version_%random%.ps1"

:: Escribimos el script de PowerShell en un archivo temporal para evitar errores de sintaxis en CMD
(
echo $path = 'pack.toml'
echo $content = Get-Content $path
echo $pattern = 'version = "(\d+)\.(\d+)\.(\d+)"'
echo $match = [regex]::Match($content, $pattern^)
echo if ^($match.Success^) {
echo     $major = $match.Groups[1].Value
echo     $minor = $match.Groups[2].Value
echo     $patch = [int]$match.Groups[3].Value + 1
echo     $newVer = "$major.$minor.$patch"
echo     $content -replace $pattern, "version = `"$newVer`"" ^| Set-Content $path
echo     Write-Output $newVer
echo } else {
echo     Write-Output "ERROR_PATTERN"
echo }
) > "%psFile%"

:: Ejecutamos el archivo temporal y capturamos la salida
for /f "usebackq delims=" %%v in (`powershell -Noprofile -ExecutionPolicy Bypass -File "%psFile%"`) do set "NEW_VERSION=%%v"

:: Borramos el archivo temporal
del "%psFile%"

:: Verificamos si funciono
if "%NEW_VERSION%"=="ERROR_PATTERN" (
    color 0c
    echo [ERROR] No pude encontrar la linea de version en pack.toml.
    echo Asegurate de que tenga el formato: version = "1.0.0"
    pause
    exit /b
)

echo       Nueva version establecida: %NEW_VERSION%

:: 3. REFRESCAR OTRA VEZ (Para incluir el cambio de version en el hash)
call .\packwiz.exe refresh >nul

:: 4. SUBIR A GITHUB
echo [3/5] Subiendo cambios a GitHub...
git add .
git commit -m "Auto-deploy version %NEW_VERSION%"
git push origin main

:: 5. EXPORTAR ZIP
echo [4/5] Generando ZIP de instalacion...
call .\packwiz.exe curseforge export
if %errorlevel% neq 0 (
    color 0c
    echo [ERROR] Fallo al exportar el ZIP.
    pause
    exit /b
)

echo.
echo ========================================================
echo   DESPLIEGUE FINALIZADO EXITOSAMENTE
echo   Version: %NEW_VERSION%
echo   GitHub:  Sincronizado
echo   ZIP:     Generado
echo ========================================================
echo.
pause