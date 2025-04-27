#!/bin/bash

APP_NAME="SelfTrack"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
EXECUTABLE_NAME="SelfTrack"
VENV_DIR="venv"

# --- Step 1: Check Python Installation ---
if ! command -v python3 &>/dev/null; then
    echo "Python3 is not installed. Installing Python3..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip
else
    echo "Python3 is installed."
fi

# --- Step 2: Create Virtual Environment ---
echo "Setting up virtual environment..."
python3 -m venv "$VENV_DIR"

# Activate venv
source "$VENV_DIR/bin/activate"

# --- Step 3: Install Required Packages ---
echo "Installing required Python packages..."
pip install --upgrade pip
pip install flask pyinstaller

# --- Step 4: Build Executable ---
echo "Building executable with PyInstaller..."
pyinstaller --onefile --add-data "templates:templates" --add-data "static:static" app.py --name "$EXECUTABLE_NAME" --noconsole

# Deactivate venv
deactivate

# --- Step 5: Install the App ---
# Move executable and folders
echo "Installing $APP_NAME to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "dist/$EXECUTABLE_NAME" "$INSTALL_DIR/"
sudo cp -r templates "$INSTALL_DIR/"
sudo cp -r static "$INSTALL_DIR/"
sudo cp -r logs "$INSTALL_DIR/" || echo "No logs folder yet, skipping."
sudo cp -r data "$INSTALL_DIR/" || echo "No data folder yet, skipping."

# --- Step 6: Set Executable Permission ---
sudo chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"

# --- Step 7: Create .desktop Launcher ---
echo "Creating desktop entry..."

sudo bash -c "cat > $DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$APP_NAME
Comment=A simple self-tracking and session recording tool
Exec=$INSTALL_DIR/$EXECUTABLE_NAME
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;
EOL

# --- Step 8: Update Desktop Database ---
echo "Updating application database..."
sudo update-desktop-database

echo "$APP_NAME installed successfully!"

# --- Step 9: Clean Up Build Files ---
echo "Cleaning up temporary build files..."
rm -rf build dist *.spec "$VENV_DIR"

echo "Done! You can now launch $APP_NAME from the Applications Menu!"
