#!/bin/bash
# verify_setup.sh — Pre-flight check before starting exercises
# Run this after setup_ubuntu.sh and after logging back in

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     NUCLEO-C562RE Setup Verification         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"   # "ok" or "fail"
    local detail="$3"
    if [ "$result" = "ok" ]; then
        echo "  ✅  $label"
        [ -n "$detail" ] && echo "       $detail"
        PASS=$((PASS+1))
    else
        echo "  ❌  $label"
        [ -n "$detail" ] && echo "       FIX: $detail"
        FAIL=$((FAIL+1))
    fi
}

# ARM toolchain
if command -v arm-none-eabi-gcc &> /dev/null; then
    VER=$(arm-none-eabi-gcc --version | head -1 | awk '{print $NF}')
    check "ARM GCC cross-compiler" "ok" "Version $VER"
else
    check "ARM GCC cross-compiler" "fail" "sudo apt install gcc-arm-none-eabi"
fi

# STM32CubeProgrammer
PROG_PATH="$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI"
if command -v STM32_Programmer_CLI &> /dev/null || [ -f "$PROG_PATH" ]; then
    check "STM32CubeProgrammer CLI" "ok" "Found at path"
else
    check "STM32CubeProgrammer CLI" "fail" "Install from st.com/stm32cubeprog then run setup_ubuntu.sh"
fi

# User groups
if groups | grep -q "plugdev"; then
    check "plugdev group" "ok" "USB device access enabled"
else
    check "plugdev group" "fail" "sudo usermod -aG plugdev \$USER then re-login"
fi

if groups | grep -q "dialout"; then
    check "dialout group" "ok" "Serial port access enabled"
else
    check "dialout group" "fail" "sudo usermod -aG dialout \$USER then re-login"
fi

# udev rules
if [ -f "/etc/udev/rules.d/49-stlink.rules" ]; then
    if grep -q "3754" /etc/udev/rules.d/49-stlink.rules; then
        check "ST-LINK V3 udev rule (0483:3754)" "ok" "Your board's USB ID is covered"
    else
        check "ST-LINK V3 udev rule (0483:3754)" "fail" "Rule file exists but missing 3754 entry — re-run setup_ubuntu.sh"
    fi
else
    check "ST-LINK V3 udev rule" "fail" "Run: bash scripts/setup_ubuntu.sh"
fi

# Board connected?
echo ""
echo "── Board detection ─────────────────────────────────"
if lsusb | grep -q "0483:3754"; then
    STLINK_LINE=$(lsusb | grep "0483:3754")
    check "ST-LINK V3 on USB" "ok" "$STLINK_LINE"
else
    check "ST-LINK V3 on USB" "fail" "Plug in the Nucleo C562RE via USB-C cable"
fi

if ls /dev/ttyACM* &> /dev/null 2>&1; then
    PORT=$(ls /dev/ttyACM* | head -1)
    check "Virtual COM port" "ok" "$PORT available"
    # Check we can actually access it
    if [ -r "$PORT" ] && [ -w "$PORT" ]; then
        check "COM port permissions" "ok" "Read/write access confirmed"
    else
        check "COM port permissions" "fail" "Re-login after adding to dialout group"
    fi
else
    check "Virtual COM port" "fail" "Board not detected or not plugged in (/dev/ttyACM* missing)"
fi

# Git submodules
echo ""
echo "── Submodules ──────────────────────────────────────"
if [ -f "tools/build_tools/README.md" ] || [ -d "tools/build_tools/CMake" ]; then
    check "build_tools submodule" "ok" "tools/build_tools/ populated"
else
    check "build_tools submodule" "fail" "git submodule update --init --recursive"
fi

echo ""
echo "────────────────────────────────────────────────────"
echo "  Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
    echo ""
    echo "  🎉 All checks passed — ready to start exercises!"
else
    echo ""
    echo "  ⚠  Fix the $FAIL item(s) above before starting."
fi
echo ""