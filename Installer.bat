@echo off
echo off
powershell -NoProfile -Command "$Host.UI.RawUI.CursorSize = 0"
title Requirements Installer

echo [1/4] Checking and upgrading pip...
python -m pip install --upgrade pip

cls
echo [2/4] Checking and Installing pipreqs...
python -m pip install pipreqs

cls
echo [3/4] Generating requirements.txt...
python -m pipreqs.pipreqs . --force

cls
echo [4/4] Installing all requirements...
python -m pip install -r requirements.txt

cls
title REQUIREMENTS INSTALLER COMPLETED SUCCESSFULLY!
echo.
echo.
echo                     REQUIREMENTS INSTALLER COMPLETED SUCCESSFULLY!
pause >nul