import QtQuick 2.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/layout" as Layout
import "../resources/components/actions" as Actions

Scope {
    FloatingWindow {
        id: demoWindow
        title: "SidePanel Demo"
        visible: true
        implicitWidth: 300
        implicitHeight: 400
        
        Rectangle {
            anchors.fill: parent
            color: Components.ColorPalette.surface
            
            Column {
                anchors.centerIn: parent
                spacing: 16
                
                Text {
                    text: "SidePanel Demo"
                    font.pixelSize: 20
                    font.bold: true
                    color: Components.ColorPalette.onSurface
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Click buttons to show panels"
                    font.pixelSize: 12
                    color: Components.ColorPalette.onSurfaceVariant
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Actions.Button {
                    text: "Show Right Panel"
                    onClicked: rightPanel.toggle()
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Actions.Button {
                    text: "Show Left Panel"
                    onClicked: leftPanel.toggle()
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Actions.Button {
                    text: "Show Top Panel"
                    onClicked: topPanel.toggle()
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Actions.Button {
                    text: "Show Bottom Panel"
                    onClicked: bottomPanel.toggle()
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    
    // Right side panel - Wide and tall
    Layout.SidePanel {
        id: rightPanel
        edge: "right"
        panelWidth: 450
        panelHeight: 600
        cornerRadius: 32
        margin: 16
        panelColor: Components.ColorPalette.surface
        
        contentComponent: Component {
            Item {
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: parent.width - 40
                    
                    Text {
                        text: "Right Panel"
                        font.pixelSize: 24
                        font.bold: true
                        color: Components.ColorPalette.onSurface
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Width: " + Math.round(rightPanel.panelWidth) + "px\nHeight: " + Math.round(rightPanel.panelHeight) + "px"
                        font.pixelSize: 14
                        color: Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "Adjust Width"
                            font.pixelSize: 12
                            color: Components.ColorPalette.onSurfaceVariant
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: Components.ColorPalette.surfaceVariant
                            radius: 8
                            
                            Rectangle {
                                width: parent.width * ((rightPanel.panelWidth - 200) / 600)
                                height: parent.height
                                color: Components.ColorPalette.primary
                                radius: parent.radius
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        rightPanel.panelWidth = Math.max(200, Math.min(800, 200 + (mouse.x / width) * 600))
                                    }
                                }
                            }
                        }
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "Adjust Height"
                            font.pixelSize: 12
                            color: Components.ColorPalette.onSurfaceVariant
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: Components.ColorPalette.surfaceVariant
                            radius: 8
                            
                            Rectangle {
                                width: parent.width * ((rightPanel.panelHeight - 200) / 800)
                                height: parent.height
                                color: Components.ColorPalette.secondary
                                radius: parent.radius
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        rightPanel.panelHeight = Math.max(200, Math.min(1000, 200 + (mouse.x / width) * 800))
                                    }
                                }
                            }
                        }
                    }
                    
                    Actions.Button {
                        text: "Close"
                        onClicked: rightPanel.hide()
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
    
    // Left side panel - Narrow
    Layout.SidePanel {
        id: leftPanel
        edge: "left"
        panelWidth: 280
        panelHeight: 500
        cornerRadius: 24
        margin: 12
        panelColor: Components.ColorPalette.surfaceContainer
        
        contentComponent: Component {
            Item {
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: parent.width - 40
                    
                    Text {
                        text: "Left Panel"
                        font.pixelSize: 24
                        font.bold: true
                        color: Components.ColorPalette.onSurface
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Width: " + Math.round(leftPanel.panelWidth) + "px\nHeight: " + Math.round(leftPanel.panelHeight) + "px"
                        font.pixelSize: 14
                        color: Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "Adjust Width"
                            font.pixelSize: 12
                            color: Components.ColorPalette.onSurfaceVariant
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: Components.ColorPalette.surfaceVariant
                            radius: 8
                            
                            Rectangle {
                                width: parent.width * ((leftPanel.panelWidth - 200) / 600)
                                height: parent.height
                                color: Components.ColorPalette.primary
                                radius: parent.radius
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        leftPanel.panelWidth = Math.max(200, Math.min(800, 200 + (mouse.x / width) * 600))
                                    }
                                }
                            }
                        }
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "Adjust Height"
                            font.pixelSize: 12
                            color: Components.ColorPalette.onSurfaceVariant
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: Components.ColorPalette.surfaceVariant
                            radius: 8
                            
                            Rectangle {
                                width: parent.width * ((leftPanel.panelHeight - 200) / 800)
                                height: parent.height
                                color: Components.ColorPalette.secondary
                                radius: parent.radius
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        leftPanel.panelHeight = Math.max(200, Math.min(1000, 200 + (mouse.x / width) * 800))
                                    }
                                }
                            }
                        }
                    }
                    
                    Actions.Button {
                        text: "Close"
                        onClicked: leftPanel.hide()
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
    
    // Top panel - Tall
    Layout.SidePanel {
        id: topPanel
        edge: "top"
        panelWidth: 600
        panelHeight: 350
        cornerRadius: 28
        margin: 16
        panelColor: Components.ColorPalette.primaryContainer
        
        contentComponent: Component {
            Item {
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: Math.min(400, parent.width - 40)
                    
                    Text {
                        text: "Top Panel"
                        font.pixelSize: 24
                        font.bold: true
                        color: Components.ColorPalette.onPrimaryContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Width: " + Math.round(topPanel.panelWidth) + "px\nHeight: " + Math.round(topPanel.panelHeight) + "px"
                        font.pixelSize: 14
                        color: Components.ColorPalette.onPrimaryContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "Adjust Width"
                            font.pixelSize: 12
                            color: Components.ColorPalette.onPrimaryContainer
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: Qt.darker(Components.ColorPalette.primaryContainer, 1.2)
                            radius: 8
                            
                            Rectangle {
                                width: parent.width * ((topPanel.panelWidth - 300) / 900)
                                height: parent.height
                                color: Components.ColorPalette.primary
                                radius: parent.radius
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        topPanel.panelWidth = Math.max(300, Math.min(1200, 300 + (mouse.x / width) * 900))
                                    }
                                }
                            }
                        }
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: "Adjust Height"
                            font.pixelSize: 12
                            color: Components.ColorPalette.onPrimaryContainer
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: Qt.darker(Components.ColorPalette.primaryContainer, 1.2)
                            radius: 8
                            
                            Rectangle {
                                width: parent.width * ((topPanel.panelHeight - 150) / 450)
                                height: parent.height
                                color: Components.ColorPalette.secondary
                                radius: parent.radius
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        topPanel.panelHeight = Math.max(150, Math.min(600, 150 + (mouse.x / width) * 450))
                                    }
                                }
                            }
                        }
                    }
                    
                    Actions.Button {
                        text: "Close"
                        onClicked: topPanel.hide()
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
    
    // Bottom panel - Short
    Layout.SidePanel {
        id: bottomPanel
        edge: "bottom"
        panelWidth: 700
        panelHeight: 200
        cornerRadius: 20
        margin: 16
        panelColor: Components.ColorPalette.secondaryContainer
        
        contentComponent: Component {
            Item {
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: Math.min(400, parent.width - 40)
                    
                    Text {
                        text: "Bottom Panel"
                        font.pixelSize: 24
                        font.bold: true
                        color: Components.ColorPalette.onSecondaryContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Width: " + Math.round(bottomPanel.panelWidth) + "px\nHeight: " + Math.round(bottomPanel.panelHeight) + "px"
                        font.pixelSize: 14
                        color: Components.ColorPalette.onSecondaryContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Row {
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Column {
                            width: 180
                            spacing: 8
                            
                            Text {
                                text: "Width"
                                font.pixelSize: 12
                                color: Components.ColorPalette.onSecondaryContainer
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: Qt.darker(Components.ColorPalette.secondaryContainer, 1.2)
                                radius: 8
                                
                                Rectangle {
                                    width: parent.width * ((bottomPanel.panelWidth - 300) / 900)
                                    height: parent.height
                                    color: Components.ColorPalette.secondary
                                    radius: parent.radius
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            bottomPanel.panelWidth = Math.max(300, Math.min(1200, 300 + (mouse.x / width) * 900))
                                        }
                                    }
                                }
                            }
                        }
                        
                        Column {
                            width: 180
                            spacing: 8
                            
                            Text {
                                text: "Height"
                                font.pixelSize: 12
                                color: Components.ColorPalette.onSecondaryContainer
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: Qt.darker(Components.ColorPalette.secondaryContainer, 1.2)
                                radius: 8
                                
                                Rectangle {
                                    width: parent.width * ((bottomPanel.panelHeight - 150) / 450)
                                    height: parent.height
                                    color: Components.ColorPalette.primary
                                    radius: parent.radius
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            bottomPanel.panelHeight = Math.max(150, Math.min(600, 150 + (mouse.x / width) * 450))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Actions.Button {
                        text: "Close"
                        onClicked: bottomPanel.hide()
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
