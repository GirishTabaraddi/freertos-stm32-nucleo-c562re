#!/bin/bash
set -e

echo "============================================"
echo " FreeRTOS STM32 Course — Ubuntu Setup"
echo " Board: NUCLEO-C562RE (STM32C562RE)"
echo "============================================"

# ── 1. System packages ────────────────────────────────────────────────────────
echo "[1/6] Installing system packages..."
sudo apt update
sudo apt install -y \
    git git-lfs \
    cmake make \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libusb-1.0-0 libusb-dev \
    minicom screen \
    python3 python3-pip python3-venv \
    curl wget unzip \
    openjdk-17-jdk

# NOTE: We do NOT install stlink-tools from apt.
# stlink-tools in apt has an outdated chip database and shows flash=0
# for the STM32C562RE (new STM32C5 series).
# We use STM32CubeProgrammer instead — see step 3.

# ── 2. udev rules for ST-LINK/V3 ─────────────────────────────────────────────
echo "[2/6] Installing ST-LINK udev rules..."

# Write the udev rule directly — covers ST-LINK V2, V3, and all variants
sudo tee /etc/udev/rules.d/49-stlink.rules > /dev/null << 'UDEV'
# ST-LINK V1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", \
    MODE="660", GROUP="plugdev", TAG+="uaccess"

# ST-LINK V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
    MODE="660", GROUP="plugdev", TAG+="uaccess"

# ST-LINK V2-1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    MODE="660", GROUP="plugdev", TAG+="uaccess"

# ST-LINK V3 (your board: 0483:3754)
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", \
    MODE="660", GROUP="plugdev", TAG+="uaccess"

# ST-LINK V3E, V3E-HLA
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", \
    MODE="660", GROUP="plugdev", TAG+="uaccess"
UDEV

sudo udevadm control --reload-rules
sudo udevadm trigger
echo "  → udev rules installed (covers ST-LINK V3 at 0483:3754 — your board)"

# ── 3. STM32CubeProgrammer — manual step ─────────────────────────────────────
echo ""
echo "[3/6] STM32CubeProgrammer (MANUAL STEP REQUIRED)"
echo "  The apt version of stlink-tools is too old for STM32C562RE."
echo "  You must install STM32CubeProgrammer from ST's website:"
echo ""
echo "  1. Go to: https://www.st.com/en/development-tools/stm32cubeprog.html"
echo "  2. Download: SetupSTM32CubeProgrammer-*-linux-x64.zip"
echo "     (Free ST account required)"
echo "  3. Run:"
echo "     cd ~/Downloads"
echo "     unzip SetupSTM32CubeProgrammer-*-linux-x64.zip"
echo "     chmod +x SetupSTM32CubeProgrammer*.linux"
echo "     ./SetupSTM32CubeProgrammer*.linux"
echo "  4. Default install path:"
echo "     ~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/"
echo "  5. Add to PATH — run scripts/add_programmer_to_path.sh"
echo ""
echo "  Press ENTER when done, or Ctrl+C to do it later."
read -r

# ── 4. Add STM32CubeProgrammer to PATH ───────────────────────────────────────
echo "[4/6] Adding STM32CubeProgrammer to PATH..."
PROG_PATH="$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin"

if [ -f "$PROG_PATH/STM32_Programmer_CLI" ]; then
    if ! grep -q "STM32CubeProgrammer" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# STM32CubeProgrammer CLI" >> ~/.bashrc
        echo "export PATH=\"$PROG_PATH:\$PATH\"" >> ~/.bashrc
        echo "  → Added to ~/.bashrc"
    else
        echo "  → Already in PATH"
    fi
    export PATH="$PROG_PATH:$PATH"
    STM32_Programmer_CLI --version
else
    echo "  ⚠ STM32CubeProgrammer not found at expected path."
    echo "    Run scripts/add_programmer_to_path.sh after installing it."
fi

# ── 5. User groups ────────────────────────────────────────────────────────────
echo "[5/6] Adding $USER to required groups..."
sudo usermod -aG plugdev "$USER"
sudo usermod -aG dialout "$USER"
echo "  → Groups: plugdev, dialout (re-login required)"

# ── 6. Git submodules ─────────────────────────────────────────────────────────
echo "[6/6] Initializing git submodules..."
git submodule update --init --recursive

echo ""
echo "============================================"
echo " ✅ Setup complete!"
echo " ⚠  LOG OUT and back in for group changes"
echo " Then verify with: bash scripts/verify_setup.sh"
echo "============================================"