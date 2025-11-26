pragma Singleton

import QtQuick 2.15
import Quickshell.Io
import "../colors.js" as PaletteJS

QtObject {
    id: root
    
    property bool _isReady: false
    property int _refreshCounter: 0
    property int _fileReaderVersion: 0
    property var _lastRefreshTime: 0
    
    // Expose all palette properties
    property color primary
    property color onPrimary
    property color primaryContainer
    property color onPrimaryContainer
    
    property color secondary
    property color onSecondary
    property color secondaryContainer
    property color onSecondaryContainer
    
    property color tertiary
    property color onTertiary
    property color tertiaryContainer
    property color onTertiaryContainer
    
    property color error
    property color onError
    property color errorContainer
    property color onErrorContainer
    
    property color background
    property color onBackground
    property color surface
    property color onSurface
    property color surfaceVariant
    property color onSurfaceVariant
    property color surfaceContainer
    property color surfaceContainerHighest
    
    property color outline
    property color shadow
    
    property color inverseSurface
    property color inverseOnSurface
    property color inversePrimary
    
    property bool isDarkMode: true
    
    signal colorsChanged()
    
    // Loader to dynamically reload FileView
    property Loader _fileReaderLoader: Loader {
        id: fileLoader
        sourceComponent: Component {
            FileView {
                path: Qt.resolvedUrl("../colors.js")
                blockLoading: true
            }
        }
    }
    
    // Parse colors.js file content
    function _parseColorsFile() {
        var reader = _fileReaderLoader.item
        if (!reader) {
            console.warn("ColorPalette: FileView not loaded")
            return null
        }
        
        var content = reader.text()
        if (!content) {
            console.warn("ColorPalette: Unable to read colors.js file")
            return null
        }
        
        try {
            // Extract isDark value
            var isDarkMatch = content.match(/var\s+isDark\s*=\s*(true|false)/);
            if (isDarkMatch) {
                isDarkMode = isDarkMatch[1] === "true"
            }
            
            // Determine which palette to use
            var paletteSection = isDarkMode ? "var dark = {" : "var light = {"
            var startIdx = content.indexOf(paletteSection)
            if (startIdx === -1) {
                console.warn("ColorPalette: Could not find palette section")
                return null
            }
            
            // Extract the palette object
            var braceCount = 0
            var paletteStart = content.indexOf("{", startIdx)
            var paletteEnd = -1
            
            for (var i = paletteStart; i < content.length; i++) {
                if (content[i] === "{") braceCount++
                if (content[i] === "}") {
                    braceCount--
                    if (braceCount === 0) {
                        paletteEnd = i
                        break
                    }
                }
            }
            
            if (paletteEnd === -1) {
                console.warn("ColorPalette: Could not parse palette object")
                return null
            }
            
            var paletteStr = content.substring(paletteStart, paletteEnd + 1)
            
            // Parse color values using regex
            var palette = {}
            var colorRegex = /(\w+):\s*"([^"]+)"/g
            var match
            
            while ((match = colorRegex.exec(paletteStr)) !== null) {
                palette[match[1]] = match[2]
            }
            
            return palette
            
        } catch (e) {
            console.error("ColorPalette: Error parsing colors.js:", e)
            return null
        }
    }
    
    // Load colors from parsed palette
    function _loadColors() {
        var p = _parseColorsFile()
        
        if (!p) {
            console.warn("ColorPalette: Using fallback from JS module")
            p = PaletteJS.palette()
        }
        
        primary = p.primary || "#000000"
        onPrimary = p.onPrimary || "#ffffff"
        primaryContainer = p.primaryContainer || "#000000"
        onPrimaryContainer = p.onPrimaryContainer || "#ffffff"
        
        secondary = p.secondary || "#000000"
        onSecondary = p.onSecondary || "#ffffff"
        secondaryContainer = p.secondaryContainer || "#000000"
        onSecondaryContainer = p.onSecondaryContainer || "#ffffff"
        
        tertiary = p.tertiary || "#000000"
        onTertiary = p.onTertiary || "#ffffff"
        tertiaryContainer = p.tertiaryContainer || "#000000"
        onTertiaryContainer = p.onTertiaryContainer || "#ffffff"
        
        error = p.error || "#B3261E"
        onError = p.onError || "#ffffff"
        errorContainer = p.errorContainer || "#F9DEDC"
        onErrorContainer = p.onErrorContainer || "#000000"
        
        background = p.background || "#000000"
        onBackground = p.onBackground || "#ffffff"
        surface = p.surface || "#000000"
        onSurface = p.onSurface || "#ffffff"
        surfaceVariant = p.surfaceVariant || "#000000"
        onSurfaceVariant = p.onSurfaceVariant || "#ffffff"
        surfaceContainer = p.surfaceContainer || "#000000"
        surfaceContainerHighest = p.surfaceContainerHighest || "#000000"
        
        outline = p.outline || "#79747E"
        shadow = p.shadow || "#000000"
        
        inverseSurface = p.inverseSurface || "#ffffff"
        inverseOnSurface = p.inverseOnSurface || "#000000"
        inversePrimary = p.inversePrimary || "#000000"
    }
    
    property FileView _colorFileWatcher: FileView {
        path: Qt.resolvedUrl("../colors.js")
        watchChanges: true
        
        onFileChanged: {
            // console.log("colors.js changed, reloading palette...")
            // Simple debounce: only refresh if enough time has passed
            var now = Date.now()
            if (now - root._lastRefreshTime > 150) {
                root._lastRefreshTime = now
                Qt.callLater(root.refresh)
            }
        }
    }
    
    function refresh() {
        try {
            _refreshCounter++
            _fileReaderVersion++
            
            // Force Loader to reload
            _fileReaderLoader.active = false
            
            Qt.callLater(function() {
                _fileReaderLoader.active = true
                
                Qt.callLater(function() {
                    try {
                        _loadColors()
                        colorsChanged()
                        // console.log("Palette refreshed, counter:", _refreshCounter)
                        // console.log("  primary:", primary)
                    } catch (e) {
                        console.error("ColorPalette refresh error:", e)
                    }
                })
            })
        } catch (e) {
            console.error("ColorPalette refresh outer error:", e)
        }
    }
    
    function toggleDarkMode() {
        isDarkMode = !isDarkMode
        refresh()
    }
    
    function setDarkMode(isDark) {
        isDarkMode = !!isDark
        refresh()
    }
    
    Component.onCompleted: {
        try {
            _loadColors()
            // console.log("=== ColorPalette initialized ===")
            // console.log("  primary:", primary)
        } catch (e) {
            console.error("ColorPalette initialization error:", e)
        }
    }
}
