@echo off
setlocal ENABLEDELAYEDEXPANSION

set APP_NAME=SelfTrack
set INSTALL_DIR="C:\Program Files\%APP_NAME%"
set SHORTCUT_NAME=%APP_NAME%.lnk
set EXECUTABLE_NAME=SelfTrack.exe
set PYTHON_VERSION_REQUIRED=3.12.3

echo =========================================
echo Installing %APP_NAME%...
echo =========================================

:: Check if python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed!
    echo Please install Python %PYTHON_VERSION_REQUIRED% manually from:
    echo   https://www.python.org/ftp/python/%PYTHON_VERSION_REQUIRED%/python-%PYTHON_VERSION_REQUIRED%-amd64.exe
    echo Make sure to select "Add Python to PATH" during installation.
    pause
    exit /b 1
) else (
    echo [INFO] Python found!
)

:: Create virtual environment
echo Creating virtual environment...
python -m venv venv

if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
) else (
    echo [ERROR] Failed to create virtual environment.
    pause
    exit /b 1
)

:: Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

:: Install requirements
echo Installing required packages...
python -m pip install flask pyinstaller

:: Build executable
echo Building executable using PyInstaller...
pyinstaller --onefile --add-data "templates;templates" --add-data "static;static" app.py --name %APP_NAME%

:: Deactivate venv
deactivate

:: Create installation directory
echo Installing built app to %INSTALL_DIR%...
if not exist %INSTALL_DIR% (
    mkdir %INSTALL_DIR%
)

copy /Y dist\%EXECUTABLE_NAME% %INSTALL_DIR%
xcopy templates %INSTALL_DIR%\templates /E /I /Y
xcopy static %INSTALL_DIR%\static /E /I /Y
xcopy logs %INSTALL_DIR%\logs /E /I /Y
xcopy data %INSTALL_DIR%\data /E /I /Y

:: Create a desktop shortcut
echo Creating desktop shortcut...

powershell -Command ^
  "$WshShell = New-Object -ComObject WScript.Shell; ^
   $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\%SHORTCUT_NAME%'); ^
   $Shortcut.TargetPath = '%INSTALL_DIR%\%EXECUTABLE_NAME%'; ^
   $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; ^
   $Shortcut.WindowStyle = 1; ^
   $Shortcut.Description = 'Launch SelfTrack'; ^
   $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,3'; ^
   $Shortcut.Save()"

echo.
echo =========================================
echo %APP_NAME% installed successfully!
echo =========================================
pause
endlocal
