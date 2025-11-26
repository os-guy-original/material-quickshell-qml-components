pragma Singleton

import QtQuick 2.15
import Quickshell
import Quickshell.Io

/**
 * ApplicationsService - Desktop Application Discovery and Management
 * 
 * Implements Freedesktop Desktop Entry Specification (DES) compliant
 * application discovery following XDG Base Directory standards.
 * 
 * Architecture:
 * - Uses shell script for efficient .desktop file scanning
 * - Parses and validates desktop entries per DES requirements
 * - Filters by Type=Application and NoDisplay=true
 * - Respects XDG directory precedence
 * 
 * Usage:
 *   import "../services" as Services
 *   
 *   Repeater {
 *       model: Services.ApplicationsService.applications
 *       delegate: Text { text: modelData.name }
 *   }
 */
QtObject {
    id: root
    
    // Public API
    property var applications: []
    property bool loading: true
    property string error: ""
    property bool useStreaming: false  // Disable streaming for now (can be enabled later)
    
    // Favorites and usage tracking
    property var favorites: []
    property var usageStats: ({})  // { appId: { count: number, lastUsed: timestamp } }
    property string statsFile: Qt.resolvedUrl("ApplicationsService/usage_stats.json").toString().replace("file://", "")
    
    // Signals
    signal applicationsUpdated()
    signal scanCompleted()
    signal favoritesUpdated()
    
    // Scanner process - uses Python for better performance
    property var scannerProcess: Process {
        command: useStreaming ? 
            ["python3", Qt.resolvedUrl("ApplicationsService/scan_applications_stream.py").toString().replace("file://", "")] :
            ["python3", Qt.resolvedUrl("ApplicationsService/scan_applications.py").toString().replace("file://", "")]
        running: false
        
        property string output: ""
        property string lineBuffer: ""
        
        stdout: SplitParser {
            onRead: function(data) {
                if (useStreaming) {
                    // Process line by line for streaming mode
                    scannerProcess.lineBuffer += data
                    var lines = scannerProcess.lineBuffer.split('\n')
                    
                    // Keep the last incomplete line in buffer
                    scannerProcess.lineBuffer = lines.pop()
                    
                    // Process complete lines
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i].trim()
                        if (line) {
                            try {
                                var app = JSON.parse(line)
                                var newApps = applications.slice()
                                newApps.push(app)
                                applications = newApps
                                applicationsUpdated()
                                console.log("ApplicationsService: Added app:", app.name, "- Total:", applications.length)
                            } catch (e) {
                                console.error("ApplicationsService: Failed to parse line:", e, "Line:", line.substring(0, 100))
                            }
                        }
                    }
                } else {
                    scannerProcess.output += data
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                if (useStreaming) {
                    // Process any remaining data in buffer
                    if (scannerProcess.lineBuffer.trim()) {
                        try {
                            var app = JSON.parse(scannerProcess.lineBuffer)
                            var newApps = applications.slice()
                            newApps.push(app)
                            applications = newApps
                        } catch (e) {
                            // Skip invalid JSON
                        }
                    }
                    loading = false
                    error = ""
                    console.log("ApplicationsService: Loaded", applications.length, "applications (streaming)")
                    applicationsUpdated()
                    scanCompleted()
                } else {
                    try {
                        var apps = JSON.parse(scannerProcess.output)
                        applications = apps
                        loading = false
                        error = ""
                        console.log("ApplicationsService: Loaded", applications.length, "applications")
                        applicationsUpdated()
                        scanCompleted()
                    } catch (e) {
                        error = "Failed to parse applications: " + e
                        console.error("ApplicationsService:", error)
                        loading = false
                    }
                }
            } else {
                error = "Scanner exited with code " + exitCode
                console.error("ApplicationsService:", error)
                loading = false
            }
            
            scannerProcess.output = ""
            scannerProcess.lineBuffer = ""
        }
    }
    
    Component.onCompleted: {
        loadUsageStats()
        loadApplications()
    }
    
    /**
     * Load applications by running scanner script
     */
    function loadApplications() {
        loading = true
        error = ""
        scannerProcess.running = true
    }
    
    /**
     * Launch an application by its entry
     */
    function launchApplication(entry) {
        if (!entry || !entry.id) {
            console.error("ApplicationsService: Invalid entry for launch")
            return false
        }
        
        console.log("ApplicationsService: Launching", entry.name, "(" + entry.id + ")")
        
        // Track usage
        trackUsage(entry.id)
        
        // Use launch script for proper desktop entry launching
        // This handles gtk-launch with fallback to manual parsing
        var launcher = Qt.createQmlObject(
            'import Quickshell.Io; Process { running: true }',
            root,
            "launcher_" + Date.now()
        )
        
        var scriptPath = Qt.resolvedUrl("ApplicationsService/launch_app.sh").toString().replace("file://", "")
        launcher.command = ["sh", scriptPath, entry.id]
        
        return true
    }
    
    /**
     * Search applications by query with smart sorting
     */
    function search(query) {
        var results
        if (!query) {
            results = applications.slice()
        } else {
            var lowerQuery = query.toLowerCase()
            results = applications.filter(function(app) {
                return app.name.toLowerCase().indexOf(lowerQuery) !== -1 ||
                       (app.genericName && app.genericName.toLowerCase().indexOf(lowerQuery) !== -1) ||
                       (app.comment && app.comment.toLowerCase().indexOf(lowerQuery) !== -1) ||
                       (app.categories && app.categories.toLowerCase().indexOf(lowerQuery) !== -1)
            })
        }
        
        // Sort by: favorites first, then by usage count, then alphabetically
        return sortApplications(results)
    }
    
    /**
     * Sort applications by favorites and usage
     */
    function sortApplications(apps) {
        return apps.sort(function(a, b) {
            // Favorites always on top
            var aFav = isFavorite(a.id)
            var bFav = isFavorite(b.id)
            if (aFav && !bFav) return -1
            if (!aFav && bFav) return 1
            
            // Then by usage count
            var aUsage = usageStats[a.id] ? usageStats[a.id].count : 0
            var bUsage = usageStats[b.id] ? usageStats[b.id].count : 0
            if (aUsage !== bUsage) return bUsage - aUsage
            
            // Finally alphabetically
            return a.name.localeCompare(b.name)
        })
    }
    
    /**
     * Toggle favorite status
     */
    function toggleFavorite(appId) {
        var index = favorites.indexOf(appId)
        var newFavorites = favorites.slice()
        
        if (index === -1) {
            newFavorites.push(appId)
            console.log("ApplicationsService: Added to favorites:", appId)
        } else {
            newFavorites.splice(index, 1)
            console.log("ApplicationsService: Removed from favorites:", appId)
        }
        
        favorites = newFavorites
        saveUsageStats()
        favoritesUpdated()
        applicationsUpdated()
    }
    
    /**
     * Check if app is favorite
     */
    function isFavorite(appId) {
        return favorites.indexOf(appId) !== -1
    }
    
    /**
     * Track app usage (doesn't trigger applicationsUpdated to avoid re-scanning)
     */
    function trackUsage(appId) {
        var stats = usageStats[appId] || { count: 0, lastUsed: 0 }
        stats.count++
        stats.lastUsed = Date.now()
        
        // Update stats without triggering property change notification
        usageStats[appId] = stats
        
        saveUsageStats()
    }
    
    /**
     * Load usage stats from file
     */
    property var statsLoader: Process {
        command: ["cat", statsFile]
        running: false
        
        property string output: ""
        
        stdout: SplitParser {
            onRead: function(data) {
                statsLoader.output += data
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0 && statsLoader.output) {
                try {
                    var data = JSON.parse(statsLoader.output)
                    favorites = data.favorites || []
                    usageStats = data.usageStats || {}
                    console.log("ApplicationsService: Loaded", favorites.length, "favorites and", Object.keys(usageStats).length, "usage stats")
                } catch (e) {
                    console.log("ApplicationsService: No existing stats file or parse error:", e)
                }
            }
            statsLoader.output = ""
        }
    }
    
    function loadUsageStats() {
        statsLoader.running = true
    }
    
    /**
     * Save usage stats to file
     */
    function saveUsageStats() {
        var data = {
            favorites: favorites,
            usageStats: usageStats
        }
        
        var json = JSON.stringify(data, null, 2)
        
        var process = Qt.createQmlObject(
            'import Quickshell.Io; Process { running: true }',
            root,
            "statsSaver_" + Date.now()
        )
        
        process.command = ["sh", "-c", "echo '" + json.replace(/'/g, "'\\''") + "' > " + statsFile]
    }
    
    /**
     * Force refresh of application list
     */
    function refresh() {
        console.log("ApplicationsService: Refreshing application list...")
        loadApplications()
    }
}
