@echo off
chcp 65001 >nul
powershell -NoProfile -Command "$Host.UI.RawUI.CursorSize = 0"
title Requirements Installer

echo [0/4] Checking Python environment via PySilInstaller...
set "PYSIL_URL=https://raw.githubusercontent.com/weiwei-hacking/PySilInstaller/main/PySilInstaller.bat"
set "PYSIL_PATH=%TEMP%\PySilInstaller.bat"

powershell -NoProfile -Command "try { Invoke-WebRequest -Uri '%PYSIL_URL%' -OutFile '%PYSIL_PATH%' -UseBasicParsing -ErrorAction Stop; exit 0 } catch { exit 1 }"
if %errorlevel% equ 0 (
    call "%PYSIL_PATH%" "%~f0"
    if %errorlevel% neq 0 (
        echo [!] PySilInstaller exited with an error.
        pause >nul
        exit /b 1
    )
) else (
    echo [!] Unable to fetch PySilInstaller from GitHub. Continuing with local environment...
    timeout /t 2 >nul
)

cls
echo [1/4] Checking and upgrading pip...
python -m pip install --upgrade pip

cls
echo [2/4] Checking and installing pipreqs...
python -m pip install pipreqs

cls
echo [3/4] Generating requirements.txt...
python -m pipreqs.pipreqs . --force

cls
echo [4/4] Installing all requirements...
python -m pip install -r requirements.txt

cls
title Completed
echo.
echo.
echo                     REQUIREMENTS INSTALLER COMPLETED SUCCESSFULLY!
pause >nul
