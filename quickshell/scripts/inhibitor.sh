#!/bin/bash

# Configuration
LOCK_FILE="/tmp/systemd-inhibitor-lock"
INHIBIT_REASON="Scripted toggle for OpenSource Guy"

# --- Main Logic ---

if [ "$1" == "--toggle" ]; then
    # --- Toggle Operation ---

    if [ -f "$LOCK_FILE" ]; then
        # Inhibitor is ON -> Turn OFF
        
        # Check if the PID file exists and contains a valid PID
        if [ -s "$LOCK_FILE" ]; then
            INHIBITOR_PID=$(cat "$LOCK_FILE")
            
            # Kill the background process holding the lock
            kill $INHIBITOR_PID 2>/dev/null
        fi

        # Remove the lock file regardless of kill success
        rm -f "$LOCK_FILE"
        
        # Output the new state
        echo "off"
        exit 0
    else
        # Inhibitor is OFF -> Turn ON
        
        # Run systemd-inhibit in the background
        # We use 'sleep infinity' to keep the lock held indefinitely
        systemd-inhibit --what=sleep:shutdown --who=OpenSourceGuy \
            --why="$INHIBIT_REASON" --mode=block sleep infinity &
        
        INHIBITOR_PID=$!
        if [ -n "$INHIBITOR_PID" ] && [ "$INHIBITOR_PID" -gt 0 ]; then
            echo "$INHIBITOR_PID" > "$LOCK_FILE"
            # Output the new state
            echo "on"
            exit 0
        else
            # Failed to activate inhibitor (e.g., systemd-inhibit failed)
            echo "error" >&2
            exit 1
        fi
    fi
else
    # --- State Check Operation (Default) ---
    
    if [ -f "$LOCK_FILE" ]; then
        # Inhibitor is ON
        echo "on"
        exit 0
    else
        # Inhibitor is OFF
        echo "off"
        exit 0 # Success exit code 0 to prevent shell error messages
    fi
fi
