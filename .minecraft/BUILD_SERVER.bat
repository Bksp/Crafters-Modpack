@echo off
title SEPARANDO CLIENTE Y SERVIDOR
echo.
echo [!] Marcando mods que CRASHEAN servidores como "Client Side"...
echo.

:: Ejecutar script de Powershell para ajustar los mods a Client-Side
powershell -ExecutionPolicy Bypass -File ".\set_client_side.ps1"

:: --- CONFIRMACION ---
echo.
echo [OK] Configuracion aplicada.
echo Ahora Packwiz sabe que estos mods NO deben ir al servidor.
pause