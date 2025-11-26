pragma Singleton
import QtQuick 2.15

QtObject {
    id: root
    
    // Initialization flag to prevent access before ready
    property bool ready: false
    
    // Global opacity settings with safe defaults
    readonly property real barOpacity: _barOpacity
    readonly property real sidebarOpacity: _sidebarOpacity
    readonly property real osdOpacity: _osdOpacity
    readonly property real launcherOpacity: _launcherOpacity
    
    // Internal properties that can be safely modified
    property real _barOpacity: 0.85
    property real _sidebarOpacity: 0.85
    property real _osdOpacity: 0.85
    property real _launcherOpacity: 0.85
    
    // Signal when any opacity changes
    signal opacityChanged()
    
    // Set all opacities at once
    function setGlobalOpacity(value) {
        _barOpacity = value
        _sidebarOpacity = value
        _osdOpacity = value
        _launcherOpacity = value
        opacityChanged()
        console.log("OpacityService: Global opacity set to", value)
    }
    
    // Individual setters
    function setBarOpacity(value) {
        _barOpacity = value
        opacityChanged()
        console.log("OpacityService: Bar opacity set to", value)
    }
    
    function setSidebarOpacity(value) {
        _sidebarOpacity = value
        opacityChanged()
        console.log("OpacityService: Sidebar opacity set to", value)
    }
    
    function setOsdOpacity(value) {
        _osdOpacity = value
        opacityChanged()
        console.log("OpacityService: OSD opacity set to", value)
    }
    
    function setLauncherOpacity(value) {
        _launcherOpacity = value
        opacityChanged()
        console.log("OpacityService: Launcher opacity set to", value)
    }
    
    Component.onCompleted: {
        ready = true
        console.log("OpacityService initialized - use Services.OpacityService to control window opacity")
    }
}
