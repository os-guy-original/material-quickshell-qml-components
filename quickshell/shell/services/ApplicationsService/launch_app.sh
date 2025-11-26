#!/bin/bash
# Application Launcher - Handles desktop entry execution
# Supports: Native, Flatpak, and Snap applications
# Usage: launch_app.sh <desktop-file-id>

DESKTOP_ID="$1"

if [ -z "$DESKTOP_ID" ]; then
    echo "Usage: $0 <desktop-file-id>" >&2
    exit 1
fi

# Detect and handle Flatpak apps
if [[ "$DESKTOP_ID" =~ ^.*\.desktop$ ]] && command -v flatpak &>/dev/null; then
    # Extract app ID from desktop file name (e.g., com.spotify.Client.desktop -> com.spotify.Client)
    FLATPAK_ID="${DESKTOP_ID%.desktop}"
    if flatpak list --app --columns=application 2>/dev/null | grep -q "^${FLATPAK_ID}$"; then
        flatpak run "$FLATPAK_ID" &>/dev/null &
        exit 0
    fi
fi

# Detect and handle Snap apps
if [[ "$DESKTOP_ID" =~ ^.*_.*\.desktop$ ]] && command -v snap &>/dev/null; then
    # Snap desktop files are named like: appname_appname.desktop
    SNAP_NAME="${DESKTOP_ID%%_*}"
    if snap list 2>/dev/null | grep -q "^${SNAP_NAME} "; then
        snap run "$SNAP_NAME" &>/dev/null &
        exit 0
    fi
fi

# Try gtk-launch first (most reliable for native apps)
if command -v gtk-launch &>/dev/null; then
    gtk-launch "$DESKTOP_ID" &>/dev/null &
    exit 0
fi

# Fallback: Find and parse the desktop file manually
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Search for desktop file
DESKTOP_FILE=""
for dir in "$XDG_DATA_HOME/applications" ${XDG_DATA_DIRS//:/ }; do
    if [ -f "$dir/applications/$DESKTOP_ID.desktop" ]; then
        DESKTOP_FILE="$dir/applications/$DESKTOP_ID.desktop"
        break
    fi
done

if [ -z "$DESKTOP_FILE" ]; then
    echo "Desktop file not found: $DESKTOP_ID" >&2
    exit 1
fi

# Parse Exec and Terminal
EXEC=$(grep "^Exec=" "$DESKTOP_FILE" | head -1 | cut -d'=' -f2-)
TERMINAL=$(grep "^Terminal=" "$DESKTOP_FILE" | head -1 | cut -d'=' -f2-)

# Remove field codes
EXEC=$(echo "$EXEC" | sed 's/%[fFuUick]//g')

# Handle Terminal=true
if [ "$TERMINAL" = "true" ]; then
    TERM_CMD="${TERMINAL:-kitty}"
    $TERM_CMD -e sh -c "$EXEC" &>/dev/null &
else
    # Launch detached
    sh -c "$EXEC" &>/dev/null &
fi

exit 0
