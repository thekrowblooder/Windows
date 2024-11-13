@echo off
title Administrador de Windows Update
color 8F
echo ===================================================
echo           Habilitando Windows Update
echo ===================================================
echo               Creado por TheKrowBlooder
echo.

:: Verifica si el script se esta ejecutando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -Command "Start-Process '%~0' -Verb runAs"
    exit /b
)

echo Configurando Windows Update para inicio automatico...
echo ---------------------------------------------------

:: Configura el servicio de Windows Update para que se inicie automaticamente
sc config wuauserv start= auto >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Configurado para inicio automatico.
) else (
    echo [!] Error al configurar el inicio automatico.
)

:: Inicia el servicio de Windows Update
net start wuauserv >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Servicio de Windows Update iniciado.
) else (
    echo [!] Error al iniciar el servicio. Puede que ya este en ejecucion.
)

:: Abre la ventana de Windows Update para buscar actualizaciones
start ms-settings:windowsupdate >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Interfaz de Windows Update abierta.
) else (
    echo [!] Error al abrir la interfaz de Windows Update.
)

echo ---------------------------------------------------
echo Operacion completada.
echo ===================================================

REM Limpiar la pantalla al finalizar y mostrar mensaje de cierre
cls
echo ===================================================
echo                Operacion Finalizada
echo ===================================================
echo Siguenos en YouTube para mas contenido y guias utiles.
echo     Presiona [Enter] para ir a mi canal de YouTube
echo     https://www.youtube.com/@TheKrowBlooder
echo     O presiona cualquier otra tecla para salir.
echo ===================================================
set /p "input=Presiona Enter para ir a mi canal de YouTube o cualquier otra tecla para salir"

if "%input%"=="" (
    start https://www.youtube.com/@TheKrowBlooder
)

exit
