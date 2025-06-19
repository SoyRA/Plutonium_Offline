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

:: Activar (1) o Desactivar (0) la validación de las rutas
SET VALIDATE_PATHS=1

:: Activar (1) o Desactivar (0) los easter eggs
SET EASTER_EGGS=1

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

CALL :pre_check_path
CALL :get_plutonium_updater_path
CALL :get_plutonium_bootstrapper_path
CALL :check_updates
CALL :get_current_game
CALL :check_player_name
CALL :easter_egg
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
        CALL :check_path "%LOCALAPPDATA%\Plutonium"
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
        CALL :check_path "%LOCALAPPDATA%\Plutonium"
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
            CALL :check_path "%LOCALAPPDATA%\Plutonium"
        )
    )

    IF NOT DEFINED PLUTONIUM_UPDATER_PATH (
        IF %PORTABLE_MODE% EQU 1 (
            SET PLUTONIUM_UPDATER_PATH=%CD%
        ) ELSE (
            SET PLUTONIUM_UPDATER_PATH=%LOCALAPPDATA%\Plutonium
            CALL :check_path "%LOCALAPPDATA%\Plutonium"
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
        CALL :check_path "%T4_GAME_DIR%"
    )
    IF EXIST "%T5_GAME_DIR%\%_T5_FILE%" (
        SET _DETECTED_GAME=T5
        SET _HAS_T5=1
        CALL :check_path "%T5_GAME_DIR%"
    )
    IF EXIST "%IW5_GAME_DIR%\%_IW5_FILE%" (
        SET _DETECTED_GAME=IW5
        SET _HAS_IW5=1
        CALL :check_path "%IW5_GAME_DIR%"
    )
    IF EXIST "%T6_GAME_DIR%\%_T6_FILE%" (
        SET _DETECTED_GAME=T6
        SET _HAS_T6=1
        CALL :check_path "%T6_GAME_DIR%"
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
:: @subroutine   pre_check_path
:: @description  Verifica si la ruta donde se ejecuta este script es válida.
:: @returns      MAX_PATH
:: ============================================================================

:pre_check_path
    IF %VALIDATE_PATHS% NEQ 1 (
        GOTO :EOF
    )

    SETLOCAL
    SET _BAD_PATH_LENGTH=0
    SET _BAD_PATH_CHARS=0
    SET _BAD_PATH_ONEDRIVE=0

    :: Determino cuál puede ser el largo máximo de la ruta
    :: Aunque los posibles son 260 y 32767, debo restarle 86 porque considero la ruta más larga que puede tener Plutonium / el Juego
    SET _MAX_PATH=174
    CALL REG QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD | FIND "0x1" > NUL 2>&1
    IF %ERRORLEVEL% EQU 0 (
        :: Pero hay un límite de 8191 para las líneas de CMD y pasarte de 260 parece que estás buscando problemas apropósito realmente xd
        SET _MAX_PATH=1040
    )

    :: Determino el largo de la ruta
    SET _PATH=%CD%
    CALL :strlen _PATH _LENGTH
    IF %_LENGTH% GTR %_MAX_PATH% (
        SET _BAD_PATH_LENGTH=1
    )

    :: Determino si la ruta tiene algo más que alfanuméricos, guion bajo, barra invertida y espacios
    :: Obviamente hay más caracteres válidos, pero todo depende de lo que aguante Plutonium y/o el Juego así que la hago simple
    SET _PATH=%CD:~2%
    START "" /I /MIN /WAIT PowerShell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "if ('%_PATH%' -notmatch '^[\w\\ ]*$') { Exit 1 }"
    IF %ERRORLEVEL% EQU 1 (
        SET _BAD_PATH_CHARS=1
    )

    :: Determino si la ruta está en OneDrive
    :: Podría verificarse más cosas para hacerlo más preciso pero bueno
    SET _PATH=%CD%
    CALL SET "_TEMP=%%_PATH:%ONEDRIVE%=%%"
    IF NOT "%_TEMP%"=="%_PATH%" (
        SET _BAD_PATH_ONEDRIVE=1
    )

    :: Si todo está bien nos vamos
    IF %_BAD_PATH_LENGTH% EQU 0 (
        IF %_BAD_PATH_CHARS% EQU 0 (
            IF %_BAD_PATH_ONEDRIVE% EQU 0 (
                ENDLOCAL & SET MAX_PATH=%_MAX_PATH%
                GOTO :EOF
            )
        )
    )

    CLS
    COLOR 06
    ECHO Aviso: La ruta "%_PATH%" tiene los siguientes problemas:
    IF %_BAD_PATH_LENGTH% EQU 1 (
        ECHO - Es muy larga ^(%_LENGTH% de %_MAX_PATH% caracteres^).
    )
    IF %_BAD_PATH_CHARS% EQU 1 (
        ECHO - Contiene algo más que alfanuméricos, guion bajo y espacios.
    )
    IF %_BAD_PATH_ONEDRIVE% EQU 1 (
        ECHO - Está en OneDrive.
    )
    ECHO.
    ECHO Todo esto podría causar problemas en la ejecución de este %~nx0, Plutonium y/o el Juego.
    ECHO Te recomiendo mover todo a una ruta simple usando solo alfanuméricos y espacios, como "C:\Juegos\Nombre del Juego"
    ECHO.
    CHOICE /C SN /N /M "¿Querés continuar y arriesgarte, (S)í o (N)o? "

    IF %ERRORLEVEL% EQU 2 (
        EXIT
    )

    ENDLOCAL & SET MAX_PATH=%_MAX_PATH%
    GOTO :EOF

:: ============================================================================
:: @subroutine   check_path
:: @param        %1 Ruta a comprobar.
:: @description  Verifica si la ruta especificada es válida.
:: ============================================================================

:check_path
    IF %VALIDATE_PATHS% NEQ 1 (
        GOTO :EOF
    )

    SETLOCAL

    SET _BAD_PATH_LENGTH=0
    SET _BAD_PATH_CHARS=0
    SET _BAD_PATH_ONEDRIVE=0

    :: Determino el largo de la ruta
    SET _PATH=%~1
    CALL :strlen _PATH _LENGTH
    IF %_LENGTH% GTR %MAX_PATH% (
        SET _BAD_PATH_LENGTH=1
    )

    :: Determino si la ruta tiene algo más que alfanuméricos, guion bajo, barra invertida y espacios
    :: Obviamente hay más caracteres válidos, pero todo depende de lo que aguante Plutonium y/o el Juego así que la hago simple
    SET _PATH=%~pn1
    START "" /I /MIN /WAIT PowerShell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "if ('%_PATH%' -notmatch '^[\w\\ ]*$') { Exit 1 }"
    IF %ERRORLEVEL% EQU 1 (
        SET _BAD_PATH_CHARS=1
    )

    :: Determino si la ruta está en OneDrive
    :: Podría verificarse más cosas para hacerlo más preciso pero bueno
    SET _PATH=%~1
    CALL SET "_TEMP=%%_PATH:%ONEDRIVE%=%%"
    IF NOT "%_TEMP%"=="%_PATH%" (
        SET _BAD_PATH_ONEDRIVE=1
    )

    :: Si todo está bien nos vamos
    IF %_BAD_PATH_LENGTH% EQU 0 (
        IF %_BAD_PATH_CHARS% EQU 0 (
            IF %_BAD_PATH_ONEDRIVE% EQU 0 (
                ENDLOCAL
                GOTO :EOF
            )
        )
    )

    CLS
    COLOR 06
    ECHO Aviso: La ruta "%_PATH%" tiene los siguientes problemas:
    IF %_BAD_PATH_LENGTH% EQU 1 (
        ECHO - Es muy larga ^(%_LENGTH% de %MAX_PATH% caracteres^).
    )
    IF %_BAD_PATH_CHARS% EQU 1 (
        ECHO - Contiene algo más que alfanuméricos, guion bajo y espacios.
    )
    IF %_BAD_PATH_ONEDRIVE% EQU 1 (
        ECHO - Está en OneDrive.
    )
    ECHO.
    ECHO Todo esto podría causar problemas en la ejecución de este %~nx0, Plutonium y/o el Juego.
    ECHO Te recomiendo mover todo a una ruta simple usando solo alfanuméricos y espacios, como "C:\Juegos\Nombre del Juego"
    ECHO.
    CHOICE /C SN /N /M "¿Querés continuar y arriesgarte, (S)í o (N)o? "

    IF %ERRORLEVEL% EQU 2 (
        EXIT
    )

    ENDLOCAL
    GOTO :EOF

:: ============================================================================
:: @subroutine   check_player_name
:: @description  Verifica el largo del nombre sin contar los códigos de color.
:: ============================================================================

:check_player_name
    SETLOCAL ENABLEDELAYEDEXPANSION

    :: Eliminar los códigos de color
    SET "_CLEAN_NAME=#!PLAYER_NAME!"

    FOR %%G IN (0 1 2 3 4 5 6 7 8 9) DO (
        SET "_CLEAN_NAME=!_CLEAN_NAME:^%%G=!"
    )

    :: Eliminar el primer carácter que es un # para evitar que esté vacío
    :: Así no hay problemas en nombres vacíos o con un código de color sin más
    SET "_CLEAN_NAME=!_CLEAN_NAME:~1!"

    :: Obtener el largo del nombre
    CALL :strlen _CLEAN_NAME _LENGTH

    IF %_LENGTH% LSS 1 (
        CLS
        COLOR 06
        ECHO Aviso: Tu nombre parece ser menor a 1 carácter, es posible que el juego te lo cambie a uno predeterminado.
        ECHO.
        PAUSE
    )

    IF %_LENGTH% GTR 15 (
        CLS
        COLOR 06
        ECHO Aviso: Tu nombre parece ser mayor a 15 caracteres, es posible que el juego te lo recorte.
        ECHO.
        PAUSE
    )

    ENDLOCAL
    GOTO :EOF

:: ============================================================================
:: @subroutine   strlen
:: @param        %1 [in]  La cadena cuya longitud se desea calcular.
:: @param        %2 [out] Variable donde se almacenará el resultado.
:: @description  Devuelve la longitud de una cadena.
:: @author       Dave Benham <https://ss64.com/nt/syntax-strlen.html>
:: ============================================================================

:strlen
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET "_STRING=#!%~1!"
    SET _LENGTH=0
    FOR %%G IN (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) DO (
        IF "!_STRING:~%%G,1!" NEQ "" (
            SET /A _LENGTH+=%%G
            SET "_STRING=!_STRING:~%%G!"
        )
    )
    ENDLOCAL & (
        IF "%~2" NEQ "" (
            SET %~2=%_LENGTH%
        )
    )
    GOTO :EOF

:: ============================================================================
:: @subroutine   easter_egg
:: @description  Huevos de pascua para romper los huevos. :v
:: ============================================================================

:easter_egg
    IF %EASTER_EGGS% NEQ 1 (
        GOTO :EOF
    )

    IF NOT %RANDOM% LEQ 225 (
        GOTO :EOF
    )

    SETLOCAL
    CLS
    COLOR 03
    SET /A _EGG_OPTION=(%RANDOM% %% 5) + 1

    :: En honor a JoseX
    IF %_EGG_OPTION% EQU 1 (
        START "" /I /MIN /WAIT PowerShell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "if (-not ((Get-Date).Month -eq 3 -and (Get-Date).Day -eq 31)) { Exit 1 }"
        IF %ERRORLEVEL% EQU 0 (
            SET PLAYER_NAME=Pibe Sex
        )
    )

    :: En honor a M4RCK5
    IF %_EGG_OPTION% EQU 2 (
        ECHO "Mi script es aprueba de idiotas, no como el tuyo. uwu"
        ECHO - M4RCK5, 69 años. Su script no realiza comprobaciones pese a decir que es aprueba de idiotas.
        TIMEOUT /T 5 /NOBREAK > NUL
    )

    :: CMD / PS Spam
    IF %_EGG_OPTION% EQU 3 (
        FOR /L %%G IN (1, 1, 4) DO (
            START "" /I CMD.exe /C "TIMEOUT /T 1 /NOBREAK > NUL"
            START "" /I PowerShell.exe -NoLogo -NoProfile -NonInteractive -Command "Start-Sleep -Seconds 1"
        )
    )

    :: RAServer Fake Virus
    IF %_EGG_OPTION% EQU 4 (
        IF EXIST "%WINDIR%\System32\raserver.exe" (
            ECHO [RAServer] Inicializando conexión segura...
            TIMEOUT /T 1 /NOBREAK > NUL
            ECHO [RAServer] Transfiriendo documentos privados...
            TIMEOUT /T 3 /NOBREAK > NUL
            ECHO [RAServer] Completado.
            TIMEOUT /T 1 /NOBREAK > NUL
        )
    )

    :: Rickroll
    IF %_EGG_OPTION% EQU 5 (
        START "" "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    )

    ENDLOCAL
    GOTO :EOF

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
