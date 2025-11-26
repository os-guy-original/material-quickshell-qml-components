import QtQuick 2.15
import Quickshell
import Quickshell.Hyprland as Hypr
import "../resources/components" as Components
import "../resources/components/layout" as Layout
import "../resources/components/typography" as Type
import "../resources/components/actions" as Actions
import "../shell/services/AppIconService" as AppIconSvc

FloatingWindow {
    id: testWindow
    title: "App Icon Service Test"
    visible: true
    implicitWidth: 700
    implicitHeight: 650
    minimumSize: Qt.size(600, 500)
    
    // Reusable icon display component with error handling
    Component {
        id: iconDisplayComponent
        
        Rectangle {
            id: iconContainer
            color: Components.ColorPalette.surfaceVariant
            
            property string appName: ""
            property string iconSource: ""
            property bool showFallback: iconSource === "" || iconImg.status === Image.Error
            
            // Watch for cache changes
            Connections {
                target: AppIconSvc.AppIconService
                function onIconCacheChanged() {
                    if (iconContainer.appName) {
                        var cached = AppIconSvc.AppIconService.iconCache[iconContainer.appName]
                        if (cached !== undefined && cached !== iconContainer.iconSource) {
                            iconContainer.iconSource = cached
                        }
                    }
                }
            }
            
            Image {
                id: iconImg
                anchors.fill: parent
                source: iconContainer.iconSource
                visible: status === Image.Ready
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                smooth: true
                
                onStatusChanged: {
                    if (status === Image.Error && iconContainer.iconSource) {
                        AppIconSvc.AppIconService.markIconInvalid(iconContainer.appName)
                        iconContainer.iconSource = ""
                    }
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: "?"
                font.pixelSize: parent.width * 0.5
                font.bold: true
                color: Components.ColorPalette.onSurfaceVariant
                visible: iconContainer.showFallback
            }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: Components.ColorPalette.background
        
        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16
            
            // Header
            Row {
                width: parent.width
                spacing: 16
                
                Type.Label {
                    text: "App Icon Service Test"
                    pixelSize: 24
                    bold: true
                    color: Components.ColorPalette.onBackground
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: 1; height: 1 }
                
                Actions.Button {
                    text: "Close"
                    kind: "cancel"
                    outlined: true
                    onClicked: testWindow.visible = false
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Components.ColorPalette.outline
            }
            
            // Active Toplevel Test
            Column {
                width: parent.width
                spacing: 12
                
                Type.Label {
                    text: "Active Window"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Layout.Container {
                    width: parent.width
                    padding: 12
                    
                    Row {
                        spacing: 16
                        
                        Loader {
                            sourceComponent: iconDisplayComponent
                            width: 64
                            height: 64
                            
                            onLoaded: {
                                item.radius = 32
                                item.appName = Qt.binding(function() {
                                    try {
                                        return AppIconSvc.AppIconService.extractIconName(Hypr.Hyprland.activeToplevel) || ""
                                    } catch (e) {
                                        return ""
                                    }
                                })
                                item.iconSource = Qt.binding(function() {
                                    try {
                                        return AppIconSvc.AppIconService.getTopLevelIcon(Hypr.Hyprland.activeToplevel) || ""
                                    } catch (e) {
                                        return ""
                                    }
                                })
                            }
                        }
                        
                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Type.Label {
                                text: {
                                    try {
                                        return Hypr.Hyprland.activeToplevel ? Hypr.Hyprland.activeToplevel.title : "No active window"
                                    } catch (e) {
                                        return "No active window"
                                    }
                                }
                                pixelSize: 14
                                bold: true
                                color: Components.ColorPalette.onSurface
                                width: 400
                                elide: Text.ElideRight
                            }
                            
                            Type.Label {
                                text: {
                                    try {
                                        if (!Hypr.Hyprland.activeToplevel) return "N/A"
                                        var cls = Hypr.Hyprland.activeToplevel.class
                                        return cls ? cls : "N/A"
                                    } catch (e) {
                                        return "N/A"
                                    }
                                }
                                pixelSize: 12
                                color: Components.ColorPalette.onSurfaceVariant
                            }
                        }
                    }
                }
            }
            
            // Random Icon Test
            Column {
                width: parent.width
                spacing: 12
                
                Type.Label {
                    text: "Random App Icon"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Row {
                    spacing: 12
                    
                    Loader {
                        id: randomIconLoader
                        sourceComponent: iconDisplayComponent
                        width: 64
                        height: 64
                        
                        property string currentAppName: ""
                        
                        onLoaded: {
                            item.radius = 32
                            refreshRandomIcon()
                        }
                        
                        function refreshRandomIcon() {
                            if (item) {
                                try {
                                    var toplevels = Hypr.Hyprland.toplevels.values
                                    if (toplevels && toplevels.length > 0) {
                                        var randomIndex = Math.floor(Math.random() * toplevels.length)
                                        var appName = AppIconSvc.AppIconService.extractIconName(toplevels[randomIndex])
                                        currentAppName = appName
                                        item.appName = appName
                                        item.iconSource = AppIconSvc.AppIconService.getAppIcon(appName) || ""
                                    }
                                } catch (e) {
                                    item.iconSource = ""
                                }
                            }
                        }
                    }
                    
                    Actions.Button {
                        text: "Refresh"
                        outlined: true
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: randomIconLoader.refreshRandomIcon()
                    }
                }
            }
            
            // Specific Icon Test
            Column {
                width: parent.width
                spacing: 12
                
                Type.Label {
                    text: "Specific App Icons"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Row {
                    spacing: 12
                    
                    Repeater {
                        model: ["firefox", "chromium", "code", "spotify", "discord"]
                        
                        delegate: Column {
                            spacing: 4
                            
                            Loader {
                                sourceComponent: iconDisplayComponent
                                width: 48
                                height: 48
                                
                                onLoaded: {
                                    item.radius = 24
                                    item.appName = modelData
                                    item.iconSource = AppIconSvc.AppIconService.getAppIcon(modelData) || ""
                                }
                            }
                            
                            Type.Label {
                                text: modelData
                                pixelSize: 10
                                color: Components.ColorPalette.onSurfaceVariant
                                horizontalAlignment: Text.AlignHCenter
                                width: 48
                            }
                        }
                    }
                }
            }
            
            // GNOME Apps Test (reverse domain names)
            Column {
                width: parent.width
                spacing: 12
                
                Type.Label {
                    text: "GNOME Apps (Reverse Domain Names)"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Row {
                    spacing: 12
                    
                    Repeater {
                        model: ["org.gnome.Nautilus", "org.gnome.Settings", "org.gnome.Terminal", "org.gnome.Calculator"]
                        
                        delegate: Column {
                            spacing: 4
                            
                            Loader {
                                sourceComponent: iconDisplayComponent
                                width: 48
                                height: 48
                                
                                onLoaded: {
                                    item.radius = 24
                                    item.appName = modelData
                                    item.iconSource = AppIconSvc.AppIconService.getAppIcon(modelData) || ""
                                }
                            }
                            
                            Type.Label {
                                text: modelData.split(".").pop()
                                pixelSize: 10
                                color: Components.ColorPalette.onSurfaceVariant
                                horizontalAlignment: Text.AlignHCenter
                                width: 48
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Components.ColorPalette.outline
            }
            
            // All Open Windows
            Column {
                width: parent.width
                spacing: 8
                
                Type.Label {
                    text: "All Open Windows"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Layout.ListContainer {
                    width: parent.width
                    
                    Repeater {
                        model: {
                            try {
                                return Hypr.Hyprland.toplevels.values || []
                            } catch (e) {
                                return []
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 56
                            color: Components.ColorPalette.surface
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                Loader {
                                    sourceComponent: iconDisplayComponent
                                    width: 32
                                    height: 32
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    onLoaded: {
                                        item.radius = 16
                                        item.appName = Qt.binding(function() {
                                            try {
                                                return AppIconSvc.AppIconService.extractIconName(modelData) || ""
                                            } catch (e) {
                                                return ""
                                            }
                                        })
                                        item.iconSource = Qt.binding(function() {
                                            try {
                                                return AppIconSvc.AppIconService.getTopLevelIcon(modelData) || ""
                                            } catch (e) {
                                                return ""
                                            }
                                        })
                                    }
                                }
                                
                                Column {
                                    spacing: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 56
                                    
                                    Type.Label {
                                        text: {
                                            try {
                                                return modelData.title || "Unknown"
                                            } catch (e) {
                                                return "Unknown"
                                            }
                                        }
                                        pixelSize: 14
                                        bold: true
                                        color: Components.ColorPalette.onSurface
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                    
                                    Type.Label {
                                        text: {
                                            try {
                                                var cls = modelData.class
                                                return cls ? cls : "No class"
                                            } catch (e) {
                                                return "No class"
                                            }
                                        }
                                        pixelSize: 12
                                        color: Components.ColorPalette.onSurfaceVariant
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
