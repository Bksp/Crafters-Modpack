@echo off
title CRAFTERS DEV TOOL - MODO SEPARADO
cd /d "%~dp0"
color 0b
cls

echo ========================================================
echo     HERRAMIENTA DE DESARROLLO - MODS SEPARADOS
echo ========================================================

:: 1. DETECCION (CurseForge)
echo [1/4] Detectando mods de CurseForge...
:: Packwiz es metiche y va a querer escanear mods_github tambien.
packwiz.exe curseforge detect

:: 2. LIMPIEZA QUIRURGICA (La clave de tu solicitud)
echo [2/4] Limpiando rastros de CurseForge en mods_github...
:: Si Packwiz creo un .toml en tu carpeta privada, LO MATAMOS.
if exist "mods_github\*.toml" (
    del /q "mods_github\*.toml"
    echo      - Se eliminaron configs basura de mods_github.
)

:: Tambien limpiamos shaders y resources por seguridad
if exist "resourcepacks\*.toml" del /q "resourcepacks\*.toml"
if exist "shaderpacks\*.toml" del /q "shaderpacks\*.toml"

:: 3. REFRESH (Hashing Local)
echo [3/4] Generando indices (Hashing)...
:: Ahora Packwiz vera los archivos de mods_github y, como no tienen .toml,
:: calculara su hash para bajarlos desde tu Repo.
packwiz.exe refresh

:: 4. VERSIONADO RAPIDO
echo [4/4] Subiendo version...
powershell -Command "$c = Get-Content pack.toml; $c -replace 'version = \"(\d+\.\d+\.)(\d+)\"', { $m = $args[0]; $v = [int]$m.Groups[2].Value + 1; 'version = \"' + $m.Groups[1].Value + $v + '\"' } | Set-Content pack.toml"

echo.
echo ========================================================
echo     LISTO.
echo     1. Los mods de CurseForge estan en 'mods'
echo     2. Tus mods estan seguros en 'mods_github'
echo ========================================================
echo.
echo     Ejecuta: git add .  /  git commit -m "Update"  /  git push
pause