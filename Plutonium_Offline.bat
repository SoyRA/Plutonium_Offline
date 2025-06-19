:: ============================================================================
:: @title        Plutonium Offline Launcher
:: @description  Permite lanzar distintos juegos de Call of Duty compatibles con Plutonium en modo offline.
:: @author       SoyRA
:: @encoding     UTF-8
:: @platform     Windows (CMD / Batch)
:: ============================================================================

:: ============================================================================
:: @section      Configuración Inicial
:: @description  Configura entorno, codificación, color y título de ventana.
:: ============================================================================

@ECHO OFF
CHCP 65001 > NUL
COLOR 07
TITLE Plutonium Offline Launcher
SETLOCAL ENABLEEXTENSIONS
CD /D "%~dp0" || PAUSE && EXIT /B

:: ============================================================================
:: @section      Variables personalizables
:: @description  Variables que el usuario puede editar a gusto.
:: ============================================================================

:: Tu nombre dentro del juego
SET PLAYER_NAME=Unknown Soldier

:: Tu ruta de instalación de cada juego
SET T4_GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty World at War
SET T5_GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops
SET IW5_GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare 3
SET T6_GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops II

:: Parámetros de lanzamiento para el juego
SET LAUNCH_PARAMETERS=

:: Activar (1) o Desactivar (0) el modo portable
SET PORTABLE_MODE=1

:: Activar (1) o Desactivar (0) la comprobación de actualizaciones de Plutonium
SET CHECK_FOR_UPDATES=1

:: ============================================================================
:: @section      Variables internas
:: @description  Variables que el usuario no debe modificar.
:: ============================================================================

SET PLUTONIUM_UPDATER_EXE=plutonium.exe
SET PLUTONIUM_BOOTSTRAPPER_EXE=plutonium-bootstrapper-win32.exe

:: ============================================================================
:: @section      Flujo principal
:: @description  Llama a subrutinas principales en orden lógico.
:: ============================================================================

CALL :get_plutonium_updater_path
CALL :get_plutonium_bootstrapper_path
CALL :check_updates
CALL :get_current_game
CALL :show_menu
EXIT /B

:: ============================================================================
:: @subroutine   get_plutonium_updater_path
:: @description  Detecta la ubicación del actualizador de Plutonium.
:: @returns      PLUTONIUM_UPDATER_PATH
:: ============================================================================

