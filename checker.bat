@echo off
chcp 65001 >nul
title Python Environment Checker

:: 若已經是由 checker 重新啟動的，直接通過並回到 Installer.bat
if defined PYLIB_CHECKER_DONE (
    exit /b 0
)

:: 1. 檢查是否已有可用的 Python（排除 WindowsApps 商店導向 stub）
where python >nul 2>nul
if %errorlevel% equ 0 (
    for /f "delims=" %%P in ('where python 2^>nul') do (
        echo "%%P" | findstr /i "WindowsApps" >nul
        if errorlevel 1 (
            python --version >nul 2>nul
            if %errorlevel% equ 0 (
                echo [OK] Python detected:
                python --version
                exit /b 0
            )
        )
    )
)

echo [!] Python not found. Checking winget...
where winget >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] winget is not available on this system.
    echo     Please install Python manually from https://www.python.org/downloads/
    pause >nul
    exit /b 1
)

echo [*] Installing Python silently via winget...
winget install --id Python.Python.3.12 --exact --silent --accept-package-agreements --accept-source-agreements
if %errorlevel% neq 0 (
    echo [X] winget failed to install Python (Error code: %errorlevel%).
    pause >nul
    exit /b 1
)

echo [OK] Python installation completed. Refreshing environment and restarting Installer.bat...
timeout /t 2 >nul

:: 2. 取得系統與使用者最新 PATH 並重新啟動 Installer.bat
set "PYLIB_CHECKER_DONE=1"
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYS_PATH=%%B"
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USR_PATH=%%B"
set "PATH=%SYS_PATH%;%USR_PATH%;%LocalAppData%\Programs\Python\Python312;%LocalAppData%\Programs\Python\Python312\Scripts"

:: 尋找主腳本（優先找目前工作目錄的 Installer.bat）
set "TARGET_BAT=%CD%\Installer.bat"
if not exist "%TARGET_BAT%" (
    if exist "%CD%\Insaller.bat" set "TARGET_BAT=%CD%\Insaller.bat"
)

if exist "%TARGET_BAT%" (
    start "" cmd /c "set PYLIB_CHECKER_DONE=1 && set \"PATH=%PATH%\" && cd /d \"%CD%\" && call \"%TARGET_BAT%\""
    exit /b 0
) else (
    echo [!] Installer.bat not found in current directory: %CD%
    exit /b 0
)