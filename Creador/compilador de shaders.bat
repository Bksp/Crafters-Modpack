@echo off
title DEPLOY SHADER + TXT
cd /d "%~dp0"
color 0b
cls

echo ========================================================
echo   ENVIANDO SHADER Y TXT AL GIT
echo ========================================================

:: --- 1. CONFIGURACION ---

set "NOMBRE_CARPETA=BSL_v8.4"
set "NOMBRE_TXT=BSL_v8.4.txt"
set "RUTA_GIT=C:\Users\LOGAN\OneDrive\Documentos\GIT\Crafters-Modpack\.minecraft\shaderpacks"
set "NOMBRE_FINAL_ZIP=BSL_v8.4-Modded-by-Bksp.zip"
set "NOMBRE_FINAL_TXT=BSL_v8.4-Modded-by-Bksp.zip.txt"

:: --- 2. DEFINIR RUTAS ABSOLUTAS ---
set "RUTA_BASE=%~dp0"
set "PATH_CARPETA_SHADER=%RUTA_BASE%%NOMBRE_CARPETA%"
set "PATH_TXT_ORIGINAL=%RUTA_BASE%%NOMBRE_TXT%"
set "PATH_DESTINO_ZIP=%RUTA_GIT%\%NOMBRE_FINAL_ZIP%"
set "PATH_DESTINO_TXT=%RUTA_GIT%\%NOMBRE_FINAL_TXT%"

:: --- 3. VALIDACIONES ---
if not exist "%PATH_CARPETA_SHADER%" (
    color 0c
    echo [ERROR] No encuentro la carpeta del shader:
    echo "%PATH_CARPETA_SHADER%"
    pause
    exit
)

if not exist "%RUTA_GIT%" (
    color 0c
    echo [ERROR] No encuentro la ruta del GIT:
    echo "%RUTA_GIT%"
    pause
    exit
)

:: --- 4. PROCESO ZIP (ENTRANDO A LA CARPETA) ---
echo.
echo [1/3] Comprimiendo Shader (Estructura plana)...
echo       Fuente: %NOMBRE_CARPETA%

:: Borrar zip anterior en el GIT
if exist "%PATH_DESTINO_ZIP%" del /f /q "%PATH_DESTINO_ZIP%"

:: Entramos a la carpeta para comprimir el contenido (*)
:: IMPORTANTE: Usamos TAR nativo de Windows (mas compatible con Java/Oculus que PowerShell)
cd "%PATH_CARPETA_SHADER%"
tar -a -c -f "%PATH_DESTINO_ZIP%" *

:: Volvemos a la base
cd /d "%RUTA_BASE%"

if not exist "%PATH_DESTINO_ZIP%" (
    color 0c
    echo [ERROR] Fallo la compresion.
    pause
    exit
)

:: --- 5. PROCESO TXT (COPIADO SIMPLE) ---
echo.
echo [2/3] Procesando archivo de texto...

if exist "%PATH_TXT_ORIGINAL%" (
    copy /Y "%PATH_TXT_ORIGINAL%" "%PATH_DESTINO_TXT%" >nul
    echo       Copiado: %NOMBRE_TXT% 
    echo       --> %NOMBRE_FINAL_TXT%
) else (
    color 0e
    echo [ALERTA] No encontre el archivo "%NOMBRE_TXT%" junto al bat.
    echo Se omitio la copia del texto.
)

:: --- FIN ---
color 0a
echo.
echo ========================================================
echo   [EXITO] SHADER Y TXT ACTUALIZADOS
echo ========================================================
echo   Archivos en GIT:
echo   1. %NOMBRE_FINAL_ZIP%
echo   2. %NOMBRE_FINAL_TXT%
echo.
pause