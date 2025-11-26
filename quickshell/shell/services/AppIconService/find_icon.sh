#!/bin/bash
# Comprehensive icon finder - searches everywhere for an app icon
# Usage: find_icon.sh <app_name>
#
# Strategy:
# 1. Parse .desktop files to find the Icon field (like launchers do)
# 2. Search icon theme directories
# 3. Check pixmaps and flatpak exports
# 4. Try name variations for reverse domain names
# 5. Comprehensive find search as last resort

app_name="$1"

if [ -z "$app_name" ]; then
    echo "Error: No app name provided" >&2
    exit 1
fi

# Get the script's directory for recursive calls
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"

# Function to check if file exists and print it
check_and_print() {
    if [ -f "$1" ]; then
        echo "$1"
        exit 0
    fi
}

# Function to find and parse desktop file for Icon field
find_icon_from_desktop() {
    local search_name="$1"
    local desktop_file=""
    
    # Search for desktop file in common locations
    for desktop_dir in \
        "$HOME/.local/share/applications" \
        "/usr/share/applications" \
        "/usr/local/share/applications" \
        "$HOME/.local/share/flatpak/exports/share/applications" \
        "/var/lib/flatpak/exports/share/applications"; do
        
        if [ -d "$desktop_dir" ]; then
            # Try exact match first
            if [ -f "$desktop_dir/$search_name.desktop" ]; then
                desktop_file="$desktop_dir/$search_name.desktop"
                break
            fi
        fi
    done
    
    # If not found, try case-insensitive search
    if [ -z "$desktop_file" ]; then
        for desktop_dir in \
            "$HOME/.local/share/applications" \
            "/usr/share/applications" \
            "/usr/local/share/applications" \
            "$HOME/.local/share/flatpak/exports/share/applications" \
            "/var/lib/flatpak/exports/share/applications"; do
            
            if [ -d "$desktop_dir" ]; then
                desktop_file=$(find "$desktop_dir" -maxdepth 1 -iname "$search_name.desktop" -type f 2>/dev/null | head -n 1)
                if [ -n "$desktop_file" ]; then
                    break
                fi
            fi
        done
    fi
    
    # Parse Icon field from desktop file
    if [ -n "$desktop_file" ] && [ -f "$desktop_file" ]; then
        # Extract Icon= line (first occurrence in [Desktop Entry] section)
        local icon_name=$(grep -m 1 "^Icon=" "$desktop_file" | cut -d'=' -f2- | tr -d '\r\n')
        if [ -n "$icon_name" ]; then
            echo "$icon_name"
            return 0
        fi
    fi
    
    return 1
}

# STEP 0: Try to get icon name from desktop file
desktop_icon=$(find_icon_from_desktop "$app_name")
if [ -n "$desktop_icon" ]; then
    # If it's an absolute path, use it directly
    if [[ "$desktop_icon" == /* ]]; then
        check_and_print "$desktop_icon"
    else
        # Otherwise, use it as the search name
        app_name="$desktop_icon"
    fi
fi

# Get current icon theme
icon_theme=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
[ -z "$icon_theme" ] && icon_theme="hicolor"

# Common icon sizes to check
sizes="scalable 256x256 128x128 96x96 64x64 48x48 32x32 24x24 22x22 16x16"

# Icon extensions
exts="svg png xpm"

# 1. Check XDG icon theme directories
for theme_dir in \
    "$HOME/.local/share/icons/$icon_theme" \
    "$HOME/.icons/$icon_theme" \
    "/usr/share/icons/$icon_theme" \
    "$HOME/.local/share/icons/hicolor" \
    "$HOME/.icons/hicolor" \
    "/usr/share/icons/hicolor"; do
    
    if [ -d "$theme_dir" ]; then
        for size in $sizes; do
            for context in apps applications; do
                for ext in $exts; do
                    check_and_print "$theme_dir/$size/$context/$app_name.$ext"
                done
            done
        done
    fi
done

# 2. Check pixmaps directory
for ext in $exts; do
    check_and_print "/usr/share/pixmaps/$app_name.$ext"
    check_and_print "$HOME/.local/share/pixmaps/$app_name.$ext"
done

# 3. Check flatpak exports
for ext in $exts; do
    check_and_print "$HOME/.local/share/flatpak/exports/share/icons/hicolor/scalable/apps/$app_name.$ext"
    check_and_print "/var/lib/flatpak/exports/share/icons/hicolor/scalable/apps/$app_name.$ext"
    
    for size in $sizes; do
        check_and_print "$HOME/.local/share/flatpak/exports/share/icons/hicolor/$size/apps/$app_name.$ext"
        check_and_print "/var/lib/flatpak/exports/share/icons/hicolor/$size/apps/$app_name.$ext"
    done
done

# 4. Try variations of the app name
# For "org.gnome.Nautilus", try "nautilus", "Nautilus", "org-gnome-nautilus"
if [[ "$app_name" == *.* ]]; then
    # Extract last part (e.g., "Nautilus" from "org.gnome.Nautilus")
    last_part="${app_name##*.}"
    lowercase_last="${last_part,,}"
    
    # Try lowercase version
    if [ "$lowercase_last" != "$app_name" ]; then
        "$SCRIPT_PATH" "$lowercase_last" && exit 0
    fi
    
    # Try with dashes
    dashed="${app_name//./-}"
    dashed_lower="${dashed,,}"
    if [ "$dashed_lower" != "$app_name" ]; then
        "$SCRIPT_PATH" "$dashed_lower" && exit 0
    fi
fi

# 5. Search using find (slower but comprehensive)
for base_dir in \
    "$HOME/.local/share/icons" \
    "$HOME/.icons" \
    "/usr/share/icons" \
    "/usr/share/pixmaps" \
    "$HOME/.local/share/flatpak/exports/share/icons" \
    "/var/lib/flatpak/exports/share/icons"; do
    
    if [ -d "$base_dir" ]; then
        result=$(find "$base_dir" -type f \( -name "$app_name.svg" -o -name "$app_name.png" -o -name "$app_name.xpm" \) 2>/dev/null | head -n 1)
        if [ -n "$result" ]; then
            echo "$result"
            exit 0
        fi
    fi
done

# Not found
exit 1
