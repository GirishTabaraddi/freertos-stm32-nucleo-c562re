#!/bin/bash
# flash.sh — Flash firmware to NUCLEO-C562RE using STM32CubeProgrammer
#
# Usage:
#   bash scripts/flash.sh path/to/firmware.elf
#   bash scripts/flash.sh path/to/firmware.bin   (also works)

set -e

ELF_FILE="${1}"

if [ -z "$ELF_FILE" ]; then
    echo "Usage: $0 <path/to/firmware.elf>"
    echo ""
    echo "Examples:"
    echo "  $0 sections/04-tasks/exercises/ex001_two_tasks/Debug/ex001_two_tasks.elf"
    echo "  $0 sections/03-freertos-integration/exercises/ex001_hello_freertos/Debug/*.elf"
    exit 1
fi

if [ ! -f "$ELF_FILE" ]; then
    echo "❌ File not found: $ELF_FILE"
    echo "   Did you build the project first? (Ctrl+B in STM32CubeIDE)"
    exit 1
fi

# ── Find STM32_Programmer_CLI ─────────────────────────────────────────────────
PROGRAMMER=""

# Check PATH first
if command -v STM32_Programmer_CLI &> /dev/null; then
    PROGRAMMER="STM32_Programmer_CLI"
fi

# Check default install location
DEFAULT_PATH="$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI"
if [ -z "$PROGRAMMER" ] && [ -f "$DEFAULT_PATH" ]; then
    PROGRAMMER="$DEFAULT_PATH"
fi

if [ -z "$PROGRAMMER" ]; then
    echo "❌ STM32_Programmer_CLI not found."
    echo ""
    echo "Install STM32CubeProgrammer from:"
    echo "  https://www.st.com/en/development-tools/stm32cubeprog.html"
    echo ""
    echo "Then run: bash scripts/setup_ubuntu.sh"
    exit 1
fi

# ── Check board is connected ──────────────────────────────────────────────────
echo "🔍 Checking board connection..."
if ! lsusb | grep -q "0483:3754"; then
    echo "⚠  ST-LINK V3 (0483:3754) not detected on USB."
    echo "   Is the Nucleo plugged in?"
    lsusb | grep -i "st" || echo "   No ST devices found at all."
    echo ""
    echo "   Trying to flash anyway..."
fi

# ── Flash ─────────────────────────────────────────────────────────────────────
echo ""
echo "⚡ Flashing: $(basename $ELF_FILE)"
echo "   Tool: $PROGRAMMER"
echo ""

"$PROGRAMMER" \
    -c port=SWD freq=4000 reset=HWrst \
    -w "$ELF_FILE" \
    -v \
    -rst

echo ""
echo "✅ Flash complete! Board is running."
echo "   Open monitor: bash scripts/monitor.sh"
