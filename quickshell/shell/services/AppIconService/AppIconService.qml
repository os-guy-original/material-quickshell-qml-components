pragma Singleton

import QtQuick 2.15
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland as Hypr

/**
 * AppIconService - Centralized service for app icon management
 * Uses Hyprland's lastIpcObject for window class data
 * 
 * Icon Resolution Strategy:
 * Uses a comprehensive shell script that:
 * 1. Parses .desktop files to find the Icon field (like launchers do)
 * 2. Searches icon theme directories
 * 3. Checks pixmaps and flatpak exports
 * 4. Tries name variations for reverse domain names
 * 5. Comprehensive find search as last resort
 * 
 * This approach mirrors how desktop launchers find icons, ensuring
 * apps like org.gnome.Nautilus are properly detected.
 */
QtObject {
    id: appIconService
    
    property bool isShuttingDown: false
    property var iconCache: ({})
    property var pendingRequests: ({})
    property int iconCacheVersion: 0  // Increment to trigger updates
    
    // Monitor active toplevel changes to refresh lastIpcObject
    property Connections activeToplevelMonitor: Connections {
        target: Hypr.Hyprland
        function onActiveToplevelChanged() {
            // Refresh toplevels to ensure lastIpcObject is up to date
            Hypr.Hyprland.refreshToplevels()
        }
    }
    
    property Component iconSearchComponent: Component {
        Process {
            id: proc
            property string searchName: ""
            property string scriptPath: ""
            
            command: ["bash", scriptPath, searchName]
            running: true
            
            stdout: SplitParser {
                onRead: function(data) {
                    var iconPath = data.trim()
                    if (iconPath && iconPath !== "") {
                        var fileUrl = "file://" + iconPath
                        appIconService.iconCache[proc.searchName] = fileUrl
                        delete appIconService.pendingRequests[proc.searchName]
                        appIconService.iconCacheVersion++
                    }
                }
            }
            
            stderr: SplitParser {
                onRead: function(data) {
                    // Ignore stderr
                }
            }
            
            onExited: function(exitCode) {
                if (exitCode !== 0) {
                    // Icon not found, cache empty result
                    appIconService.iconCache[proc.searchName] = ""
                    delete appIconService.pendingRequests[proc.searchName]
                }
                proc.destroy()
            }
        }
    }
    
    /**
     * Get icon from a toplevel window
     */
    function getTopLevelIcon(toplevel) {
        if (!toplevel) return ""
        
        var iconName = extractIconName(toplevel)
        
        // If no class found, try using the title
        if (!iconName && toplevel.title) {
            iconName = toplevel.title.toString().trim().toLowerCase()
        }
        
        if (!iconName) return ""
        
        return resolveIcon(iconName)
    }
    
    /**
     * Get a random app icon from currently open windows
     */
    function getRandomAppIcon() {
        try {
            if (!Hypr.Hyprland || !Hypr.Hyprland.toplevels) return ""
            
            var toplevels = Hypr.Hyprland.toplevels.values
            if (!toplevels || toplevels.length === 0) return ""
            
            var randomIndex = Math.floor(Math.random() * toplevels.length)
            return getTopLevelIcon(toplevels[randomIndex])
        } catch (e) {
            return ""
        }
    }
    
    /**
     * Get icon by app name/class
     */
    function getAppIcon(appName) {
        if (!appName) return ""
        return resolveIcon(appName)
    }
    
    /**
     * Get icon for a specific workspace (shows focused window icon)
     */
    function getWorkspaceIcon(workspaceId) {
        try {
            if (!Hypr.Hyprland || !Hypr.Hyprland.toplevels) return ""
            
            var toplevels = Hypr.Hyprland.toplevels.values
            if (!toplevels || toplevels.length === 0) return ""
            
            // First, check if the active toplevel is in this workspace
            var activeToplevel = Hypr.Hyprland.activeToplevel
            if (activeToplevel && activeToplevel.workspace && activeToplevel.workspace.id === workspaceId) {
                return getTopLevelIcon(activeToplevel)
            }
            
            // Fallback: find any window in this workspace
            for (var i = 0; i < toplevels.length; i++) {
                var toplevel = toplevels[i]
                if (toplevel && toplevel.workspace && toplevel.workspace.id === workspaceId) {
                    return getTopLevelIcon(toplevel)
                }
            }
            
            return ""
        } catch (e) {
            return ""
        }
    }
    
    /**
     * Extract icon name from toplevel using lastIpcObject
     * Falls back to title if it looks like an app identifier
     */
    function extractIconName(toplevel) {
        if (!toplevel) return ""
        
        try {
            if (toplevel.lastIpcObject) {
                var ipc = toplevel.lastIpcObject
                
                if (ipc.initialClass && typeof ipc.initialClass === "string" && ipc.initialClass !== "") {
                    return ipc.initialClass
                }
                if (ipc.class && typeof ipc.class === "string" && ipc.class !== "") {
                    return ipc.class
                }
            }
            
            // Fallback: use title if it looks like an app identifier
            if (toplevel.title) {
                var title = toplevel.title.toString().trim()
                
                if (title.indexOf(".") !== -1 || title.indexOf("_") !== -1) {
                    return title
                }
            }
        } catch (e) {
            return ""
        }
        
        return ""
    }
    
    /**
     * Resolve icon - try Quickshell first, then script as fallback
     * Tries multiple variations for names with spaces (e.g., "GitHub Desktop" -> "github-desktop")
     */
    function resolveIcon(iconName) {
        if (!iconName) return ""
        
        // Check cache first
        if (iconCache[iconName] !== undefined) {
            return iconCache[iconName]
        }
        
        // Guard invalid names
        if (iconName === "~" || iconName.indexOf("~") === 0) {
            iconCache[iconName] = ""
            return ""
        }
        
        // Handle absolute file paths
        if (iconName.indexOf("/") === 0) {
            var filePath = "file://" + iconName
            iconCache[iconName] = filePath
            return filePath
        }
        
        // Try Quickshell.iconPath with original name
        var resolved = Quickshell.iconPath(iconName, true)
        if (resolved) {
            iconCache[iconName] = resolved
            return resolved
        }
        
        // If name has spaces, try normalized variations
        if (iconName.indexOf(" ") !== -1) {
            // Try lowercase with hyphens: "GitHub Desktop" -> "github-desktop"
            var normalized = iconName.toLowerCase().replace(/ /g, "-")
            resolved = Quickshell.iconPath(normalized, true)
            if (resolved) {
                iconCache[iconName] = resolved
                return resolved
            }
            
            // Try lowercase without spaces: "GitHub Desktop" -> "githubdesktop"
            var noSpaces = iconName.toLowerCase().replace(/ /g, "")
            resolved = Quickshell.iconPath(noSpaces, true)
            if (resolved) {
                iconCache[iconName] = resolved
                return resolved
            }
        }
        
        // Check if we already have a pending request for this icon
        if (pendingRequests[iconName]) {
            return ""
        }
        
        // Mark as pending and start async search with script
        pendingRequests[iconName] = true
        searchIconWithScript(iconName)
        
        return ""
    }
    
    /**
     * Use shell script to comprehensively search for icon (async)
     */
    function searchIconWithScript(iconName) {
        if (!iconName || isShuttingDown) return
        
        var scriptPath = Qt.resolvedUrl("find_icon.sh").toString().replace("file://", "")
        var proc = iconSearchComponent.createObject(appIconService, {
            searchName: iconName,
            scriptPath: scriptPath
        })
    }
    
    function markIconInvalid(iconName) {
        if (iconName) {
            iconCache[iconName] = ""
            delete pendingRequests[iconName]
        }
    }
    
    Component.onDestruction: {
        isShuttingDown = true
    }
}
