@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Starte mit Administratorrechten...
    powershell -Command "Start-Process -Verb RunAs -FilePath '%~f0'" %*
    exit /b
)
wt -w 0 nt powershell -ExecutionPolicy Bypass -NoExit -File "%~dpn0.ps1" %*