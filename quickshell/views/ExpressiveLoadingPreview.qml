import QtQuick 2.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/layout" as Layout
import "../resources/components/typography" as Type
import "../resources/components/actions" as Actions
import "../resources/components/inputs" as Inputs
import "../resources/components/progress" as Progress
import "../resources/components/navigation" as Nav

FloatingWindow {
    id: previewWindow
    title: "Expressive Loading Indicator"
    visible: true
    implicitWidth: 580
    implicitHeight: 480
    minimumSize: Qt.size(400, 360)
    
    Rectangle {
        anchors.fill: parent
        color: Components.ColorPalette.isDarkMode 
            ? Components.ColorPalette.background 
            : Qt.darker(Components.ColorPalette.background, 1.08)
    }
    
    Nav.HeaderBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: "M3X Expressive Loading"
        titleAlignment: "center"
        onCloseRequested: previewWindow.visible = false
        z: 10
    }
    
    Flickable {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16
        contentHeight: content.height
        clip: true
        
        Column {
            id: content
            width: parent.width
            spacing: 20
            
            // Main showcase
            Rectangle {
                width: parent.width
                height: 140
                radius: 16
                color: Components.ColorPalette.surfaceContainer
                
                Progress.ExpressiveLoadingIndicator {
                    id: mainIndicator
                    anchors.centerIn: parent
                    size: 72
                    running: runningSwitch.checked
                    filled: filledSwitch.checked
                    cycleColors: cycleSwitch.checked
                }
            }
            
            // Controls
            Row {
                spacing: 20
                
                Row {
                    spacing: 8
                    Type.Label {
                        text: "Running"
                        color: Components.ColorPalette.onSurfaceVariant
                        pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Inputs.Switch {
                        id: runningSwitch
                        checked: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Row {
                    spacing: 8
                    Type.Label {
                        text: "Filled"
                        color: Components.ColorPalette.onSurfaceVariant
                        pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Inputs.Switch {
                        id: filledSwitch
                        checked: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Row {
                    spacing: 8
                    Type.Label {
                        text: "Cycle Colors"
                        color: Components.ColorPalette.onSurfaceVariant
                        pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Inputs.Switch {
                        id: cycleSwitch
                        checked: false
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            
            // Size variants
            Column {
                width: parent.width
                spacing: 10
                
                Type.Label {
                    text: "Sizes"
                    color: Components.ColorPalette.onSurface
                    pixelSize: 15
                    bold: true
                }
                
                Row {
                    spacing: 28
                    
                    Column {
                        spacing: 6
                        Progress.ExpressiveLoadingIndicator { size: 20; anchors.horizontalCenter: parent.horizontalCenter }
                        Type.Label { text: "20"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    
                    Column {
                        spacing: 6
                        Progress.ExpressiveLoadingIndicator { size: 32; anchors.horizontalCenter: parent.horizontalCenter }
                        Type.Label { text: "32"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    
                    Column {
                        spacing: 6
                        Progress.ExpressiveLoadingIndicator { size: 48; anchors.horizontalCenter: parent.horizontalCenter }
                        Type.Label { text: "48"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    
                    Column {
                        spacing: 6
                        Progress.ExpressiveLoadingIndicator { size: 64; anchors.horizontalCenter: parent.horizontalCenter }
                        Type.Label { text: "64"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }
            
            // Colors
            Column {
                width: parent.width
                spacing: 10
                
                Type.Label {
                    text: "Colors"
                    color: Components.ColorPalette.onSurface
                    pixelSize: 15
                    bold: true
                }
                
                Row {
                    spacing: 20
                    
                    Progress.ExpressiveLoadingIndicator { size: 36; color: Components.ColorPalette.primary }
                    Progress.ExpressiveLoadingIndicator { size: 36; color: Components.ColorPalette.secondary }
                    Progress.ExpressiveLoadingIndicator { size: 36; color: Components.ColorPalette.tertiary }
                    Progress.ExpressiveLoadingIndicator { size: 36; color: Components.ColorPalette.error }
                    Progress.ExpressiveLoadingIndicator { size: 36; color: Components.ColorPalette.onSurface }
                }
            }
            
            // Contained variants
            Column {
                width: parent.width
                spacing: 10
                
                Type.Label {
                    text: "Contained (M3X)"
                    color: Components.ColorPalette.onSurface
                    pixelSize: 15
                    bold: true
                }
                
                Row {
                    spacing: 16
                    
                    Rectangle {
                        width: 56; height: 56; radius: 28
                        color: Components.ColorPalette.primaryContainer
                        Progress.ExpressiveLoadingIndicator {
                            anchors.centerIn: parent
                            size: 32
                            color: Components.ColorPalette.onPrimaryContainer
                        }
                    }
                    
                    Rectangle {
                        width: 56; height: 56; radius: 28
                        color: Components.ColorPalette.secondaryContainer
                        Progress.ExpressiveLoadingIndicator {
                            anchors.centerIn: parent
                            size: 32
                            color: Components.ColorPalette.onSecondaryContainer
                        }
                    }
                    
                    Rectangle {
                        width: 56; height: 56; radius: 28
                        color: Components.ColorPalette.tertiaryContainer
                        Progress.ExpressiveLoadingIndicator {
                            anchors.centerIn: parent
                            size: 32
                            color: Components.ColorPalette.onTertiaryContainer
                        }
                    }
                    
                    Rectangle {
                        width: 56; height: 56; radius: 12
                        color: Components.ColorPalette.surfaceVariant
                        Progress.ExpressiveLoadingIndicator {
                            anchors.centerIn: parent
                            size: 32
                            color: Components.ColorPalette.primary
                        }
                    }
                }
            }
            
            // Outlined variant
            Column {
                width: parent.width
                spacing: 10
                
                Type.Label {
                    text: "Outlined"
                    color: Components.ColorPalette.onSurface
                    pixelSize: 15
                    bold: true
                }
                
                Row {
                    spacing: 20
                    
                    Progress.ExpressiveLoadingIndicator { size: 40; filled: false; color: Components.ColorPalette.primary }
                    Progress.ExpressiveLoadingIndicator { size: 40; filled: false; color: Components.ColorPalette.secondary }
                    Progress.ExpressiveLoadingIndicator { size: 40; filled: false; color: Components.ColorPalette.tertiary }
                }
            }
            
            // Usage examples
            Column {
                width: parent.width
                spacing: 10
                
                Type.Label {
                    text: "Usage"
                    color: Components.ColorPalette.onSurface
                    pixelSize: 15
                    bold: true
                }
                
                Row {
                    spacing: 16
                    
                    // Inline with text
                    Row {
                        spacing: 8
                        Progress.ExpressiveLoadingIndicator {
                            size: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Type.Label {
                            text: "Loading..."
                            color: Components.ColorPalette.onSurfaceVariant
                            pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    // Color cycling
                    Row {
                        spacing: 8
                        Progress.ExpressiveLoadingIndicator {
                            size: 18
                            cycleColors: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Type.Label {
                            text: "Processing..."
                            color: Components.ColorPalette.onSurfaceVariant
                            pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
            
            Item { width: 1; height: 12 }
        }
    }
}
