#!/bin/bash
# flash.sh — Flash a compiled .elf file to the Nucleo C562RE
# Usage: bash scripts/flash.sh path/to/firmware.elf

set -e

ELF_FILE="${1}"

if [ -z "$ELF_FILE" ]; then
    echo "Usage: $0 <path/to/firmware.elf>"
    echo "Example: $0 sections/04-tasks/exercises/ex001_two_tasks/Debug/ex001.elf"
    exit 1
fi

if [ ! -f "$ELF_FILE" ]; then
    echo "❌ File not found: $ELF_FILE"
    exit 1
fi

echo "🔌 Checking ST-LINK connection..."
st-info --probe
echo ""

echo "⚡ Flashing: $ELF_FILE"
st-flash --reset write "$ELF_FILE" 0x08000000

echo ""
echo "✅ Flash complete! Board should be running now."
echo "   Open monitor: bash scripts/monitor.sh"