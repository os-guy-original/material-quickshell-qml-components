import QtQuick 2.15
import QtQuick.Window 2.15
import "../resources/components" as Components
import "../resources/components/navigation" as Navigation
import "../resources/components/actions" as Actions

Window {
    id: window
    visible: true
    width: 1200
    height: 700
    title: "Navigation Rail Preview - Interactive Tabs"
    color: Components.ColorPalette.surface

    property int currentTab: 0

    Row {
        anchors.fill: parent
        spacing: 0

        // Navigation Rail
        Navigation.NavigationRail {
            id: navRail
            height: parent.height
            showLabels: navRail.showLabels
            circularCollapsed: currentTab === 2
            showMenuButton: true
            fabIcon: "dashboard"
            fabLabel: "Overview"
            onMenuClicked: navRail.showLabels = !navRail.showLabels
            
            items: [
                {
                    icon: "text_fields",
                    label: "With Labels",
                    selected: currentTab === 0,
                    onTriggered: function() { currentTab = 0 }
                },
                {
                    icon: "format_strikethrough",
                    label: "No Labels",
                    selected: currentTab === 1,
                    onTriggered: function() { currentTab = 1 }
                },
                {
                    icon: "radio_button_unchecked",
                    label: "Circular",
                    selected: currentTab === 2,
                    onTriggered: function() { currentTab = 2 }
                },
                {
                    icon: "auto_awesome",
                    label: "Animated",
                    badge: "NEW",
                    selected: currentTab === 3,
                    onTriggered: function() { currentTab = 3 }
                }
            ]
        }

        // Content Area
        Rectangle {
            width: parent.width - navRail.width
            height: parent.height
            color: Components.ColorPalette.surfaceVariant
            
            // Tab content
            Item {
                anchors.fill: parent
                anchors.margins: 40
                
                // Tab 0: With Labels
                Column {
                    visible: opacity > 0
                    opacity: currentTab === 0 ? 1 : 0
                    anchors.centerIn: parent
                    spacing: 24
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        text: "With Labels (Collapsed)"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: Components.ColorPalette.onSurface
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Icons with text labels below them"
                        font.pixelSize: 16
                        color: Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Rectangle {
                        width: 400
                        height: 400
                        color: Components.ColorPalette.surface
                        radius: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Navigation.NavigationRail {
                            anchors.centerIn: parent
                            height: 350
                            showLabels: false
                            fabIcon: "edit"
                            fabLabel: "Compose"
                            
                            property int selected: 0
                            
                            items: [
                                { icon: "inbox", label: "Inbox", selected: selected === 0, onTriggered: function() { selected = 0 } },
                                { icon: "send", label: "Sent", badge: "3", selected: selected === 1, onTriggered: function() { selected = 1 } },
                                { icon: "favorite", label: "Favorites", selected: selected === 2, onTriggered: function() { selected = 2 } }
                            ]
                        }
                    }
                }
                
                // Tab 1: No Labels
                Column {
                    visible: opacity > 0
                    opacity: currentTab === 1 ? 1 : 0
                    anchors.centerIn: parent
                    spacing: 24
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        text: "No Labels (Icons Only)"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: Components.ColorPalette.onSurface
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Just icons, no text labels"
                        font.pixelSize: 16
                        color: Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Rectangle {
                        width: 400
                        height: 400
                        color: Components.ColorPalette.surface
                        radius: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Navigation.NavigationRail {
                            anchors.centerIn: parent
                            height: 350
                            showLabels: false
                            fabIcon: "add"
                            fabLabel: "Create"
                            
                            property int selected: 0
                            
                            items: [
                                { icon: "home", selected: selected === 0, onTriggered: function() { selected = 0 } },
                                { icon: "search", badge: "5", selected: selected === 1, onTriggered: function() { selected = 1 } },
                                { icon: "settings", selected: selected === 2, onTriggered: function() { selected = 2 } }
                            ]
                        }
                    }
                }
                
                // Tab 2: Circular
                Column {
                    visible: opacity > 0
                    opacity: currentTab === 2 ? 1 : 0
                    anchors.centerIn: parent
                    spacing: 24
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        text: "Circular Collapsed Buttons"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: Components.ColorPalette.onSurface
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Perfect circles instead of pills"
                        font.pixelSize: 16
                        color: Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Rectangle {
                        width: 400
                        height: 400
                        color: Components.ColorPalette.surface
                        radius: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Navigation.NavigationRail {
                            anchors.centerIn: parent
                            height: 350
                            showLabels: false
                            circularCollapsed: true
                            fabIcon: "menu"
                            fabLabel: "Menu"
                            
                            property int selected: 0
                            
                            items: [
                                { icon: "notifications", badge: "2", selected: selected === 0, onTriggered: function() { selected = 0 } },
                                { icon: "mail", selected: selected === 1, onTriggered: function() { selected = 1 } },
                                { icon: "person", selected: selected === 2, onTriggered: function() { selected = 2 } }
                            ]
                        }
                    }
                }
                
                // Tab 3: Animated
                Column {
                    visible: opacity > 0
                    opacity: currentTab === 3 ? 1 : 0
                    anchors.centerIn: parent
                    spacing: 24
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        text: "Animated Expand/Collapse"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: Components.ColorPalette.onSurface
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Click the button to see the animation"
                        font.pixelSize: 16
                        color: Components.ColorPalette.onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Actions.Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: animatedRail.showLabels ? "Collapse" : "Expand"
                        onClicked: animatedRail.showLabels = !animatedRail.showLabels
                    }
                    
                    Rectangle {
                        width: 400
                        height: 400
                        color: Components.ColorPalette.surface
                        radius: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Navigation.NavigationRail {
                            id: animatedRail
                            anchors.centerIn: parent
                            height: 350
                            showLabels: false
                            fabIcon: "star"
                            fabLabel: "Featured"
                            
                            property int selected: 1
                            
                            items: [
                                { icon: "inbox", label: "Inbox", selected: selected === 0, onTriggered: function() { selected = 0 } },
                                { icon: "send", label: "Sent", badge: "3", selected: selected === 1, onTriggered: function() { selected = 1 } },
                                { icon: "favorite", label: "Favorites", selected: selected === 2, onTriggered: function() { selected = 2 } }
                            ]
                        }
                    }
                }
            }
        }
    }
}
