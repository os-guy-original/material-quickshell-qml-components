import QtQuick 2.15
import ".." as Components

/*
  NavigationDrawer - Material Design 3 Navigation Drawer
  
  A side panel for app navigation with sections and items
  
  Properties:
  - headline: string - Title at the top of the drawer (e.g., "Mail")
  - sections: array of { title?, items: [{ icon, label, badge?, selected?, onTriggered }] }
  - modal: bool - Whether drawer has elevated appearance (default: false)
  - width: number - Drawer width (default: 360)
*/

Rectangle {
    id: root
    width: 360
    implicitHeight: contentColumn.implicitHeight + 32
    color: modal ? Components.ColorPalette.surfaceContainer : Components.ColorPalette.surface
    radius: modal ? 16 : 0
    clip: true
    
    property string headline: ""
    property var sections: []
    property bool modal: false
    
    signal itemClicked(int sectionIndex, int itemIndex)
    
    // Subtle shadow for modal variant
    Rectangle {
        visible: root.modal
        anchors.fill: parent
        anchors.margins: -1
        z: -1
        radius: root.radius + 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.08)
    }
    
    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        spacing: 0
        
        // Headline
        Item {
            visible: root.headline !== ""
            width: parent.width
            height: visible ? 56 : 0

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                text: root.headline
                font.pixelSize: 14
                font.weight: Font.Medium
                font.letterSpacing: 0.1
                color: Components.ColorPalette.onSurfaceVariant
            }
        }
        
        // Sections
        Repeater {
            model: root.sections.length
            
            delegate: Column {
                id: sectionDelegate
                width: root.width
                spacing: 0
                
                property var sectionData: root.sections[index] || {}
                property int sectionIndex: index
                
                // Section divider (not for first section)
                Rectangle {
                    visible: sectionDelegate.sectionIndex > 0
                    width: parent.width - 56
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Components.ColorPalette.outline
                    
                    Item {
                        width: parent.width
                        height: 16
                    }
                }
                
                // Section title
                Item {
                    visible: sectionDelegate.sectionData.title && sectionDelegate.sectionData.title !== ""
                    width: parent.width
                    height: visible ? 56 : 0
                    
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        text: sectionDelegate.sectionData.title || ""
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        font.letterSpacing: 0.1
                        color: Components.ColorPalette.onSurfaceVariant
                    }
                }

                // Section items
                Repeater {
                    model: (sectionDelegate.sectionData.items || []).length
                    
                    delegate: Item {
                        id: itemDelegate
                        width: root.width
                        height: 56
                        
                        property var itemData: sectionDelegate.sectionData.items ? sectionDelegate.sectionData.items[index] : null
                        property bool isSelected: itemData ? (itemData.selected === true) : false
                        property bool isHovered: false
                        property int itemIndex: index
                        
                        // Item container with padding
                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            
                            // Background pill
                            Rectangle {
                                id: itemBg
                                anchors.fill: parent
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                radius: 28
                                color: itemDelegate.isSelected ? Components.ColorPalette.primaryContainer : 
                                       itemDelegate.isHovered ? Components.ColorPalette.surfaceContainerHighest : 
                                       "transparent"
                                
                                Behavior on color {
                                    ColorAnimation { 
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                            
                            // Content row
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 24
                                spacing: 12
                                
                                // Icon
                                Item {
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: itemDelegate.itemData ? (itemDelegate.itemData.icon || "") : ""
                                        font.family: "Material Icons"
                                        font.pixelSize: 24
                                        color: itemDelegate.isSelected ? 
                                               Components.ColorPalette.onPrimaryContainer : 
                                               Components.ColorPalette.onSurfaceVariant
                                        
                                        Behavior on color {
                                            ColorAnimation { 
                                                duration: 200
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }
                                
                                // Label
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 24 - 12 - (badgeContainer.visible ? badgeContainer.width + 12 : 0)
                                    text: itemDelegate.itemData ? (itemDelegate.itemData.label || "") : ""
                                    font.pixelSize: 14
                                    font.weight: itemDelegate.isSelected ? Font.DemiBold : Font.Medium
                                    font.letterSpacing: 0.1
                                    elide: Text.ElideRight
                                    color: itemDelegate.isSelected ? 
                                           Components.ColorPalette.onPrimaryContainer : 
                                           Components.ColorPalette.onSurfaceVariant
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: 200
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                            
                            // Badge (right-aligned)
                            Item {
                                id: badgeContainer
                                visible: itemDelegate.itemData ? !!(itemDelegate.itemData.badge) : false
                                anchors.right: parent.right
                                anchors.rightMargin: 24
                                anchors.verticalCenter: parent.verticalCenter
                                width: badgeText.width
                                height: 24
                                
                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: itemDelegate.itemData ? (itemDelegate.itemData.badge || "") : ""
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: itemDelegate.isSelected ? 
                                           Components.ColorPalette.onPrimaryContainer : 
                                           Components.ColorPalette.onSurfaceVariant
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onEntered: itemDelegate.isHovered = true
                                onExited: itemDelegate.isHovered = false
                                
                                onClicked: {
                                    if (itemDelegate.itemData && itemDelegate.itemData.onTriggered) {
                                        itemDelegate.itemData.onTriggered()
                                    }
                                    root.itemClicked(sectionDelegate.sectionIndex, itemDelegate.itemIndex)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
