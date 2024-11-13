@echo off
title Mantenimiento de Red y Limpieza de Sistema
color 8F
echo ===================================================
echo     Mantenimiento de Red y Limpieza de Sistema
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

echo Realizando mantenimiento de red y limpieza de sistema...
echo ---------------------------------------------------

REM === Mantenimiento de red ===

REM Vaciar la cache de DNS
ipconfig /flushdns >nul 2>&1
echo [OK] Cache DNS vaciada.

REM Liberar direccion IP actual
ipconfig /release >nul 2>&1
echo [OK] Direccion IP liberada.

REM Renovar direccion IP
ipconfig /renew >nul 2>&1
echo [OK] Direccion IP renovada.

REM Restablecer la cache de resolucion de NetBIOS
nbtstat -R >nul 2>&1
echo [OK] Cache de NetBIOS restablecida.

REM Forzar la actualizacion de nombres NetBIOS y su cache
nbtstat -RR >nul 2>&1
echo [OK] Tabla de nombres NetBIOS y cache actualizadas.

REM Restablecer el stack TCP/IP (requiere reinicio)
netsh int ip reset >nul 2>&1
echo [OK] Stack TCP/IP restablecido. Es posible que se requiera reiniciar.

REM Restablecer configuracion de Winsock
netsh winsock reset >nul 2>&1
echo [OK] Winsock restablecido. Es posible que se requiera reiniciar.

echo ---------------------------------------------------
echo Mantenimiento de red completado.
echo.

REM === Limpieza de actualizaciones de Windows y carpetas temporales ===
echo Iniciando limpieza de actualizaciones y archivos temporales...
echo ---------------------------------------------------

REM Detener servicios de Windows Update
net stop wuauserv >nul 2>&1
net stop UsoSvc >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1
echo [OK] Servicios de Windows Update detenidos.

REM Eliminar y recrear la carpeta SoftwareDistribution
rd /s /q C:\Windows\SoftwareDistribution >nul 2>&1
md C:\Windows\SoftwareDistribution >nul 2>&1
echo [OK] Carpeta SoftwareDistribution limpiada.

REM Limpieza de carpetas temporales del sistema
rd /s /q %temp% >nul 2>&1
mkdir %temp% >nul 2>&1
takeown /f "%temp%" /r /d y >nul 2>&1
takeown /f "C:\Windows\Temp" /r /d y >nul 2>&1
rd /s /q C:\Windows\Temp >nul 2>&1
mkdir C:\Windows\Temp >nul 2>&1
echo [OK] Carpetas temporales de Windows limpiadas.

REM Limpieza de archivos temporales del usuario y sistema
del /s /q "%TMP%\*.*" >nul 2>&1
del /s /q "%TEMP%\*.*" >nul 2>&1
del /s /q "%WINDIR%\Temp\*.*" >nul 2>&1
del /s /q "%USERPROFILE%\Local Settings\Temp\*.*" >nul 2>&1
del /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
echo [OK] Archivos temporales del usuario y sistema eliminados.

echo ---------------------------------------------------
echo Limpieza de sistema completada.
echo ===================================================
echo Mantenimiento y limpieza finalizados.
echo ===================================================

REM Limpiar la pantalla al finalizar y mostrar mensaje de cierre
cls
echo ===================================================
echo                Mantenimiento Finalizado
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
