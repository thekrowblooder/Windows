@echo off
title Restablecer Efectos Visuales
color 8F
echo ===================================================
echo     Restableciendo Efectos Visuales de Windows
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

echo Restableciendo efectos visuales a valores predeterminados...
echo ---------------------------------------------------

:: Habilitar los efectos visuales
reg add "HKCU\Control Panel\Desktop" /v "VisualFXSetting" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_DWORD /d 400 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9e 3e 07 80 12 00 00 00" /f >nul 2>&1

:: Activar animaciones en la interfaz
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFX" /t REG_DWORD /d 1 /f >nul 2>&1

:: Habilitar efectos de transparencia y Aero
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "AeroGlass" /t REG_DWORD /d 1 /f >nul 2>&1

echo ---------------------------------------------------
echo Los efectos visuales han sido restaurados a los valores predeterminados.
echo ===================================================

:: Reiniciar el explorador de Windows para aplicar los cambios
echo Reiniciando el explorador de Windows...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo ---------------------------------------------------
echo El explorador de Windows se ha reiniciado.
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
set /p "input=Presiona Enter para ir a mi canal de YouTube o cualquier otra tecla para salir: "

if "%input%"=="" (
    start https://www.youtube.com/@TheKrowBlooder
)

exit
