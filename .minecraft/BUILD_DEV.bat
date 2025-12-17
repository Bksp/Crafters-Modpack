@echo off
setlocal EnableDelayedExpansion
title CRAFTERS DEV TOOL - PROTECCION TOTAL
color 0b
cls

echo ========================================================
echo     HERRAMIENTA DE DESARROLLO - CRAFTERS MODPACK
echo ========================================================

:: 0. FASE DE RESCATE (SEGURIDAD CRITICA)
:: Antes de que Packwiz toque nada, movemos los mods prohibidos a su bunker.
echo [0/5] Asegurando mods protegidos (Evacuacion)...

if not exist "mods_github" mkdir "mods_github"

:: Lista de mods que JAMAS deben ser tocados por curseforge detect
:: Si estan en 'mods', los movemos YA a 'mods_github'
if exist "mods\wildberries*.jar" move /Y "mods\wildberries*.jar" "mods_github\" >nul
if exist "mods\Structory*.jar" move /Y "mods\Structory*.jar" "mods_github\" >nul
if exist "mods\skinlayers3d*.jar" move /Y "mods\skinlayers3d*.jar" "mods_github\" >nul
if exist "mods\notenoughanimations*.jar" move /Y "mods\notenoughanimations*.jar" "mods_github\" >nul
if exist "mods\capybaramod*.jar" move /Y "mods\capybaramod*.jar" "mods_github\" >nul
if exist "mods\hexerei*.jar" move /Y "mods\hexerei*.jar" "mods_github\" >nul
if exist "mods\entityculling*.jar" move /Y "mods\entityculling*.jar" "mods_github\" >nul

:: Tambien borramos cualquier .toml basura que haya quedado en mods_github
if exist "mods_github\*.toml" del /q "mods_github\*.toml"

echo      - Mods asegurados en la carpeta segura.
echo.

:: 1. DETECTAR CAMBIOS (Ahora es seguro)
echo [1/5] Escaneando carpeta de mods (Solo mods normales)...
:: Como ya sacamos los archivos, Packwiz NO los encontrara y NO creara tomls
call .\packwiz.exe curseforge detect
echo.

:: 2. LIMPIEZA DE RESOURCES (Por si acaso)
echo [2/5] Limpiando metadatos de recursos...
if exist "resourcepacks\*.toml" del /q "resourcepacks\*.toml"
if exist "shaderpacks\*.toml" del /q "shaderpacks\*.toml"

:: 3. REFRESCAR INDICES
echo [3/5] Calculando Hashes (Indexando)...
:: Packwiz leera 'mods' (Curseforge) y 'mods_github' (Local)
call .\packwiz.exe refresh
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Fallo el refresh.
    pause
    exit /b
)

:: 4. AUTO-VERSIONADO
echo [4/5] Incrementando version...
set "psFile=%temp%\bump_ver_%random%.ps1"
(
echo $c = Get-Content pack.toml; $p = 'version = "(\d+)\.(\d+)\.(\d+)"'
echo $m = [regex]::Match($c, $p^)
echo if ^($m.Success^) {
echo       $v = "$($m.Groups[1]).$($m.Groups[2]).$([int]$m.Groups[3].Value+1)"
echo       $c -replace $p, "version = `"$v`"" ^| Set-Content pack.toml; Write-Host $v
echo } else { Write-Host "ERR" }
) > "%psFile%"
for /f "usebackq delims=" %%v in (`powershell -Noprofile -ExecutionPolicy Bypass -File "%psFile%"`) do set "NEW_VER=%%v"
del "%psFile%"

:: 5. SUBIDA
echo.
echo ========================================================
echo     TODO LISTO. VERSION: %NEW_VER%
echo ========================================================
echo.
echo     Haz: git add .
echo     Haz: git commit -m "Update v%NEW_VER%"
echo     Haz: git push
echo.
pause