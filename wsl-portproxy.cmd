@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Starting with administrator privileges...
    powershell -Command "Start-Process -Verb RunAs -FilePath '%~f0'" %*
    exit /b
)
wt -w 0 nt powershell -ExecutionPolicy Bypass -NoExit -File "%~dpn0.ps1" %*