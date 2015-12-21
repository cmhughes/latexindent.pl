@echo off
goto check_Permissions

:check_Permissions
   net session >nul 2>&1
    if NOT %errorLevel% == 0 (
        echo ######## ########  ########   #######  ########  
	    echo ##       ##     ## ##     ## ##     ## ##     ## 
	    echo ##       ##     ## ##     ## ##     ## ##     ## 
	    echo ######   ########  ########  ##     ## ########  
	    echo ##       ##   ##   ##   ##   ##     ## ##   ##   
	    echo ##       ##    ##  ##    ##  ##     ## ##    ##  
	    echo ######## ##     ## ##     ##  #######  ##     ## 
	    echo.
	    echo.
	    echo ####### ERROR: ADMINISTRATOR PRIVILEGES REQUIRED #########
	    echo This script must be run as administrator to work properly!  
	    echo If you're seeing this after clicking on a start menu icon, then right click on the shortcut and select "Run As Administrator".
	    echo.
	    PAUSE
	    EXIT /B 1
    )

SET CURRENTDIR=%~dp0

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f /v Path /t REG_EXPAND_SZ /d "%Path%%CURRENTDIR%

echo Install successfull!

PAUSE         