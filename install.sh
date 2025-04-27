#!/bin/bash

set -e  # Exit immediately on error

APP_NAME="SelfTrack"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
EXECUTABLE_NAME="SelfTrack"
VENV_DIR="venv"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Spinner ---
spin() {
    local -a marks=('/' '-' '\' '|')
    while :; do
        for mark in "${marks[@]}"; do
            printf "\r${YELLOW}%s${NC}" "$mark"
            sleep 0.1
        done
    done
}

# --- Logging ---
info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "\n${YELLOW}===== $APP_NAME Installer =====${NC}\n"

# --- Detect Package Manager ---
detect_package_manager() {
    info "Detecting package manager..."
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
    else
        error "No supported package manager found (apt, dnf, pacman). Exiting."
        exit 1
    fi
    success "Detected package manager: $PKG_MANAGER"
}

# --- Install Required Packages ---
install_requirements() {
    info "Checking if Python3 is installed..."
    if ! command -v python3 &>/dev/null; then
        info "Python3 not found. Installing..."
        case "$PKG_MANAGER" in
            apt)
                sudo apt update
                sudo apt install -y python3 python3-venv python3-pip
                ;;
            dnf)
                sudo dnf install -y python3 python3-venv python3-pip
                ;;
            pacman)
                sudo pacman -Sy --noconfirm python python-virtualenv python-pip
                ;;
        esac
        success "Python3 installed successfully."
    else
        success "Python3 is already installed."
    fi
}

# --- Step 1: Preparation ---
detect_package_manager
install_requirements

# --- Step 2: Create Virtual Environment ---
info "Creating virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
success "Virtual environment created."

# --- Step 3: Install Required Python Packages ---
info "Installing Python packages (Flask, PyInstaller)..."
{
    spin &
    SPIN_PID=$!
    pip install --upgrade pip
    pip install flask pyinstaller
    kill $SPIN_PID
    wait $SPIN_PID 2>/dev/null || true
}
success "Python packages installed."

# --- Step 4: Prepare Local Directories ---
info "Preparing local directories (logs/, data/)..."
mkdir -p logs data
success "Directories prepared."

# --- Step 5: Build Executable ---
info "Building executable with PyInstaller..."
{
    spin &
    SPIN_PID=$!
    pyinstaller --onefile \
        --add-data "templates:templates" \
        --add-data "static:static" \
        --add-data "logs:logs" \
        --add-data "data:data" \
        --name "$EXECUTABLE_NAME" \
        --noconsole \
        app.py
    kill $SPIN_PID
    wait $SPIN_PID 2>/dev/null || true
}
success "Executable built."

deactivate

# --- Step 6: Install the App ---
info "Installing $APP_NAME to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "dist/$EXECUTABLE_NAME" "$INSTALL_DIR/"
sudo cp -r templates static "$INSTALL_DIR/"
success "Files copied."

# Create empty logs/ and data/ folders
info "Creating logs/ and data/ in $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR/logs" "$INSTALL_DIR/data"
success "Logs and data folders created."

# Set ownership to current user
CURRENT_USER=$(whoami)
info "Setting ownership of $INSTALL_DIR to $CURRENT_USER..."
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$INSTALL_DIR"
success "Ownership set."

# --- Step 7: Set Executable Permissions ---
info "Setting executable permissions..."
sudo chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"
success "Permissions set."

# --- Step 8: Create .desktop Launcher ---
info "Creating desktop launcher at $DESKTOP_FILE..."

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
success "Desktop launcher created."

# --- Step 9: Update Desktop Database ---
info "Updating desktop database..."
if command -v update-desktop-database &>/dev/null; then
    sudo update-desktop-database
    success "Desktop database updated."
else
    info "Skipping desktop database update (command not found)."
fi

# --- Step 10: Clean Up Build Files ---
info "Cleaning up build files..."
rm -rf build dist *.spec "$VENV_DIR"
success "Build files cleaned."

echo -e "\n${GREEN}🎉 $APP_NAME installed successfully!${NC}"
echo -e "${GREEN}You can now find it in your Applications menu!${NC}\n"
