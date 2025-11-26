pragma Singleton
import QtQuick 2.15
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "." as Services

Item {
    id: root
    
    // Icon resolver for Flatpak icon fallback
    property var iconResolver: Services.IconResolverService
    
    // Assume conflict exists - user can manually check and kill if needed
    property bool serverRegistered: false
    property bool checkingForConflict: false
    property bool hasReceivedNotification: false
    
    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        persistenceSupported: true
        imageSupported: true
        actionIconsSupported: true
        inlineReplySupported: false
        keepOnReload: true
        
        onNotification: function(notification) {
            // console.log("Notification received:", notification.summary, "- Body:", notification.body)
            // console.log("  App Name:", notification.appName)
            // console.log("  App Icon:", notification.appIcon)
            // console.log("  Image:", notification.image)
            // console.log("  Resolved Icon:", getAppIcon(notification))
            notification.tracked = true
            // If we receive a notification, we're definitely registered
            root.serverRegistered = true
            root.hasReceivedNotification = true
        }
    }
    
    // Check for conflicts on startup
    Component.onCompleted: {
        checkForConflicts()
    }
    
    Process {
        id: checkProc
        command: ["sh", "-c", "pgrep -x dunst || pgrep -x mako || pgrep -x swaync || pgrep -f 'deadd-notification-center'"]
        
        onExited: function(exitCode) {
            // exitCode 0 means one of those processes is running (conflict exists)
            // exitCode 1 means no conflicts found (we can register)
            root.serverRegistered = (exitCode !== 0)
            root.checkingForConflict = false
            
            // If no conflicts, try to ensure server is active
            if (exitCode !== 0) {
                console.log("No conflicting notification daemons found")
            } else {
                console.log("Conflicting notification daemon detected")
            }
        }
    }
    
    function checkForConflicts() {
        checkingForConflict = true
        checkProc.running = true
    }
    
    // Expose the tracked notifications from the server
    readonly property alias notifications: server.trackedNotifications
    
    // Grouped notifications by app name
    property var groupedNotifications: ({})
    property var singleNotifications: []
    property int groupedNotificationsVersion: 0
    
    // Watch for notification changes and rebuild groups
    Connections {
        target: server.trackedNotifications
        function onValuesChanged() {
            rebuildGroups()
        }
    }
    
    function rebuildGroups() {
        var groups = {}
        var singles = []
        var notifs = server.trackedNotifications.values
        
        // Sort notifications by timestamp (newest first)
        if (notifs && notifs.length > 0) {
            notifs = notifs.slice().sort(function(a, b) {
                // Assuming notifications have a timestamp or id
                // If they have timestamp, use it; otherwise use creation order
                return (b.id || 0) - (a.id || 0)
            })
        }
        
        // First pass: count notifications per app
        var appCounts = {}
        if (notifs && notifs.length > 0) {
            for (var i = 0; i < notifs.length; i++) {
                var notif = notifs[i]
                var appName = notif.appName || "Unknown"
                appCounts[appName] = (appCounts[appName] || 0) + 1
            }
        }
        
        // Second pass: create groups for ALL apps (even with 1 notification)
        // The NotificationGroup component will handle single-mode display
        if (notifs && notifs.length > 0) {
            for (var i = 0; i < notifs.length; i++) {
                var notif = notifs[i]
                var appName = notif.appName || "Unknown"
                
                // Always create a group for each app
                if (!groups[appName]) {
                    groups[appName] = {
                        appName: appName,
                        appIcon: getAppIcon(notif),
                        notifications: [],
                        count: 0,
                        lastTimestamp: notif.id || 0
                    }
                }
                groups[appName].notifications.push(notif)
                groups[appName].count++
                // Track the most recent notification timestamp for sorting groups
                if ((notif.id || 0) > groups[appName].lastTimestamp) {
                    groups[appName].lastTimestamp = notif.id || 0
                }
            }
        }
        
        groupedNotifications = groups
        singleNotifications = singles
        groupedNotificationsVersion++
    }
    
    // Known problematic icons that crash Qt's icon provider
    property var _problematicIcons: [
        "org.kde.kdialog",
        "hyprland-share-picker"
    ]
    
    function getAppIcon(notification) {
        var iconPath = ""
        
        // Prefer the richer 'image' if available, otherwise use 'appIcon'
        if (notification.image && notification.image !== "") {
            iconPath = notification.image
        } else if (notification.appIcon && notification.appIcon !== "") {
            iconPath = notification.appIcon
        }
        
        if (!iconPath) return ""
        
        // Check if this is a known problematic icon
        for (var i = 0; i < _problematicIcons.length; i++) {
            if (iconPath.indexOf(_problematicIcons[i]) !== -1) {
                // console.log("Skipping problematic icon:", iconPath)
                return ""  // Return empty to use fallback
            }
        }
        
        // If it's already a full path or URL, return as-is
        if (iconPath.startsWith("/") || iconPath.startsWith("file://") || iconPath.startsWith("image://")) {
            return iconPath
        }
        
        // Otherwise it's an icon name - use Qt's icon provider
        return "image://icon/" + iconPath
    }
    
    function dismissNotification(notification) {
        notification.dismiss()
    }
    
    function dismissGroup(appName) {
        var group = groupedNotifications[appName]
        if (group && group.notifications) {
            for (var i = group.notifications.length - 1; i >= 0; i--) {
                group.notifications[i].dismiss()
            }
        }
    }
    
    function clearAll() {
        var tracked = server.trackedNotifications.values
        if (tracked && tracked.length > 0) {
            for (var i = tracked.length - 1; i >= 0; i--) {
                tracked[i].dismiss()
            }
        }
    }
    
    Process {
        id: killProc
    }
    
    function killConflictingDaemon() {
        // Kill common notification daemons
        killProc.command = ["sh", "-c", "pkill dunst; pkill mako; pkill swaync; pkill -f deadd-notification-center"]
        killProc.running = true
        
        // Wait for processes to die, then check again
        checkTimer.restart()
    }
    
    Timer {
        id: checkTimer
        interval: 1500
        running: false
        repeat: false
        onTriggered: {
            // Recheck for conflicts
            checkForConflicts()
            
            // Send a test notification after a bit more time
            testTimer.restart()
        }
    }
    
    Process {
        id: testProc
    }
    
    Timer {
        id: testTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            // Send a test notification to verify we're registered
            testProc.command = ["notify-send", "Notification Center", "Successfully registered!", "-t", "3000", "-u", "normal"]
            testProc.running = true
        }
    }
}
