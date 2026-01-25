#!/bin/bash

# ========================================================
#   CRAFTERS MODPACK - SOLO LANZAR
# ========================================================

MODPACK_NAME=".minecraft-1.20.1-crafters"
TARGET_DIR="$HOME/$MODPACK_NAME"
LAUNCHER_FILE="SKlauncher.jar"
LAUNCHER_EXE="$TARGET_DIR/$LAUNCHER_FILE"

# Colores
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ ! -f "$LAUNCHER_EXE" ]; then
    echo -e "${RED}[ERROR] No se encuntra el launcher en: $LAUNCHER_EXE${NC}"
    echo "Por favor, ejecuta install.sh primero para instalarlo."
    read -p "Presiona Enter para salir..."
    exit 1
fi

echo "Ejecutando SKLauncher desde Directorio Objetivo..."
cd "$TARGET_DIR" || exit
java -jar "$LAUNCHER_EXE" --workDir "$TARGET_DIR"
