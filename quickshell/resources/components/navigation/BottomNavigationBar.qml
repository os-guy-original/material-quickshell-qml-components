import QtQuick 2.15
import "../../colors.js" as Palette

/*
  BottomNavigationBar - Horizontal navigation component
  
  Properties:
  - items: array of { icon, label, selected?, onTriggered }
  - showLabels: bool - whether to show labels below icons (default: true)
*/

Rectangle {
    id: root
    property var items: []
    property int selectedIndex: -1
    property bool showLabels: true
    
    color: Palette.palette().surface
    height: showLabels ? 80 : 64
    width: parent ? parent.width : implicitWidth
    
    signal itemClicked(int index)
    
    Behavior on height {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    // Top divider
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Palette.palette().outline
        opacity: 0.24
    }
    
    Row {
        anchors.centerIn: parent
        spacing: 8
        
        Repeater {
            model: root.items.length
            
            delegate: Item {
                id: navItem
                width: 80
                height: 64
                
                property var itemData: root.items[index] || {}
                property bool isSelected: index === root.selectedIndex
                property bool hovered: false
                
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    // Pill-shaped button
                    Rectangle {
                        id: pill
                        width: 64
                        height: 32
                        radius: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: navItem.isSelected ? Palette.palette().primaryContainer : 
                               navItem.hovered ? Qt.rgba(Palette.palette().onSurface.r, 
                                                          Palette.palette().onSurface.g, 
                                                          Palette.palette().onSurface.b, 0.08) : 
                               "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                        
                        // Icon
                        Text {
                            anchors.centerIn: parent
                            text: navItem.itemData.icon || ""
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 24
                            color: navItem.isSelected ? 
                                   Palette.palette().onPrimaryContainer : 
                                   Palette.palette().onSurfaceVariant
                            
                            Behavior on color {
                                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                    
                    // Label below
                    Text {
                        visible: root.showLabels
                        opacity: root.showLabels ? 1 : 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: navItem.itemData.label || ""
                        font.pixelSize: 12
                        font.weight: navItem.isSelected ? Font.Medium : Font.Normal
                        color: navItem.isSelected ? 
                               Palette.palette().onSurface : 
                               Palette.palette().onSurfaceVariant
                        
                        Behavior on color {
                            ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: navItem.hovered = true
                    onExited: navItem.hovered = false
                    
                    onClicked: {
                        root.selectedIndex = index
                        if (navItem.itemData && navItem.itemData.onTriggered) {
                            navItem.itemData.onTriggered()
                        }
                        root.itemClicked(index)
                    }
                }
            }
        }
    }
}


