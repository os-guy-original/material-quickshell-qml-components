#!/bin/bash
# Desktop Application Scanner - Optimized for speed
# Implements Freedesktop Desktop Entry Specification (DES)
# Supports: Native, Flatpak, and Snap applications

# XDG paths
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Build search paths
SEARCH_PATHS=("$XDG_DATA_HOME/applications")
IFS=':' read -ra SYSTEM_DIRS <<< "$XDG_DATA_DIRS"
for dir in "${SYSTEM_DIRS[@]}"; do
    [ -d "$dir/applications" ] && SEARCH_PATHS+=("$dir/applications")
done

# Add Flatpak paths if available
if command -v flatpak &>/dev/null; then
    [ -d "$HOME/.local/share/flatpak/exports/share/applications" ] && \
        SEARCH_PATHS+=("$HOME/.local/share/flatpak/exports/share/applications")
    [ -d "/var/lib/flatpak/exports/share/applications" ] && \
        SEARCH_PATHS+=("/var/lib/flatpak/exports/share/applications")
fi

# Add Snap paths if available
if command -v snap &>/dev/null; then
    [ -d "/var/lib/snapd/desktop/applications" ] && \
        SEARCH_PATHS+=("/var/lib/snapd/desktop/applications")
fi

# Associative array for deduplication
declare -A SEEN

# Output JSON array
echo "["
FIRST=true

# Process each directory
for search_dir in "${SEARCH_PATHS[@]}"; do
    [ ! -d "$search_dir" ] && continue
    
    # Use find for reliable file listing
    while IFS= read -r -d '' f; do
        ID=$(basename "$f" .desktop)
        [ -n "${SEEN[$ID]}" ] && continue
        SEEN[$ID]=1
        
        # Read and parse in one pass
        unset TYPE NAME GENERIC_NAME COMMENT ICON EXEC TERMINAL NO_DISPLAY HIDDEN CATEGORIES
        
        while IFS='=' read -r key value; do
            value=$(echo "$value" | tr -d '\r')
            case "$key" in
                Type) TYPE="$value" ;;
                Name) [ -z "$NAME" ] && NAME="$value" ;;
                GenericName) GENERIC_NAME="$value" ;;
                Comment) COMMENT="$value" ;;
                Icon) ICON="$value" ;;
                Exec) EXEC="$value" ;;
                Terminal) TERMINAL="$value" ;;
                NoDisplay) NO_DISPLAY="$value" ;;
                Hidden) HIDDEN="$value" ;;
                Categories) CATEGORIES="$value" ;;
            esac
        done < <(grep -E "^(Type|Name|GenericName|Comment|Icon|Exec|Terminal|NoDisplay|Hidden|Categories)=" "$f")
        
        # Validate per DES requirements
        [ "$TYPE" != "Application" ] && continue
        [ -z "$NAME" ] && continue
        [ -z "$EXEC" ] && continue
        [ "$NO_DISPLAY" = "true" ] && continue
        [ "$HIDDEN" = "true" ] && continue
        
        # Escape for JSON
        NAME="${NAME//\\/\\\\}"; NAME="${NAME//\"/\\\"}"
        GENERIC_NAME="${GENERIC_NAME//\\/\\\\}"; GENERIC_NAME="${GENERIC_NAME//\"/\\\"}"
        COMMENT="${COMMENT//\\/\\\\}"; COMMENT="${COMMENT//\"/\\\"}"
        EXEC="${EXEC//\\/\\\\}"; EXEC="${EXEC//\"/\\\"}"
        
        # Output JSON
        [ "$FIRST" = false ] && echo ","
        FIRST=false
        
        printf '  {"id":"%s","name":"%s","genericName":"%s","comment":"%s","icon":"%s","exec":"%s","terminal":%s,"categories":"%s","filePath":"%s"}' \
            "$ID" "$NAME" "$GENERIC_NAME" "$COMMENT" "$ICON" "$EXEC" \
            "$([ "$TERMINAL" = "true" ] && echo "true" || echo "false")" \
            "${CATEGORIES%;}" "$f"
    done < <(find "$search_dir" -maxdepth 1 -name "*.desktop" \( -type f -o -type l \) -print0 2>/dev/null)
done

echo ""
echo "]"
