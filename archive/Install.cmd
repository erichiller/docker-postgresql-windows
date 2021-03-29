@if not defined _echo echo off
setlocal enabledelayedexpansion

call %*
echo %ERRORLEVEL%

if "%ERRORLEVEL%"=="3010" (
    echo Errorlevel is 3010
    exit /b 0
) else (
    if not "%ERRORLEVEL%"=="0" (
        echo "*************** ERROR ***************"
        set ERR=%ERRORLEVEL%
        call C:\TEMP\collect.exe -zip:C:\vslogs.zip


        REM exit /b !ERR!
    )
)