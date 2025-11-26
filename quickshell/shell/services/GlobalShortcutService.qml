pragma Singleton
import QtQuick 2.15
import Quickshell.Hyprland

Item {
    id: root
    
    // Reference to shell instance for callbacks
    property var shellInstance: null
    
    // Registered shortcuts
    property var shortcuts: ({})
    
    // App Launcher shortcut
    GlobalShortcut {
        id: launcherShortcut
        name: "toggle-launcher"
        description: "Toggle application launcher"
        
        onPressed: {
            console.log("GlobalShortcut: toggle-launcher pressed!")
            if (root.shellInstance && root.shellInstance.toggleAppLauncher) {
                root.shellInstance.toggleAppLauncher()
            } else {
                console.warn("GlobalShortcutService: shellInstance or toggleAppLauncher not available")
            }
        }
        
        Component.onCompleted: {
            root.shortcuts["toggle-launcher"] = this
            console.log("GlobalShortcutService: Registered shortcut 'toggle-launcher'")
        }
    }
    
    // Register a custom shortcut dynamically
    function registerShortcut(name, description, callback) {
        if (shortcuts[name]) {
            console.warn("GlobalShortcutService: Shortcut '" + name + "' already registered")
            return false
        }
        
        var component = Qt.createComponent("qrc:/qt/qml/Quickshell/Hyprland/GlobalShortcut.qml")
        if (component.status !== Component.Ready) {
            console.error("GlobalShortcutService: Failed to create GlobalShortcut component:", component.errorString())
            return false
        }
        
        var shortcut = component.createObject(root, {
            name: name,
            description: description
        })
        
        if (!shortcut) {
            console.error("GlobalShortcutService: Failed to instantiate GlobalShortcut")
            return false
        }
        
        shortcut.pressed.connect(callback)
        shortcuts[name] = shortcut
        
        console.log("GlobalShortcutService: Registered custom shortcut '" + name + "'")
        return true
    }
    
    // Unregister a shortcut
    function unregisterShortcut(name) {
        if (!shortcuts[name]) {
            console.warn("GlobalShortcutService: Shortcut '" + name + "' not found")
            return false
        }
        
        shortcuts[name].destroy()
        delete shortcuts[name]
        
        console.log("GlobalShortcutService: Unregistered shortcut '" + name + "'")
        return true
    }
    
    // Get list of registered shortcuts
    function listShortcuts() {
        return Object.keys(shortcuts)
    }
    
    Component.onCompleted: {
        console.log("GlobalShortcutService: Initialized")
    }
}
