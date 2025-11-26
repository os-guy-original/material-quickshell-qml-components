import QtQuick 2.15
import ".." as Components
import "../feedback" as Feedback

/*
  Tabs - Material Design 3 Tabs Component
  
  A horizontal tab bar with animated sliding indicator
  
  Properties:
  - tabs: array of { icon?, label } - Tab items (icon is optional for secondary tabs)
  - currentIndex: int - Currently selected tab index
  - variant: string - "primary" (with icons) or "secondary" (text only)
  - indicatorColor: color - Color of the active indicator line
  
  Signals:
  - tabClicked(int index) - Emitted when a tab is clicked
*/

Rectangle {
    id: root
    implicitWidth: tabRow.implicitWidth
    implicitHeight: variant === "primary" ? 64 : 48
    color: Components.ColorPalette.surface
    
    property var tabs: []
    property int currentIndex: 0
    property string variant: "primary"  // "primary" or "secondary"
    property color indicatorColor: Components.ColorPalette.primary
    
    signal tabClicked(int index)
    
    // Tab row
    Row {
        id: tabRow
        anchors.fill: parent
        
        Repeater {
            id: tabRepeater
            model: root.tabs.length
            
            delegate: Item {
                id: tabItem
                width: Math.max(90, tabContent.implicitWidth + 32)
                height: root.height
                
                property var tabData: root.tabs[index] || {}
                property bool isActive: root.currentIndex === index
                property bool isHovered: false
                
                // Hover background
                Rectangle {
                    id: hoverBg
                    anchors.fill: parent
                    color: tabItem.isHovered ? Components.ColorPalette.surfaceContainerHighest : "transparent"
                    clip: true
                    
                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    
                    // Ripple effect
                    Feedback.RippleEffect {
                        id: ripple
                        rippleColor: Components.ColorPalette.onSurface
                    }
                }

                // Tab content
                Column {
                    id: tabContent
                    anchors.centerIn: parent
                    spacing: root.variant === "primary" ? 4 : 0
                    
                    // Icon (primary variant only)
                    Item {
                        visible: root.variant === "primary"
                        width: 24
                        height: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: tabItem.tabData.icon || ""
                            font.family: "Material Icons"
                            font.pixelSize: 24
                            color: tabItem.isActive ? root.indicatorColor : Components.ColorPalette.onSurfaceVariant
                            
                            Behavior on color {
                                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                    
                    // Label
                    Text {
                        text: tabItem.tabData.label || ""
                        font.pixelSize: 14
                        font.weight: tabItem.isActive ? Font.DemiBold : Font.Medium
                        font.letterSpacing: 0.1
                        color: tabItem.isActive ? 
                               (root.variant === "primary" ? root.indicatorColor : Components.ColorPalette.onSurface) : 
                               Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: tabItem.isHovered = true
                    onExited: tabItem.isHovered = false
                    onPressed: function(mouse) {
                        ripple.trigger(mouse.x, mouse.y)
                    }
                    onClicked: {
                        root.currentIndex = index
                        root.tabClicked(index)
                    }
                }
            }
        }
    }
    
    // Sliding indicator
    Rectangle {
        id: indicator
        height: 3
        radius: height / 2  // Fully rounded ends
        color: root.indicatorColor
        y: root.height - height
        
        // Calculate position and width based on current tab
        property var currentTab: tabRepeater.count > 0 && root.currentIndex < tabRepeater.count ? 
                                 tabRepeater.itemAt(root.currentIndex) : null
        
        // Primary tabs: shorter indicator centered under content
        // Secondary tabs: full width indicator
        property real indicatorWidth: root.variant === "primary" ? 48 : (currentTab ? currentTab.width : 0)
        property real indicatorX: currentTab ? (currentTab.x + (currentTab.width - indicatorWidth) / 2) : 0
        
        x: indicatorX
        width: indicatorWidth
        
        Behavior on x {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
    }
}
