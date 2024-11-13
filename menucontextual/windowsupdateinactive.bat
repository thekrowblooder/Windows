@echo off
title Administrador de Windows Update
color 8F
echo ===================================================
echo        Administrador de Windows Update
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

echo Inhabilitando Windows Update...
echo ---------------------------------------------------

:: Detiene el servicio de Windows Update
net stop wuauserv >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Servicio Windows Update detenido.
) else (
    echo [!] No se pudo detener el servicio. Puede que ya este detenido.
)

:: Cambia el tipo de inicio del servicio de Windows Update a deshabilitado
sc config wuauserv start= disabled >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Windows Update configurado como deshabilitado.
) else (
    echo [!] Error al configurar Windows Update como deshabilitado.
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
