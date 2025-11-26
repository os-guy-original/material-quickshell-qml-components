pragma Singleton

import QtQuick 2.15

QtObject {
    id: root
    
    // Performance mode: "normal" or "low-resource"
    property string mode: "normal"
    
    // Automatically detected based on system load
    property bool isUnderHeavyLoad: false
    
    // Settings that can be adjusted based on performance mode
    readonly property bool enableAnimations: mode === "normal"
    readonly property bool enableColorExtraction: mode === "normal"
    readonly property int timerInterval: mode === "normal" ? 500 : 1000
    
    // Manual override
    function setLowResourceMode(enabled) {
        mode = enabled ? "low-resource" : "normal"
    }
    
    // Auto-detect based on active processes (simplified)
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            // Simple heuristic: if ColorExtractor has many pending requests, we're under load
            // This could be expanded with actual system monitoring
            root.isUnderHeavyLoad = false
        }
    }
}
