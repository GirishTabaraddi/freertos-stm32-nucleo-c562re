#!/bin/bash
# setup_ubuntu.sh — Install all dependencies for FreeRTOS course on Ubuntu
# Run once after cloning the repo: bash scripts/setup_ubuntu.sh

set -e   # Exit on any error

echo "============================================"
echo " FreeRTOS STM32 Course — Ubuntu Setup"
echo " Board: NUCLEO-C562RE"
echo "============================================"

# ── System packages ────────────────────────────────────────────────────────────
echo "[1/7] Installing system packages..."
sudo apt update
sudo apt install -y \
    git git-lfs \
    cmake make \
    gcc-arm-none-eabi binutils-arm-none-eabi \
    libusb-1.0-0 libusb-dev \
    minicom screen \
    python3 python3-pip python3-venv \
    curl wget unzip \
    stlink-tools \
    openocd \
    openjdk-17-jdk

# ── STM32 udev rules for ST-LINK/V3 ───────────────────────────────────────────
echo "[2/7] Installing ST-LINK udev rules..."
RULES_URL="https://raw.githubusercontent.com/stlink-org/stlink/master/config/udev/rules.d"
sudo wget -q -O /etc/udev/rules.d/49-stlinkv3.rules \
    "${RULES_URL}/49-stlinkv3.rules"
sudo wget -q -O /etc/udev/rules.d/49-stlinkv2.rules \
    "${RULES_URL}/49-stlinkv2.rules"
sudo udevadm control --reload-rules
sudo udevadm trigger
echo "  → udev rules installed"

# ── User groups ───────────────────────────────────────────────────────────────
echo "[3/7] Adding user to required groups..."
sudo usermod -aG plugdev "$USER"
sudo usermod -aG dialout "$USER"
echo "  → Added to plugdev and dialout (re-login required)"

# ── Git LFS ───────────────────────────────────────────────────────────────────
echo "[4/7] Initializing Git LFS..."
git lfs install
echo "  → Git LFS ready (use for large binaries like .SVDat recordings)"

# ── ARM toolchain version check ───────────────────────────────────────────────
echo "[5/7] Checking ARM toolchain..."
arm-none-eabi-gcc --version
arm-none-eabi-gdb --version || echo "  ℹ arm-none-eabi-gdb not found (optional)"

# ── Python requirements ───────────────────────────────────────────────────────
echo "[6/7] Setting up Python environment..."
if [ -f "tools/build_tools/Python/requirements.txt" ]; then
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r tools/build_tools/Python/requirements.txt
    echo "  → Python venv created at .venv/"
else
    echo "  ℹ No requirements.txt found in build_tools/Python/ — skipping venv"
fi

# ── Submodule initialization ───────────────────────────────────────────────────
echo "[7/7] Initializing git submodules..."
git submodule update --init --recursive
echo "  → Submodules initialized: build_tools + FreeRTOS-Kernel"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo " ✅ Setup complete!"
echo ""
echo " NEXT STEPS:"
echo "  1. Log out and back in (for group changes)"
echo "  2. Plug in your Nucleo C562RE"
echo "  3. Run: bash scripts/flash.sh to test connection"
echo "  4. Open STM32CubeIDE from /opt/st/"
echo ""
echo " VERIFY BOARD CONNECTION:"
echo "  lsusb | grep STM"
echo "  ls /dev/ttyACM*"
echo "============================================"