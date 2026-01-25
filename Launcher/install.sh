#!/bin/bash

# ========================================================
#   CRAFTERS MODPACK - CLIENTE (LINUX)
#   [Ruta: ~/.minecraft-1.20.1-crafters]
# ========================================================

# Directorios clave
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
MODPACK_NAME=".minecraft-1.20.1-crafters"
TARGET_DIR="$HOME/$MODPACK_NAME"

# URLs
RANDOM_VAL=$RANDOM
PACK_URL="https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/pack.toml?v=$RANDOM_VAL"
URL_PACKWIZ="https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
URL_SKLAUNCHER="https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/Launcher/SKlauncher.jar"
URL_CONFIG_OVERRIDES="https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/config_overrides.zip?v=$RANDOM_VAL"
URL_OPTIONS="https://raw.githubusercontent.com/Bksp/Crafters-Modpack/main/.minecraft/options.txt"

# Nombres de archivo
BOOTSTRAP_FILE="packwiz-installer-bootstrap.jar"
LAUNCHER_FILE="SKlauncher.jar"
LAUNCHER_EXE="$TARGET_DIR/$LAUNCHER_FILE"

# Colores (Opcional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/5] Preparando entorno...${NC}"
echo "     - Directorio: $TARGET_DIR"

mkdir -p "$TARGET_DIR"

# ---------------------------------------------------------
# 1. OBTENER SKLAUNCHER
# ---------------------------------------------------------
if [ -f "$SCRIPT_DIR/$LAUNCHER_FILE" ]; then
    echo -e "${YELLOW}[INFO] Copiando SKLauncher local a Directorio Destino...${NC}"
    cp "$SCRIPT_DIR/$LAUNCHER_FILE" "$LAUNCHER_EXE"
fi

if [ ! -f "$LAUNCHER_EXE" ]; then
    echo -e "${YELLOW}[AVISO] Descargando SKLauncher...${NC}"
    curl -L -o "$LAUNCHER_EXE" "$URL_SKLAUNCHER"
fi

if [ ! -f "$LAUNCHER_EXE" ]; then
    echo -e "${RED}[ERROR CRITICO] No se pudo descargar SKLauncher.${NC}"
    exit 1
fi

# ---------------------------------------------------------
# 2. ACTUALIZAR PACK (Packwiz)
# ---------------------------------------------------------
echo ""
echo -e "${GREEN}[2/5] Verificando actualizador...${NC}"
if [ ! -f "$TARGET_DIR/$BOOTSTRAP_FILE" ]; then
    echo "     - Descargando Bootstrap..."
    curl -L -o "$TARGET_DIR/$BOOTSTRAP_FILE" "$URL_PACKWIZ"
fi

echo ""
echo -e "${GREEN}[3/5] Actualizando Mods...${NC}"
cd "$TARGET_DIR" || exit
java -jar "$BOOTSTRAP_FILE" -g -s client "$PACK_URL"

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Fallo la actualizacion. Iniciando de todas formas...${NC}"
    sleep 1
fi

# ---------------------------------------------------------
# 2.5 ARREGLO MANUAL DE ARCHIVOS (Hash Fix)
# ---------------------------------------------------------
echo ""
echo -e "${YELLOW}[INFO] Descargando y aplicando configuraciones globales (Overrides)...${NC}"

curl -L -o "config_overrides.zip" "$URL_CONFIG_OVERRIDES"

# Verificar tamaño mayor a 1000 bytes aprox
FILESIZE=$(stat -c%s "config_overrides.zip" 2>/dev/null || stat -f%z "config_overrides.zip" 2>/dev/null)
if [ -n "$FILESIZE" ] && [ "$FILESIZE" -lt 1000 ]; then
   echo -e "${RED}[ERROR] El archivo descargado parece corrupto o vacio.${NC}"
   rm "config_overrides.zip"
fi

if [ -f "config_overrides.zip" ]; then
    echo "     - Limpiando configuraciones antiguas..."
    rm -rf "$TARGET_DIR/config"
    
    echo "     - Extrayendo configuraciones nuevas..."
    unzip -o "config_overrides.zip" -d "$TARGET_DIR" > /dev/null
    
    rm "config_overrides.zip"
else
    echo -e "${RED}[ALERTA] No se pudo descargar config_overrides.zip${NC}"
fi

# ---------------------------------------------------------
# 2.6 ACTUALIZAR OPTIONS.TXT
# ---------------------------------------------------------
echo ""
echo -e "${YELLOW}[INFO] Verificando options.txt...${NC}"
curl -L -o "options_new.txt" "$URL_OPTIONS"

if [ -f "options_new.txt" ]; then
    FILESIZE=$(stat -c%s "options_new.txt" 2>/dev/null || stat -f%z "options_new.txt" 2>/dev/null)
    if [ -n "$FILESIZE" ] && [ "$FILESIZE" -lt 100 ]; then
        rm "options_new.txt"
    fi
fi

if [ -f "options_new.txt" ]; then
    echo ""
    echo -e "${YELLOW}[AVISO] Se ha descargado un archivo options.txt actualizado.${NC}"
    echo "         (RECOMENDADO: S, para aplicar configuracion optima)"
    read -p "Deseas reemplazar el options.txt existente? (s/n): " OPT_CHOICE
    
    if [[ "$OPT_CHOICE" =~ ^[sS]$ ]]; then
        mv "options_new.txt" "options.txt"
        echo -e "${GREEN}[INFO] Options.txt actualizado.${NC}"
    else
        rm "options_new.txt"
        echo -e "${YELLOW}[INFO] Conservando archivo actual.${NC}"
    fi
fi

# ---------------------------------------------------------
# 4. INYECCION DE PERFIL (launcher_profiles.json)
# ---------------------------------------------------------
# SKLauncher suele gestionar esto, pero dejamos el placeholder si es necesario.

# ---------------------------------------------------------
# 5. LANZAMIENTO
# ---------------------------------------------------------
echo ""
echo -e "${GREEN}[5/5] Iniciando SKLauncher...${NC}"
echo "     - Ejecutable: $LAUNCHER_EXE"
echo "     - Directorio: $TARGET_DIR"

cd "$TARGET_DIR" || exit
java -jar "$LAUNCHER_EXE" --workDir "$TARGET_DIR"
