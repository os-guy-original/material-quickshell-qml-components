import QtQuick 2.15
import "../../colors.js" as Palette

/*
  NavigationRail - Material Design 3 Navigation Rail
  
  A vertical navigation component for switching between primary destinations
  
  Properties:
  - items: array of { icon, label?, badge?, selected?, onTriggered }
  - showLabels: bool - whether to show labels (default: false for collapsed)
  - fabIcon: string - icon for the FAB-like button at top
  - fabLabel: string - label for FAB when expanded
  - onFabClicked: signal for FAB button
*/

Rectangle {
    id: root
    width: showLabels ? 180 : 80
    color: Palette.palette().surface
    
    property var items: []
    property bool showLabels: false
    property bool circularCollapsed: false  // Make collapsed buttons fully circular
    property bool showMenuButton: false  // Show hamburger menu button at top
    property string fabIcon: "edit"
    property string fabLabel: "Compose"
    
    // Internal animation state tracking
    property bool _animatingToExpanded: false
    property bool _animatingToCollapsed: false
    property bool _showExpandedLabels: showLabels
    property bool _showCollapsedLabels: !showLabels
    
    signal itemClicked(int index)
    signal fabClicked()
    signal menuClicked()
    
    onShowLabelsChanged: {
        // Stop any running timers to prevent conflicts
        expandedLabelTimer.stop()
        collapsedLabelTimer.stop()
        
        if (showLabels) {
            // Expanding: labels fade in after delay
            _animatingToExpanded = true
            _animatingToCollapsed = false
            _showCollapsedLabels = false
            _showExpandedLabels = false  // Hide immediately
            expandedLabelTimer.restart()
        } else {
            // Collapsing: hide expanded labels first, then animate, then show collapsed labels
            _animatingToCollapsed = true
            _animatingToExpanded = false
            _showExpandedLabels = false
            _showCollapsedLabels = false  // Hide immediately
            collapsedLabelTimer.restart()
        }
    }
    
    Timer {
        id: expandedLabelTimer
        interval: 200  // Wait for bg and icon to start moving
        onTriggered: {
            if (root.showLabels) {  // Only show if still in expanded state
                root._showExpandedLabels = true
            }
            root._animatingToExpanded = false
        }
    }
    
    Timer {
        id: collapsedLabelTimer
        interval: 250  // Wait for bg and icon to settle in collapsed position
        onTriggered: {
            if (!root.showLabels) {  // Only show if still in collapsed state
                root._showCollapsedLabels = true
            }
            root._animatingToCollapsed = false
        }
    }
    
    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 0
        
        // Menu button (hamburger icon)
        Item {
            visible: root.showMenuButton
            width: parent.width
            height: visible ? 72 : 0
            
            Rectangle {
                width: 56
                height: 56
                radius: 28
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                
                property bool hovered: false
                
                // 3-line hamburger icon
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 24
                            height: 2
                            radius: 1
                            color: Palette.palette().onSurfaceVariant
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: root.menuClicked()
                }
            }
        }
        
        // Top button (styled like nav buttons)
        Item {
            width: parent.width
            height: 72
            
            property bool hovered: false
            
            Rectangle {
                id: topButton
                width: root.showLabels ? Math.max(topIconContainer.width + topLabel.width + 44, 56) : 56
                height: 56
                radius: 16
                x: root.showLabels ? 8 : (parent.width - width) / 2
                anchors.verticalCenter: parent.verticalCenter
                color: Palette.palette().primary
                
                Behavior on x {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                
                Item {
                    anchors.fill: parent
                    
                    // Icon
                    Item {
                        id: topIconContainer
                        width: 24
                        height: 24
                        x: root.showLabels ? 16 : (topButton.width - width) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Behavior on x {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.fabIcon
                            font.family: "Material Icons"
                            font.pixelSize: 24
                            color: Palette.palette().onPrimary
                        }
                    }
                    
                    // Label (expanded mode)
                    Text {
                        id: topLabel
                        visible: root.showLabels
                        opacity: root._showExpandedLabels ? 1.0 : 0.0
                        x: topIconContainer.x + topIconContainer.width + 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.fabLabel
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: Palette.palette().onPrimary
                        
                        Behavior on x {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
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
                    onEntered: parent.parent.hovered = true
                    onExited: parent.parent.hovered = false
                    onClicked: root.fabClicked()
                }
            }
        }
        
        // Spacer between top button and nav items
        Item {
            width: parent.width
            height: 32
        }
        
        // Navigation items
        Repeater {
            model: root.items.length
            
            delegate: Item {
                width: root.width
                height: 72
                
                property var itemData: root.items[index] || {}
                property bool isSelected: !!(itemData && itemData.selected === true)
                property bool hovered: false
                
                // Pill-shaped button container
                Rectangle {
                    id: pillContainer
                    width: root.showLabels ? Math.max(iconContainer.width + expandedLabel.width + 44, 56) : 56
                    height: root.showLabels ? 56 : (root.circularCollapsed ? 56 : 32)
                    radius: root.showLabels ? 28 : (root.circularCollapsed ? 28 : 16)
                    x: root.showLabels ? 8 : (parent.width - width) / 2
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    color: parent.isSelected ? Palette.palette().primaryContainer : 
                           parent.hovered ? Qt.rgba(Palette.palette().onSurface.r, 
                                                     Palette.palette().onSurface.g, 
                                                     Palette.palette().onSurface.b, 0.08) : 
                           "transparent"
                    
                    Behavior on color {
                        ColorAnimation { 
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on x {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on height {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on radius {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    // Content: icon + label
                    Item {
                        anchors.fill: parent
                        
                        // Icon (always present, position changes based on mode)
                        Item {
                            id: iconContainer
                            width: 24
                            height: 24
                            x: root.showLabels ? 16 : (pillContainer.width - width) / 2
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Behavior on x {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                            
                            Item {
                                width: 24
                                height: 24
                                anchors.centerIn: parent
                                
                                Text {
                                    id: iconText
                                    anchors.centerIn: parent
                                    text: (pillContainer.parent.itemData && pillContainer.parent.itemData.icon) ? pillContainer.parent.itemData.icon : ""
                                    font.family: "Material Icons"
                                    font.pixelSize: 24
                                    color: pillContainer.parent.isSelected ? 
                                           Palette.palette().onPrimaryContainer : 
                                           Palette.palette().onSurfaceVariant
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: 300
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                                
                                // Badge
                                Rectangle {
                                    visible: !!(pillContainer.parent.itemData && pillContainer.parent.itemData.badge)
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.rightMargin: -4
                                    anchors.topMargin: -4
                                    width: badgeText.text.length > 1 ? badgeText.width + 8 : 16
                                    height: 16
                                    radius: 8
                                    color: Palette.palette().error
                                    
                                    Text {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        text: (pillContainer.parent.itemData && pillContainer.parent.itemData.badge) ? pillContainer.parent.itemData.badge : ""
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                        color: Palette.palette().onError
                                    }
                                }
                            }
                        }
                        
                        // Label (expanded mode only) - positioned next to icon
                        Text {
                            id: expandedLabel
                            visible: root.showLabels && !!(pillContainer.parent.itemData && pillContainer.parent.itemData.label)
                            opacity: root._showExpandedLabels ? 1 : 0
                            x: iconContainer.x + iconContainer.width + 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: (pillContainer.parent.itemData && pillContainer.parent.itemData.label) ? pillContainer.parent.itemData.label : ""
                            font.pixelSize: 14
                            font.weight: pillContainer.parent.isSelected ? Font.Medium : Font.Normal
                            color: pillContainer.parent.isSelected ? 
                                   Palette.palette().onPrimaryContainer : 
                                   Palette.palette().onSurfaceVariant
                            
                            Behavior on x {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                            
                            Behavior on opacity {
                                NumberAnimation { 
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }
                            
                            Behavior on color {
                                ColorAnimation { 
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
                
                // Label below the pill (collapsed mode only, hidden if circular)
                Text {
                    visible: !root.showLabels && !root.circularCollapsed && !!(parent.itemData && parent.itemData.label)
                    opacity: root._showCollapsedLabels ? 1 : 0
                    anchors.top: pillContainer.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (parent.itemData && parent.itemData.label) ? parent.itemData.label : ""
                    font.pixelSize: 12
                    font.weight: parent.isSelected ? Font.Medium : Font.Normal
                    color: parent.isSelected ? 
                           Palette.palette().onSurface : 
                           Palette.palette().onSurfaceVariant
                    
                    Behavior on opacity {
                        NumberAnimation { 
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { 
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: {
                        var item = parent
                        if (item) item.hovered = true
                    }
                    onExited: {
                        var item = parent
                        if (item) item.hovered = false
                    }
                    
                    onClicked: {
                        var item = parent
                        if (item && item.itemData && item.itemData.onTriggered) {
                            item.itemData.onTriggered()
                        }
                        if (root && root.itemClicked) {
                            root.itemClicked(index)
                        }
                    }
                }
            }
        }
    }
}
