@echo off
setlocal EnableDelayedExpansion
title CRAFTERS DEV TOOL - ACTUALIZADO
color 0b
cls

echo ========================================================
echo     HERRAMIENTA DE DESARROLLO - CRAFTERS MODPACK
echo ========================================================
echo.

:: 1. DETECTAR CAMBIOS EN MODS (AUTO-ASOCIAR LOS NUEVOS)
echo [1/6] Escaneando carpeta de mods (CurseForge)...
call .\packwiz.exe curseforge detect
echo.

:: 2. LIMPIEZA DE "FORZADOS A GITHUB" (EL TRUCO)
:: Aqui borramos los .pw.toml de los mods que QUEREMOS que sean locales.
:: Al no tener .toml, packwiz los subira al index como archivos directos.
echo [2/6] Aplicando excepciones (Forzando carga desde GitHub)...

:: --- LISTA NEGRA DE MODS (Solo borramos sus .toml) ---
if exist "mods\wildberries*.toml" del "mods\wildberries*.toml"
if exist "mods\Structory*.toml" del "mods\Structory*.toml"
if exist "mods\skinlayers3d*.toml" del "mods\skinlayers3d*.toml"
if exist "mods\notenoughanimations*.toml" del "mods\notenoughanimations*.toml"
if exist "mods\capybaramod*.toml" del "mods\capybaramod*.toml"
if exist "mods\hexerei*.toml" del "mods\hexerei*.toml"
if exist "mods\entityculling*.toml" del "mods\entityculling*.toml"

:: --- LIMPIEZA DE RESOURCES Y SHADERS ---
:: Packwiz no suele generar tomls aqui solo, pero por seguridad borramos cualquier rastro
if exist "resourcepacks\*.toml" del "resourcepacks\*.toml"
if exist "shaderpacks\*.toml" del "shaderpacks\*.toml"

echo        - Excepciones aplicadas.

:: 3. REFRESCAR INDICES (HASHES REALES)
echo [3/6] Recalculando hashes (Refresh)...
call .\packwiz.exe refresh
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Fallo al refrescar. Revisa si hay errores de sintaxis.
    pause
    exit /b
)

:: 4. INCREMENTAR VERSION
echo [4/6] Incrementando version en pack.toml...
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

:: 5. GENERAR IGNORADOS
echo [5/6] Actualizando .packwizignore...
(
    echo Exports/
    echo packwiz.exe
    echo *.bat
    echo *.ps1
    echo .git/
    echo .github/
    echo .gitattributes
) > .packwizignore
:: Refresh rapido para aplicar el ignore
call .\packwiz.exe refresh >nul

:: 6. EXPORTAR (OPCIONAL SI USAS GITHUB DIRECO)
echo [6/6] Generando ZIP de respaldo...
if not exist "Exports" mkdir "Exports"
call .\packwiz.exe curseforge export --output "Exports\Crafters_Modpack_v%NEW_VER%.zip" >nul

echo.
echo ========================================================
echo     LISTO PARA SUBIR A GITHUB
echo     Version: %NEW_VER%
echo ========================================================
echo.
echo     RECUERDA:
echo     1. Haz: git add .
echo     2. Haz: git commit -m "Update v%NEW_VER%"
echo     3. Haz: git push
echo.
pause