:get_plutonium_updater_path
    IF EXIST "%PLUTONIUM_UPDATER_EXE%" (
        SET PLUTONIUM_UPDATER_PATH=%CD%
        GOTO :EOF
    )

    IF EXIST "%LOCALAPPDATA%\Plutonium\%PLUTONIUM_UPDATER_EXE%" (
        SET PLUTONIUM_UPDATER_PATH=%LOCALAPPDATA%\Plutonium
        GOTO :EOF
    )

    CLS
    COLOR 06
    ECHO No se encontró %PLUTONIUM_UPDATER_EXE%, se asume que lo tenés en otro lugar y ya lo ejecutaste al menos una vez.
    ECHO Caso contrario ¿Cómo querés jugar en Plutonium si nunca lo instalaste?
    ECHO.
    CHOICE /C SN /N /M "¿Querés que lo descargue por vos, (S)í o (N)o? "

    IF %ERRORLEVEL% EQU 1 (
        CALL :download_plutonium_updater
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   get_plutonium_bootstrapper_path
:: @description  Detecta la ubicación del bootstrapper de Plutonium y por ende la ubicación de Plutonium.
:: @returns      PLUTONIUM_PATH, PLUTONIUM_BOOTSTRAPPER_PATH
:: ============================================================================

:get_plutonium_bootstrapper_path
    IF EXIST "Plutonium\bin\%PLUTONIUM_BOOTSTRAPPER_EXE%" (
        SET PLUTONIUM_PATH=%CD%\Plutonium
        SET PLUTONIUM_BOOTSTRAPPER_PATH=%CD%\Plutonium\bin
        GOTO :EOF
    )

    IF EXIST "%LOCALAPPDATA%\Plutonium\bin\%PLUTONIUM_BOOTSTRAPPER_EXE%" (
        SET PLUTONIUM_PATH=%LOCALAPPDATA%\Plutonium
        SET PLUTONIUM_BOOTSTRAPPER_PATH=%LOCALAPPDATA%\Plutonium\bin
        GOTO :EOF
    )

    CLS
    COLOR 04
    ECHO No se encontró %PLUTONIUM_BOOTSTRAPPER_EXE% ¿Cómo querés jugar en Plutonium si nunca lo instalaste?
    ECHO.
    CHOICE /C SN /N /M "¿Querés que lo instale por vos, (S)í o (N)o? "

    IF %ERRORLEVEL% EQU 1 (
        IF NOT DEFINED PLUTONIUM_UPDATER_PATH (
            ECHO ¿Y cómo querés que lo instale si no tengo %PLUTONIUM_UPDATER_EXE%? Se detendrá la ejecución...
            ECHO.
            PAUSE
            EXIT
        )
        CALL :run_plutonium_updater
        GOTO :EOF
    )

    ECHO Se detendrá la ejecución...
    ECHO.
    PAUSE
    EXIT

:: ============================================================================
:: @subroutine   set_plutonium_paths
:: @description  Establece las rutas necesarias para Plutonium según el modo portable.
::               Solo se utiliza para download_plutonium_updater y run_plutonium_updater.
:: @returns      PLUTONIUM_PATH, PLUTONIUM_UPDATER_PATH, PLUTONIUM_BOOTSTRAPPER_PATH
:: ============================================================================

:set_plutonium_paths
    IF NOT DEFINED PLUTONIUM_PATH (
        IF %PORTABLE_MODE% EQU 1 (
            SET PLUTONIUM_PATH=%CD%\Plutonium
        ) ELSE (
            SET PLUTONIUM_PATH=%LOCALAPPDATA%\Plutonium
        )
    )

    IF NOT DEFINED PLUTONIUM_UPDATER_PATH (
        IF %PORTABLE_MODE% EQU 1 (
            SET PLUTONIUM_UPDATER_PATH=%CD%
        ) ELSE (
            SET PLUTONIUM_UPDATER_PATH=%LOCALAPPDATA%\Plutonium
        )
    )

    IF NOT DEFINED PLUTONIUM_BOOTSTRAPPER_PATH (
        IF %PORTABLE_MODE% EQU 1 (
            SET PLUTONIUM_BOOTSTRAPPER_PATH=%CD%\Plutonium\bin
        ) ELSE (
            SET PLUTONIUM_BOOTSTRAPPER_PATH=%LOCALAPPDATA%\Plutonium\bin
        )
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   download_plutonium_updater
:: @description  Descarga el actualizador de Plutonium.
:: ============================================================================

:download_plutonium_updater
    CALL :set_plutonium_paths
    CLS
    COLOR 07
    ECHO Descargando %PLUTONIUM_UPDATER_EXE% en %PLUTONIUM_UPDATER_PATH%
    MKDIR "%PLUTONIUM_UPDATER_PATH%" > NUL 2>&1
    CALL curl.exe -f -L -o "%PLUTONIUM_UPDATER_PATH%\%PLUTONIUM_UPDATER_EXE%" -# "https://cdn.plutonium.pw/updater/plutonium.exe"

    IF %ERRORLEVEL% NEQ 0 (
        COLOR 04
        ECHO.
        ECHO Descarga fallida.
        ECHO Se detendrá la ejecución...
        ECHO.
        PAUSE
        EXIT
    )

    ECHO.
    ECHO Descarga finalizada.
    ECHO.
    PAUSE
    GOTO :EOF

:: ============================================================================
:: @subroutine   run_plutonium_updater
:: @description  Inicia el actualizador de Plutonium para actualizar los archivos del mismo.
:: ============================================================================

:run_plutonium_updater
    CALL :set_plutonium_paths
    CLS
    COLOR 07
    ECHO Actualizando Plutonium en %PLUTONIUM_PATH% ...
    ECHO 1. Se descargan todos los archivos necesarios de Plutonium.
    ECHO 2. Se descargan e instalan todas las librerías faltantes.
    ECHO 3. Cerrá Plutonium cuando su ventana diga "Game is up to date!".
    ECHO.
    START "Plutonium Updater" /D "%PLUTONIUM_UPDATER_PATH%" /WAIT "%PLUTONIUM_UPDATER_EXE%" -install-dir "%PLUTONIUM_PATH%" -update-only
    ECHO.
    ECHO Finalizó la actualización, si la ventana decía "Game is up to date!" entonces todo está bien.
    PAUSE
    GOTO :EOF

:: ============================================================================
:: @subroutine   check_updates
:: @description  Verifica si Plutonium tiene actualizaciones disponibles.
:: @returns      LOCAL_REVISION, REMOTE_REVISION
:: ============================================================================

:check_updates
    IF %CHECK_FOR_UPDATES% NEQ 1 (
        GOTO :EOF
    )

    CLS
    COLOR 07
    ECHO Buscando actualizaciones de Plutonium...
    ECHO.

    SETLOCAL
    SET _LOCAL_JSON=%PLUTONIUM_PATH%\info.json
    SET _REMOTE_JSON=https://cdn.plutoniummod.com/updater/prod/info.json
    SET _LOCAL_REVISION=0
    SET _REMOTE_REVISION=0

    START "Plutonium Local Revision" /D "%TEMP%" /I /MIN /WAIT PowerShell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "(Get-Content -Raw '%_LOCAL_JSON%' | ConvertFrom-Json).revision | Out-File -FilePath 'Plutonium_Local_Revision.txt' -Encoding 'ASCII' -NoNewline"

    IF NOT EXIST "%TEMP%\Plutonium_Local_Revision.txt" (
        GOTO :EOF
    )

    FOR /F "usebackq" %%G IN ("%TEMP%\Plutonium_Local_Revision.txt") DO (
        SET _LOCAL_REVISION=%%G
    )

    START "Plutonium Remote Revision" /D "%TEMP%" /I /MIN /WAIT PowerShell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "(Invoke-RestMethod -Uri '%_REMOTE_JSON%').revision | Out-File -FilePath 'Plutonium_Remote_Revision.txt' -Encoding 'ASCII' -NoNewline"

    IF NOT EXIST "%TEMP%\Plutonium_Remote_Revision.txt" (
        GOTO :EOF
    )

    FOR /F "usebackq" %%G IN ("%TEMP%\Plutonium_Remote_Revision.txt") DO (
        SET _REMOTE_REVISION=%%G
    )

    IF %_LOCAL_REVISION% NEQ %_REMOTE_REVISION% (
        ENDLOCAL & (
            SET LOCAL_REVISION=%_LOCAL_REVISION%
            SET REMOTE_REVISION=%_REMOTE_REVISION%
        )
        CALL :show_update_menu
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   show_update_menu
:: @description  Muestra el menú de actualización disponible de Plutonium.
:: ============================================================================

:show_update_menu
    ECHO Hay una actualización de Plutonium disponible.
    ECHO -  Revisión local: %LOCAL_REVISION%
    ECHO - Revisión remota: %REMOTE_REVISION%
    ECHO.
    CHOICE /C SN /N /M "¿Querés actualizar, (S)í o (N)o? "

    IF %ERRORLEVEL% EQU 1 (
        CALL :run_plutonium_updater
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   get_current_game
:: @description  Detecta qué juego está disponible para lanzar.
:: @returns      DETECTED_GAME o HAS_T4, HAS_T5, HAS_IW5, HAS_T6
:: ============================================================================

:get_current_game
    SETLOCAL

    SET _T4_FILE=main\video\ber1_load.bik
    SET _T5_FILE=main\video\int_hudson_explains_2.bik
    SET _IW5_FILE=main\video\innocent_load.bik
    SET _T6_FILE=video\zm_buried_load.webm

    SET _HAS_T4=0
    SET _HAS_T5=0
    SET _HAS_IW5=0
    SET _HAS_T6=0

    IF %PORTABLE_MODE% EQU 1 (
        IF EXIST "%_T4_FILE%" (
            ENDLOCAL & (
                SET DETECTED_GAME=T4
                SET T4_GAME_DIR=%CD%
            )
            GOTO :EOF
        )
        IF EXIST "%_T5_FILE%" (
            ENDLOCAL & (
                SET DETECTED_GAME=T5
                SET T5_GAME_DIR=%CD%
            )
            GOTO :EOF
        )
        IF EXIST "%_IW5_FILE%" (
            ENDLOCAL & (
                SET DETECTED_GAME=IW5
                SET IW5_GAME_DIR=%CD%
            )
            GOTO :EOF
        )
        IF EXIST "%_T6_FILE%" (
            ENDLOCAL & (
                SET DETECTED_GAME=T6
                SET T6_GAME_DIR=%CD%
            )
            GOTO :EOF
        )

        CLS
        COLOR 04
        ECHO No se encontró ningún juego válido en la ruta donde está este %~nx0:
        ECHO %CD%
        ECHO.
        ECHO Se detendrá la ejecución...
        PAUSE
        EXIT
    )

    IF EXIST "%T4_GAME_DIR%\%_T4_FILE%" (
        SET _DETECTED_GAME=T4
        SET _HAS_T4=1
    )
    IF EXIST "%T5_GAME_DIR%\%_T5_FILE%" (
        SET _DETECTED_GAME=T5
        SET _HAS_T5=1
    )
    IF EXIST "%IW5_GAME_DIR%\%_IW5_FILE%" (
        SET _DETECTED_GAME=IW5
        SET _HAS_IW5=1
    )
    IF EXIST "%T6_GAME_DIR%\%_T6_FILE%" (
        SET _DETECTED_GAME=T6
        SET _HAS_T6=1
    )

    IF DEFINED _DETECTED_GAME (
        ENDLOCAL & (
            SET HAS_T4=%_HAS_T4%
            SET HAS_T5=%_HAS_T5%
            SET HAS_IW5=%_HAS_IW5%
            SET HAS_T6=%_HAS_T6%
        )
        GOTO :EOF
    )

    CLS
    COLOR 04
    ECHO No se encontró ningún juego válido en las siguientes rutas:
    FOR %%G IN ("%T4_GAME_DIR%" "%T5_GAME_DIR%" "%IW5_GAME_DIR%" "%T6_GAME_DIR%") DO (
        ECHO %%~G
    )
    ECHO.
    ECHO Se detendrá la ejecución...
    PAUSE
    EXIT

:: ============================================================================
:: @subroutine   show_menu
:: @description  Muestra el menú del juego o menú principal según corresponda.
:: ============================================================================

:show_menu
    IF %PORTABLE_MODE% EQU 1 (
        IF "%DETECTED_GAME%"=="T4" (
            CALL :show_t4_menu
            GOTO :EOF
        )
        IF "%DETECTED_GAME%"=="T5" (
            CALL :show_t5_menu
            GOTO :EOF
        )
        IF "%DETECTED_GAME%"=="IW5" (
            CALL :show_iw5_menu
            GOTO :EOF
        )
        IF "%DETECTED_GAME%"=="T6" (
            CALL :show_t6_menu
            GOTO :EOF
        )
    )

    CALL :show_main_menu
    GOTO :EOF

:: ============================================================================
:: @subroutine   show_main_menu
:: @description  Muestra un menú para seleccionar el juego disponible.
:: ============================================================================

:show_main_menu
    CLS
    COLOR 07
    ECHO.
    ECHO ////////////////////////////////////////////////////////////////
    ECHO ////                   Plutonium Offline                    ////
    ECHO ////////////////////////////////////////////////////////////////
    ECHO.

    IF %HAS_T4% EQU 1 (
        ECHO [1] Call of Duty: World at War
    )
    IF %HAS_T5% EQU 1 (
        ECHO [2] Call of Duty: Black Ops
    )
    IF %HAS_IW5% EQU 1 (
        ECHO [3] Call of Duty: Modern Warfare 3
    )
    IF %HAS_T6% EQU 1 (
        ECHO [4] Call of Duty: Black Ops II
    )

    ECHO.
    SET /P USER_CHOICE="Seleccioná un juego: "

    IF %USER_CHOICE% EQU 1 (
        IF %HAS_T4% EQU 1 (
            CALL :show_t4_menu
            GOTO :EOF
        )
    )

    IF %USER_CHOICE% EQU 2 (
        IF %HAS_T5% EQU 1 (
            CALL :show_t5_menu
            GOTO :EOF
        )
    )

    IF %USER_CHOICE% EQU 3 (
        IF %HAS_IW5% EQU 1 (
            CALL :show_iw5_menu
            GOTO :EOF
        )
    )

    IF %USER_CHOICE% EQU 4 (
        IF %HAS_T6% EQU 1 (
            CALL :show_t6_menu
            GOTO :EOF
        )
    )

    GOTO :show_main_menu

:: ============================================================================
:: @subroutine   show_t4_menu
:: @description  Menú de opciones para Call of Duty: World at War
:: ============================================================================

:show_t4_menu
    TITLE Plutonium T4 - Offline
    CLS
    COLOR 07
    ECHO.
    ECHO ////////////////////////////////////////////////////////////////
    ECHO ////               Call of Duty: World at War               ////
    ECHO ////////////////////////////////////////////////////////////////
    ECHO.
    ECHO [1] Modo Individual / Zombi
    ECHO [2] Modo Multijugador
    ECHO.
    CHOICE /C 12 /N /M "Seleccioná un modo: "

    IF %ERRORLEVEL% EQU 1 (
        CALL :run_game t4sp "%T4_GAME_DIR%"
        GOTO :EOF
    )

    IF %ERRORLEVEL% EQU 2 (
        CALL :run_game t4mp "%T4_GAME_DIR%"
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   show_t5_menu
:: @description  Menú de opciones para Call of Duty: Black Ops
:: ============================================================================

:show_t5_menu
    TITLE Plutonium T5 - Offline
    CLS
    COLOR 07
    ECHO.
    ECHO ////////////////////////////////////////////////////////////////
    ECHO ////                Call of Duty: Black Ops                 ////
    ECHO ////////////////////////////////////////////////////////////////
    ECHO.
    ECHO [1] Modo Individual / Zombi
    ECHO [2] Modo Multijugador
    ECHO.
    CHOICE /C 12 /N /M "Seleccioná un modo: "

    IF %ERRORLEVEL% EQU 1 (
        CALL :run_game t5sp "%T5_GAME_DIR%"
        GOTO :EOF
    )

    IF %ERRORLEVEL% EQU 2 (
        CALL :run_game t5mp "%T5_GAME_DIR%"
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   show_iw5_menu
:: @description  Menú de opciones para Call of Duty: Modern Warfare 3
:: ============================================================================

:show_iw5_menu
    TITLE Plutonium IW5 - Offline
    CLS
    COLOR 07
    ECHO.
    ECHO ////////////////////////////////////////////////////////////////
    ECHO ////             Call of Duty: Modern Warfare 3             ////
    ECHO ////////////////////////////////////////////////////////////////
    ECHO.
    ECHO [1] Modo Individual / Operaciones Especiales
    ECHO [2] Modo Multijugador
    ECHO.
    CHOICE /C 12 /N /M "Seleccioná un modo: "

    IF %ERRORLEVEL% EQU 1 (
        CALL :run_game iw5sp "%IW5_GAME_DIR%"
        GOTO :EOF
    )

    IF %ERRORLEVEL% EQU 2 (
        CALL :run_game iw5mp "%IW5_GAME_DIR%"
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   show_t6_menu
:: @description  Menú de opciones para Call of Duty: Black Ops II
:: ============================================================================

:show_t6_menu
    TITLE Plutonium T6 - Offline
    CLS
    COLOR 07
    ECHO.
    ECHO ////////////////////////////////////////////////////////////////
    ECHO ////               Call of Duty: Black Ops II               ////
    ECHO ////////////////////////////////////////////////////////////////
    ECHO.
    ECHO [1] Modo Zombi
    ECHO [2] Modo Multijugador
    ECHO.
    CHOICE /C 12 /N /M "Seleccioná un modo: "

    IF %ERRORLEVEL% EQU 1 (
        CALL :run_game t6zm "%T6_GAME_DIR%"
        GOTO :EOF
    )

    IF %ERRORLEVEL% EQU 2 (
        CALL :run_game t6mp "%T6_GAME_DIR%"
        GOTO :EOF
    )

    GOTO :EOF

:: ============================================================================
:: @subroutine   run_game
:: @param        %1 Nombre del ejecutable en %PLUTONIUM_PATH%\games (por ejemplo: iw5mp)
:: @param        %2 Ruta al directorio del juego
:: @description  Lanza el juego especificado con configuración offline.
:: ============================================================================

:run_game
    CLS
    COLOR 02
    ECHO.
    ECHO Iniciando el juego...
    START "Plutonium Offline" /D "%PLUTONIUM_PATH%" "%PLUTONIUM_BOOTSTRAPPER_PATH%\%PLUTONIUM_BOOTSTRAPPER_EXE%" %1 %2 -lan %LAUNCH_PARAMETERS% +set name "%PLAYER_NAME%"
    ECHO Ya no necesitás esta ventana, así que se cerrará automáticamente.
    ECHO.
    TIMEOUT /T 15
    EXIT
