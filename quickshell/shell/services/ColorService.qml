pragma Singleton

import QtQuick 2.15
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    signal colorsChanged()
    
    property int refreshCounter: 0
    property string colorsFilePath: {
        var url = Qt.resolvedUrl("../../resources/colors.js")
        return url.replace("file://", "")
    }
    
    // Track if a reload is pending to avoid multiple reloads
    property bool reloadPending: false
    property bool isShuttingDown: false
    
    Process {
        id: watcherProcess
        command: ["inotifywait", "-m", "-e", "close_write,modify", root.colorsFilePath]
        running: !root.isShuttingDown
        
        stdout: SplitParser {
            onRead: function(data) {
                if (root.isShuttingDown || root.reloadPending) {
                    return
                }
                
                console.log("ColorService: colors.js modified, scheduling reload...")
                root.reloadPending = true
                reloadTimer.restart()
            }
        }
        
        onExited: function(exitCode) {
            if (root.isShuttingDown) return
            
            if (exitCode !== 0) {
                console.warn("ColorService: inotifywait exited with code", exitCode, "- restarting...")
                restartTimer.start()
            }
        }
    }
    
    // Restart watcher if it crashes
    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: {
            console.log("ColorService: Restarting file watcher...")
            watcherProcess.running = true
        }
    }
    
    Timer {
        id: reloadTimer
        interval: 300
        onTriggered: {
            console.log("ColorService: Reloading QuickShell...")
            try {
                Quickshell.reload()
            } catch (e) {
                console.error("ColorService: Failed to reload:", e)
            } finally {
                // Reset pending flag after a delay to allow reload to complete
                Qt.callLater(function() {
                    root.reloadPending = false
                })
            }
        }
    }
    
    function forceRefresh() {
        if (root.reloadPending) {
            console.log("ColorService: Reload already pending")
            return
        }
        
        console.log("ColorService: Forcing shell reload...")
        root.reloadPending = true
        reloadTimer.restart()
    }
    
    Component.onCompleted: {
        console.log("ColorService initialized, watching:", colorsFilePath)
    }
    
    Component.onDestruction: {
        isShuttingDown = true
        restartTimer.stop()
        reloadTimer.stop()
        try {
            watcherProcess.running = false
        } catch (e) {
            // Ignore errors during shutdown
        }
    }
}
