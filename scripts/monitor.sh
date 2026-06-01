#!/bin/bash
# monitor.sh — Open serial monitor for Nucleo C562RE
# Connects to /dev/ttyACM0 at 115200 baud

BAUD="${1:-115200}"
PORT="${2:-/dev/ttyACM0}"

if [ ! -c "$PORT" ]; then
    echo "❌ Port $PORT not found."
    echo "   Available ports:"
    ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo "   None found — is Nucleo plugged in?"
    exit 1
fi

echo "📡 Connecting to $PORT @ ${BAUD} baud"
echo "   Press Ctrl+A then X to exit minicom"
echo ""

minicom -D "$PORT" -b "$BAUD" -o