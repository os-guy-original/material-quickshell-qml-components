pragma Singleton

import QtQuick 2.15
import Quickshell
import Quickshell.Io

/**
 * UserService - Provides user information
 * 
 * Usage:
 *   import "../../services/UserService" as UserSvc
 *   
 *   Text { text: UserSvc.UserService.fullName }
 */
QtObject {
    id: userService
    
    // User properties
    property string username: ""
    property string fullName: ""
    property string home: ""
    property string shell: ""
    property int uid: 0
    property int gid: 0
    property string avatarPath: ""
    property bool loaded: false
    property string error: ""
    
    // Avatar URL for QML Image components
    property string avatarUrl: avatarPath !== "" ? "file://" + avatarPath : ""
    
    property bool isShuttingDown: false
    
    property var getUserNameProc: Process {
        command: ["sh", Qt.resolvedUrl("get_user_name.sh").toString().replace("file://", "")]
        running: !userService.isShuttingDown
        
        stdout: SplitParser {
            onRead: function(data) {
                if (userService.isShuttingDown) return
                
                var name = data.trim()
                if (name && name !== "") {
                    userService.fullName = name
                } else {
                    // Fallback to capitalized username
                    userService.fullName = userService.username.charAt(0).toUpperCase() + userService.username.slice(1)
                }
            }
        }
        
        onExited: function(exitCode) {
            if (userService.isShuttingDown) return
            // Process completed normally
        }
    }
    
    Component.onDestruction: {
        isShuttingDown = true
        try {
            getUserNameProc.running = false
        } catch (e) {
            // Ignore errors during shutdown
        }
    }
    
    Component.onCompleted: {
        loadUserInfo()
    }
    
    function loadUserInfo() {
        // Get basic info from environment
        username = Quickshell.env("USER") || "user"
        home = Quickshell.env("HOME") || ""
        shell = Quickshell.env("SHELL") || ""
        
        // Get UID and GID from environment (set by system)
        var uidStr = Quickshell.env("UID")
        var gidStr = Quickshell.env("GID")
        uid = uidStr ? parseInt(uidStr) : 1000  // Default to 1000 if not set
        gid = gidStr ? parseInt(gidStr) : 1000
        
        // Full name will be set by the Process
        fullName = username.charAt(0).toUpperCase() + username.slice(1)  // Temporary until process completes
        
        // Check for avatar in common locations with various extensions
        avatarPath = "/var/lib/AccountsService/icons/" + username + ".png"
        
        loaded = true
    }
    
    // Refresh user info
    function refresh() {
        loaded = false
        loadUserInfo()
    }
}
