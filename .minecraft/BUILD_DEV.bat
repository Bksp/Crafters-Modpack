@echo off
setlocal EnableDelayedExpansion
title CRAFTERS DEV TOOL - FINAL
color 0b
cls

echo ========================================================
echo     HERRAMIENTA DE DESARROLLO (ESTRUCTURA .MINECRAFT)
echo ========================================================

:: 1. DETECCION AUTOMATICA (CurseForge)
echo [1/4] Detectando mods de CurseForge...
call .\packwiz.exe curseforge detect
echo.

:: 2. APLICAR EXCEPCIONES (Forzar GitHub)
echo [2/4] Configurando mods locales (GitHub)...

:: Borra los .toml de los mods que dan problemas para que usen el .jar local
if exist "mods\wildberries*.toml" del /q "mods\wildberries*.toml"
if exist "mods\Structory*.toml" del /q "mods\Structory*.toml"
if exist "mods\skinlayers3d*.toml" del /q "mods\skinlayers3d*.toml"
if exist "mods\notenoughanimations*.toml" del /q "mods\notenoughanimations*.toml"
if exist "mods\capybaramod*.toml" del /q "mods\capybaramod*.toml"
if exist "mods\hexerei*.toml" del /q "mods\hexerei*.toml"
if exist "mods\entityculling*.toml" del /q "mods\entityculling*.toml"

:: Limpieza de Resources y Shaders
if exist "resourcepacks\*.toml" del /q "resourcepacks\*.toml"
if exist "shaderpacks\*.toml" del /q "shaderpacks\*.toml"

echo      - Excepciones listas.

:: 3. REFRESCAR INDICES
echo [3/4] Actualizando hashes...
call .\packwiz.exe refresh

:: 4. VERSIONADO
echo [4/4] Subiendo version...
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

echo.
echo ========================================================
echo     TODO LISTO PARA GIT - Version: %NEW_VER%
echo ========================================================
echo.
pause