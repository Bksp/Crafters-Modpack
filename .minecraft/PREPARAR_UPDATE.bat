@echo off
setlocal EnableDelayedExpansion
title CRAFTERS DEV TOOL
color 0b
cls

echo ========================================================
echo    HERRAMIENTA DE DESARROLLO - CRAFTERS MODPACK
echo ========================================================
echo.
echo [ MODO DESARROLLADOR: PREPARACION DE DESPLIEGUE ]
echo.

:: 1. DETECTAR CAMBIOS EN MODS
echo [1/5] Escaneando carpeta de mods (CurseForge)...
call .\packwiz.exe curseforge detect
echo.

:: 2. REFRESCAR INDICES (HASHES)
echo [2/5] Actualizando indices de Packwiz...
call .\packwiz.exe refresh
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Algo fallo al refrescar. Revisa la consola.
    pause
    exit /b
)

:: 3. INCREMENTAR VERSION
echo [3/5] Incrementando version en pack.toml...
set "psFile=%temp%\bump_ver_%random%.ps1"
(
echo $c = Get-Content pack.toml; $p = 'version = "(\d+)\.(\d+)\.(\d+)"'
echo $m = [regex]::Match($c, $p^)
echo if ^($m.Success^) {
echo      $v = "$($m.Groups[1]).$($m.Groups[2]).$([int]$m.Groups[3].Value+1)"
echo      $c -replace $p, "version = `"$v`"" ^| Set-Content pack.toml; Write-Host $v
echo } else { Write-Host "ERR" }
) > "%psFile%"

for /f "usebackq delims=" %%v in (`powershell -Noprofile -ExecutionPolicy Bypass -File "%psFile%"`) do set "NEW_VER=%%v"
del "%psFile%"

:: 4. CONFIGURAR EXCLUSIONES (NUEVO PASO CRITICO)
echo [4/5] Configurando .packwizignore...
(
    echo Exports/
    echo packwiz.exe
    echo *.bat
    echo *.ps1
    echo .git/
    echo .github/
) > .packwizignore

:: Refrescar una ultima vez para asegurar que packwiz lea el ignore
call .\packwiz.exe refresh >nul

:: 5. EXPORTAR A ZIP
echo [5/5] Generando archivo ZIP de la version %NEW_VER%...
if not exist "Exports" mkdir "Exports"
call .\packwiz.exe curseforge export --output "Exports\Crafters_Modpack_v%NEW_VER%.zip"

echo.
echo ========================================================
echo    PROCESO COMPLETADO
echo    Nueva Version: %NEW_VER%
echo    Zip Generado:  Exports\Crafters_Modpack_v%NEW_VER%.zip
echo ========================================================
echo.
echo    Pasos siguientes:
echo    1. Sube los cambios a GitHub (Push).
echo    2. El ZIP limpio esta en la carpeta "Exports".
echo.
pause