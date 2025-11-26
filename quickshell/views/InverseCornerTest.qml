import QtQuick 2.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/layout" as Layout

PanelWindow {
    id: testWindow
    
    visible: true
    width: 400
    height: 400
    
    color: "transparent"
    
    Rectangle {
        id: testRect
        anchors.centerIn: parent
        width: 200
        height: 200
        color: Components.ColorPalette.surface
        radius: 0
        
        // Simulating a RIGHT panel (horizontal opening) - connectors above/below
        Layout.SideConnector { radius: 16; position: "horizontal-above-left" }
        Layout.SideConnector { radius: 16; position: "horizontal-below-left" }
        
        // Simulating a LEFT panel (horizontal opening) - connectors above/below
        Layout.SideConnector { radius: 16; position: "horizontal-above-right" }
        Layout.SideConnector { radius: 16; position: "horizontal-below-right" }
        
        // Simulating a TOP panel (vertical opening) - connectors on sides
        Layout.SideConnector { radius: 16; position: "vertical-top-left" }
        Layout.SideConnector { radius: 16; position: "vertical-top-right" }
        
        // Simulating a BOTTOM panel (vertical opening) - connectors on sides
        Layout.SideConnector { radius: 16; position: "vertical-bottom-left" }
        Layout.SideConnector { radius: 16; position: "vertical-bottom-right" }
        
        Column {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: "Side Connector Test\nAll 8 positions"
                color: Components.ColorPalette.onSurface
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    width: 40
                    height: 40
                    color: Components.ColorPalette.primary
                    radius: 4
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: testRect.color = Components.ColorPalette.primary
                    }
                }
                
                Rectangle {
                    width: 40
                    height: 40
                    color: Components.ColorPalette.secondary
                    radius: 4
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: testRect.color = Components.ColorPalette.secondary
                    }
                }
                
                Rectangle {
                    width: 40
                    height: 40
                    color: Components.ColorPalette.tertiary
                    radius: 4
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: testRect.color = Components.ColorPalette.tertiary
                    }
                }
            }
        }
    }
}
