@echo off
title Eliminador de Entrada de Registro
color 8F
echo ===================================================
echo          Eliminando entrada de registro
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

echo Eliminando la clave de registro 'TheKrowBlooder' del menú contextual...
echo ------------------------------------------------------------

:: Elimina la clave de registro asociada al menú contextual
REG DELETE "HKEY_CLASSES_ROOT\Directory\Background\shell\TheKrowBlooder" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Entrada de registro eliminada correctamente.
) else (
    echo [!] No se pudo eliminar la entrada de registro o no se encontró.
)

echo ------------------------------------------------------------
echo Operación completada.
echo ===================================================

REM Limpiar la pantalla al finalizar y mostrar mensaje de cierre
cls
echo ===================================================
echo                Operación Finalizada
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
