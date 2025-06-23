@echo off
:: Check if running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo You are now running as Administrator.
pause

echo Killing notepad (used for .txt files)...
taskkill /f /im notepad.exe >nul 2>&1

echo Killing terminal processes...
taskkill /f /im cmd.exe >nul 2>&1
taskkill /f /im powershell.exe >nul 2>&1
taskkill /f /im WindowsTerminal.exe >nul 2>&1

echo Killing local .exe files...
for %%f in (*.exe) do (
    taskkill /f /im %%~nxf >nul 2>&1
)

:: Optional: also kill conhost which may stay alive after cmd
taskkill /f /im conhost.exe >nul 2>&1

:: Won’t reach this line because cmd will be killed above
exit
