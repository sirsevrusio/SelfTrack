#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

APP_NAME="SelfTrack"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
EXECUTABLE_NAME="SelfTrack"
VENV_DIR="venv"

echo "===== $APP_NAME Installer ====="

# --- Step 1: Check Python Installation ---
if ! command -v python3 &>/dev/null; then
    echo "Python3 not found. Installing..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip
else
    echo "Python3 is already installed."
fi

# --- Step 2: Create Virtual Environment ---
echo "Creating virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# --- Step 3: Install Required Python Packages ---
echo "Installing Python packages (Flask, PyInstaller)..."
pip install --upgrade pip
pip install flask pyinstaller

# --- Step 4: Prepare Local Directories ---
echo "Preparing local directories (logs/, data/)..."
mkdir -p logs data

# --- Step 5: Build Executable ---
echo "Building executable with PyInstaller..."
pyinstaller --onefile \
    --add-data "templates:templates" \
    --add-data "static:static" \
    --add-data "logs:logs" \
    --add-data "data:data" \
    --name "$EXECUTABLE_NAME" \
    --noconsole \
    app.py

deactivate

# --- Step 6: Install the App ---
echo "Installing $APP_NAME to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "dist/$EXECUTABLE_NAME" "$INSTALL_DIR/"
sudo cp -r templates static "$INSTALL_DIR/"

# Create empty logs/ and data/ folders
echo "Creating logs/ and data/ in $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR/logs" "$INSTALL_DIR/data"

# Set ownership to current user
CURRENT_USER=$(whoami)
echo "Setting ownership of $INSTALL_DIR to user: $CURRENT_USER"
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$INSTALL_DIR"

# --- Step 7: Set Executable Permissions ---
echo "Setting executable permissions..."
sudo chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"

# --- Step 8: Create .desktop Launcher ---
echo "Creating desktop launcher at $DESKTOP_FILE..."

sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=$APP_NAME
Comment=Simple self-tracking and session recording tool
Exec=$INSTALL_DIR/$EXECUTABLE_NAME
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;
EOL

# --- Step 9: Update Desktop Database ---
echo "Updating desktop database..."
sudo update-desktop-database || true  # Don't fail if update-desktop-database is missing

# --- Step 10: Clean Up Build Files ---
echo "Cleaning up build files..."
rm -rf build dist *.spec "$VENV_DIR"

echo ""
echo "🎉 $APP_NAME installed successfully!"
echo "You can now find it in your Applications menu!"
echo ""
