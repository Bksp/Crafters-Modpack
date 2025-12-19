
# Script para marcar mods como Client-Side en packwiz
# Este script busca los archivos .pw.toml de los mods listados y cambia 'side = "both"' o 'server' a 'side = "client"'

Param(
    [string]$ModsPath = ".\mods"
)

$targetMods = @(
    "oculus",
    "embeddium",
    "entityculling",
    "effective",
    "3dskinlayers",
    "skinlayers3d",
    "notenoughanimations",
    "fallingleaves",
    "fadingnightvision",
    "xaeros-minimap",
    "xaeros-world-map",
    "jade",
    "apple-skin",
    "inventory-hud-plus",
    "better-advancements",
    "light-overlay",
    "visual-keybinder",
    "toast-control",
    "controllable",
    "mouse-tweaks",
    "sound-physics-remastered",
    "ambient-environment"
)

Write-Host "Iniciando configuracion de mods Client-Side..." -ForegroundColor Cyan

if (-not (Test-Path $ModsPath)) {
    Write-Host "Error: No se encuentra la carpeta $ModsPath" -ForegroundColor Red
    exit 1
}

foreach ($modName in $targetMods) {
    # 1. Intentar busqueda exacta
    $foundFiles = @()
    if (Test-Path "$ModsPath\$modName.pw.toml") {
        $foundFiles += Get-Item "$ModsPath\$modName.pw.toml"
    } else {
        # 2. Intentar busqueda difusa (reemplazar guiones o buscar coincidencia parcial)
        # Convertirmos "apple-skin" en "apple*skin" y "*apple-skin*"
        $pattern1 = "*$modName*.pw.toml"
        $pattern2 = "*" + ($modName -replace "-", "*") + "*.pw.toml"
        
        $foundFiles = Get-ChildItem -Path $ModsPath -Filter "*.pw.toml" | Where-Object { 
            ($_.Name -like $pattern1) -or ($_.Name -like $pattern2)
        }
    }

    # Filtramos duplicados y procesamos
    if ($foundFiles) {
        # Tomamos solo el unique por si acaso
        $foundFiles = $foundFiles | Select-Object -Unique
        
        foreach ($file in $foundFiles) {
            $content = Get-Content $file.FullName -Raw
            
            # Verificar si ya esta en client
            if ($content -match 'side\s*=\s*"client"') {
                Write-Host "  [SKIP] $($file.Name) ya es client-side." -ForegroundColor Gray
            }
            elseif ($content -match 'side\s*=\s*"(both|server)"') {
                $newContent = $content -replace 'side\s*=\s*"(both|server)"', 'side = "client"'
                Set-Content -Path $file.FullName -Value $newContent
                Write-Host "  [OK]   $($file.Name) actualizado a client-side." -ForegroundColor Green
            }
            else {
                # Caso raro o archivo malformado
                Write-Host "  [INFO] $($file.Name) no tiene propiedad 'side' estandar. Omitiendo." -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  [WARN] No se encontro archivo .pw.toml para '$modName'" -ForegroundColor DarkYellow
    }
}

Write-Host "Proceso completado." -ForegroundColor Cyan
