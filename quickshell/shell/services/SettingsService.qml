pragma Singleton

import QtQuick 2.15
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    signal settingsUpdated()
    
    property string settingsFilePath: Quickshell.env("HOME") + "/.config/sd-v-shell/settings.json"
    property var settings: ({})
    property bool isLoaded: false
    property bool isSaving: false
    property int settingsVersion: 0  // Increment this to force binding re-evaluation
    
    // Default settings for appLauncher
    property var appLauncherDefaults: ({
        "edge": "bottom",
        "panelWidth": 650,
        "panelHeight": 680,
        "showCategories": false,
        "gridColumns": 5,
        "largeIcons": false,
        "showAppNames": true,
        "autoFocusSearch": true,
        "closeOnLaunch": true,
        "showHeader": false,
        "headerPosition": "top",
        "headerAlignment": "left",
        "welcomeMessage": "Welcome back,",
        "searchPosition": "top",
        "searchAlignment": "stretch",
        "searchWidth": 400,
        "collapseCategories": false,
        "rememberLastSearch": false
    })
    
    // Helper function to get setting value with reactivity
    function _getAppLauncherSetting(key) {
        // This function depends on settingsVersion, so bindings will re-evaluate when it changes
        var _ = settingsVersion  // Force dependency
        return getSectionValue("appLauncher", key, appLauncherDefaults[key])
    }
    
    // Reactive appLauncher settings object
    readonly property QtObject appLauncher: QtObject {
        property string edge: root._getAppLauncherSetting("edge")
        property int panelWidth: root._getAppLauncherSetting("panelWidth")
        property int panelHeight: root._getAppLauncherSetting("panelHeight")
        property bool showCategories: root._getAppLauncherSetting("showCategories")
        property int gridColumns: root._getAppLauncherSetting("gridColumns")
        property bool largeIcons: root._getAppLauncherSetting("largeIcons")
        property bool showAppNames: root._getAppLauncherSetting("showAppNames")
        property bool autoFocusSearch: root._getAppLauncherSetting("autoFocusSearch")
        property bool closeOnLaunch: root._getAppLauncherSetting("closeOnLaunch")
        property bool showHeader: root._getAppLauncherSetting("showHeader")
        property string headerPosition: root._getAppLauncherSetting("headerPosition")
        property string headerAlignment: root._getAppLauncherSetting("headerAlignment")
        property string welcomeMessage: root._getAppLauncherSetting("welcomeMessage")
        property string searchPosition: root._getAppLauncherSetting("searchPosition")
        property string searchAlignment: root._getAppLauncherSetting("searchAlignment")
        property int searchWidth: root._getAppLauncherSetting("searchWidth")
        property bool collapseCategories: root._getAppLauncherSetting("collapseCategories")
        property bool rememberLastSearch: root._getAppLauncherSetting("rememberLastSearch")
    }
    
    // Accumulated file content
    property string _fileContent: ""
    
    // File reader process for loading settings
    Process {
        id: fileReader
        running: false
        
        stdout: SplitParser {
            onRead: function(data) {
                // Accumulate all data chunks
                root._fileContent += data
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                // Successfully read file, now parse it
                try {
                    if (root._fileContent && root._fileContent.trim().length > 0) {
                        root.settings = JSON.parse(root._fileContent)
                        console.log("SettingsService: Loaded settings from", root.settingsFilePath)
                        console.log("SettingsService: Settings:", JSON.stringify(root.settings))
                    } else {
                        root.settings = {}
                        console.log("SettingsService: Empty file, using defaults")
                    }
                } catch (e) {
                    console.error("SettingsService: Failed to parse settings:", e)
                    console.error("SettingsService: Content was:", root._fileContent)
                    root.settings = {}
                }
            } else {
                console.log("SettingsService: No settings file found (exit code", exitCode + "), using defaults")
                root.settings = {}
            }
            
            // Reset for next load
            root._fileContent = ""
            root.isLoaded = true
            root.settingsVersion++
            root.settingsUpdated()
        }
    }
    
    // Debounce timer to prevent excessive reloads
    Timer {
        id: reloadDebounce
        interval: 500
        onTriggered: {
            // Don't reload if we just saved
            if (!root.isSaving) {
                console.log("SettingsService: Reloading settings...")
                root.loadSettings()
            }
        }
    }
    
    // File watcher for detecting external changes
    Process {
        id: watcherProcess
        command: ["inotifywait", "-m", "-e", "close_write", root.settingsFilePath]
        running: root.isLoaded
        
        stdout: SplitParser {
            onRead: function(data) {
                // Debounce to avoid multiple rapid reloads
                reloadDebounce.restart()
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0 && root.isLoaded) {
                console.warn("SettingsService: inotifywait exited with code", exitCode)
            }
        }
    }
    
    function loadSettings() {
        console.log("SettingsService: Loading settings from", settingsFilePath)
        fileReader.command = ["cat", settingsFilePath]
        fileReader.running = true
    }
    
    Process {
        id: writeProcess
        running: false
        
        onExited: function(exitCode) {
            if (exitCode === 0) {
                console.log("SettingsService: Saved settings to", root.settingsFilePath)
                // Don't emit settingsUpdated here to avoid reload loop
            } else {
                console.error("SettingsService: Failed to save settings, exit code:", exitCode)
            }
        }
    }
    
    Timer {
        id: saveDebounce
        interval: 300
        onTriggered: {
            try {
                root.isSaving = true
                var json = JSON.stringify(settings, null, 2)
                console.log("SettingsService: Saving settings:", json)
                
                // Create directory and write file using cat with heredoc for better escaping
                var heredocMarker = "EOF_SETTINGS_" + Date.now()
                writeProcess.command = ["sh", "-c", "mkdir -p ~/.config/sd-v-shell && cat > " + settingsFilePath + " << '" + heredocMarker + "'\n" + json + "\n" + heredocMarker]
                writeProcess.running = true
            } catch (e) {
                console.error("SettingsService: Failed to save settings:", e)
                root.isSaving = false
            }
        }
    }
    
    Timer {
        id: savingResetTimer
        interval: 1000
        onTriggered: {
            root.isSaving = false
        }
    }
    
    function saveSettings() {
        // Debounce saves to avoid excessive writes
        saveDebounce.restart()
        // Increment version to trigger binding re-evaluation
        settingsVersion++
        // Emit immediately so UI updates with in-memory values
        settingsUpdated()
        // Reset saving flag after a delay
        savingResetTimer.restart()
    }
    
    function get(key, defaultValue) {
        if (settings.hasOwnProperty(key)) {
            return settings[key]
        }
        return defaultValue !== undefined ? defaultValue : null
    }
    
    function set(key, value) {
        var newSettings = Object.assign({}, settings)
        newSettings[key] = value
        settings = newSettings
        saveSettings()
    }
    
    function getSection(section) {
        if (settings.hasOwnProperty(section) && typeof settings[section] === 'object') {
            return settings[section]
        }
        return {}
    }
    
    function setSection(section, values) {
        var newSettings = Object.assign({}, settings)
        if (!newSettings[section]) {
            newSettings[section] = {}
        }
        newSettings[section] = Object.assign(newSettings[section], values)
        settings = newSettings
        saveSettings()
    }
    
    function setSectionValue(section, key, value) {
        var newSettings = Object.assign({}, settings)
        if (!newSettings[section]) {
            newSettings[section] = {}
        }
        newSettings[section][key] = value
        settings = newSettings
        saveSettings()
    }
    
    function getSectionValue(section, key, defaultValue) {
        if (settings.hasOwnProperty(section) && 
            typeof settings[section] === 'object' &&
            settings[section].hasOwnProperty(key)) {
            return settings[section][key]
        }
        return defaultValue !== undefined ? defaultValue : null
    }
    
    Component.onCompleted: {
        console.log("SettingsService: Initializing...")
        loadSettings()
    }
}
