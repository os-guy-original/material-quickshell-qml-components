#!/bin/bash
# Test script for QuickShell AppLauncher keybinding

echo "=== QuickShell Keybinding Test ==="
echo ""

# Check if QuickShell is running
echo "1. Checking if QuickShell is running..."
if pgrep -x quickshell > /dev/null; then
    echo "   ✓ QuickShell is running (PID: $(pgrep -x quickshell))"
else
    echo "   ✗ QuickShell is NOT running"
    echo "   → Start QuickShell first"
    exit 1
fi
echo ""

# Check if Hyprland is running
echo "2. Checking if Hyprland is running..."
if pgrep -x Hyprland > /dev/null; then
    echo "   ✓ Hyprland is running"
else
    echo "   ✗ Hyprland is NOT running"
    echo "   → This keybinding only works with Hyprland"
    exit 1
fi
echo ""

# Check global shortcuts registration
echo "3. Checking global shortcuts registration..."
if hyprctl globalshortcuts | grep -q "quickshell:toggle-launcher"; then
    echo "   ✓ Global shortcut is registered:"
    hyprctl globalshortcuts | grep "quickshell:toggle-launcher" | sed 's/^/     /'
else
    echo "   ✗ Global shortcut NOT registered"
    echo "   → Check QuickShell logs for errors"
    echo "   → Make sure Shell.qml has the GlobalShortcut defined"
    exit 1
fi
echo ""

# Check Hyprland config
echo "4. Checking Hyprland config..."
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
    if grep -q "quickshell:toggle-launcher" "$HYPR_CONF"; then
        echo "   ✓ Keybinding found in hyprland.conf:"
        grep "quickshell:toggle-launcher" "$HYPR_CONF" | sed 's/^/     /'
    else
        echo "   ✗ Keybinding NOT found in hyprland.conf"
        echo "   → Add this line to $HYPR_CONF:"
        echo "     bind = SUPER, SUPER_L, global, quickshell:toggle-launcher"
        echo ""
        echo "   Then reload Hyprland:"
        echo "     hyprctl reload"
        exit 1
    fi
else
    echo "   ⚠ Could not find hyprland.conf at $HYPR_CONF"
fi
echo ""

# Check active binds
echo "5. Checking active Hyprland binds..."
if hyprctl binds | grep -q "quickshell:toggle-launcher"; then
    echo "   ✓ Keybinding is active in Hyprland"
else
    echo "   ⚠ Keybinding not found in active binds"
    echo "   → Try reloading Hyprland config:"
    echo "     hyprctl reload"
fi
echo ""

echo "=== Test Complete ==="
echo ""
echo "If all checks passed, press the Super key to test the launcher."
echo "If it doesn't work, check QuickShell logs for errors."
echo ""
echo "To see QuickShell logs, run QuickShell from terminal:"
echo "  quickshell"
