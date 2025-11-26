pragma Singleton

import QtQuick 2.15
import Qt.labs.platform 1.1
import "../../resources/components" as Components
import "." as Services

QtObject {
    id: root
    
    property var cache: ({})
    property bool _initialized: false
    property var _pendingRequests: ({})  // Track in-progress requests
    property int _activeProcessCount: 0  // Track active Python processes
    property int _maxConcurrentProcesses: 2  // Limit concurrent processes to reduce memory
    property bool enabled: true  // Can be disabled to save resources
    
    signal colorExtracted(string imageUrl, var extractedColors)
    
    function extractColor(imageUrl, callback) {
        // If disabled, return fallback immediately
        if (!enabled) {
            var fallback = { primary: Components.ColorPalette.primary, onPrimary: Components.ColorPalette.onPrimary }
            if (callback) callback(fallback)
            return fallback
        }
        
        // Mark as initialized on first use
        if (!_initialized) {
            _initialized = true
        }
        
        // Return cached result immediately
        if (cache[imageUrl]) {
            if (callback) callback(cache[imageUrl])
            return cache[imageUrl]
        }
        
        // If already extracting this image, add callback to pending list
        if (_pendingRequests[imageUrl]) {
            if (callback) {
                _pendingRequests[imageUrl].callbacks.push(callback)
            }
            return null
        }
        
        // If too many processes running, return fallback to prevent memory exhaustion
        if (_activeProcessCount >= _maxConcurrentProcesses) {
            var fallback2 = { primary: Components.ColorPalette.primary, onPrimary: Components.ColorPalette.onPrimary }
            if (callback) callback(fallback2)
            return fallback2
        }
        
        // Mark as pending
        _pendingRequests[imageUrl] = {
            callbacks: callback ? [callback] : []
        }
        
        // Extract directly without creating helper objects (avoids threading issues)
        var localPath = imageUrl.replace("file://", "")
        
        extractColorFromPython(localPath, function(colors) {
            cache[imageUrl] = colors
            root.colorExtracted(imageUrl, colors)
            
            // Call all pending callbacks
            if (_pendingRequests[imageUrl]) {
                var callbacks = _pendingRequests[imageUrl].callbacks
                for (var i = 0; i < callbacks.length; i++) {
                    callbacks[i](colors)
                }
                delete _pendingRequests[imageUrl]
            }
        })
        
        return null
    }
    
    property string pythonScriptPath: {
        var homeDir = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString()
        if (homeDir.indexOf("file://") === 0) {
            homeDir = homeDir.substring(7)
        }
        return homeDir + "/.config/hypr/colorgen/python_colorgen.py"
    }
    
    function extractColorFromPython(imageUrl, callback) {
        _activeProcessCount++
        
        Services.ExecutorService.execWithOutput(
            "python3",
            [pythonScriptPath, "--primary", "--on-primary", "--path", imageUrl],
            function(stdout, stderr, exitCode) {
                _activeProcessCount--
                
                if (exitCode === 0 && stdout) {
                    var colors = stdout.trim().match(/#[0-9a-fA-F]{6}/g)
                    
                    if (colors && colors.length >= 2) {
                        if (callback) callback({ primary: colors[0], onPrimary: colors[1] })
                    } else if (colors && colors.length === 1) {
                        if (callback) callback({ primary: colors[0], onPrimary: "#FFFFFF" })
                    } else {
                        if (callback) callback({ primary: Components.ColorPalette.primary, onPrimary: Components.ColorPalette.onPrimary })
                    }
                } else {
                    if (callback) callback({ primary: Components.ColorPalette.primary, onPrimary: Components.ColorPalette.onPrimary })
                }
            }
        )
    }
    
    function clearCache() {
        cache = {}
    }
}
