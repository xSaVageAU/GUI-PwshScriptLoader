@echo off
:: Check if the script is running with administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: If already running as administrator, execute the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0PwshScriptLoader.ps1"
