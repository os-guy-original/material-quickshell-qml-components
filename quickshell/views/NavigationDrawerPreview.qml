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
    title: "Navigation Drawer Preview"
    color: Components.ColorPalette.surfaceVariant

    property int selectedSection: 0
    property int selectedItem: 0

    Row {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 40

        // Standard Navigation Drawer
        Column {
            spacing: 16
            
            // Label
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: Components.ColorPalette.inverseSurface
                anchors.horizontalCenter: standardDrawer.horizontalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "1"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Components.ColorPalette.inverseOnSurface
                }
            }
            
            Navigation.NavigationDrawer {
                id: standardDrawer
                width: 360
                headline: "Mail"
                modal: false
                
                sections: [
                    {
                        items: [
                            { 
                                icon: "inbox", 
                                label: "Inbox", 
                                badge: "24",
                                selected: selectedSection === 0 && selectedItem === 0,
                                onTriggered: function() { selectedSection = 0; selectedItem = 0 }
                            },
                            { 
                                icon: "send", 
                                label: "Outbox",
                                selected: selectedSection === 0 && selectedItem === 1,
                                onTriggered: function() { selectedSection = 0; selectedItem = 1 }
                            },
                            { 
                                icon: "favorite", 
                                label: "Favorites",
                                selected: selectedSection === 0 && selectedItem === 2,
                                onTriggered: function() { selectedSection = 0; selectedItem = 2 }
                            },
                            { 
                                icon: "delete", 
                                label: "Trash",
                                selected: selectedSection === 0 && selectedItem === 3,
                                onTriggered: function() { selectedSection = 0; selectedItem = 3 }
                            }
                        ]
                    },
                    {
                        title: "Labels",
                        items: [
                            { 
                                icon: "folder", 
                                label: "Label",
                                selected: selectedSection === 1 && selectedItem === 0,
                                onTriggered: function() { selectedSection = 1; selectedItem = 0 }
                            }
                        ]
                    }
                ]
            }
            
            Text {
                text: "Standard navigation drawer"
                font.pixelSize: 14
                color: Components.ColorPalette.onSurfaceVariant
                anchors.horizontalCenter: standardDrawer.horizontalCenter
            }
        }

        // Modal Navigation Drawer
        Column {
            spacing: 16
            
            // Label
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: Components.ColorPalette.inverseSurface
                anchors.horizontalCenter: modalDrawer.horizontalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "2"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Components.ColorPalette.inverseOnSurface
                }
            }
            
            Navigation.NavigationDrawer {
                id: modalDrawer
                width: 360
                headline: "Mail"
                modal: true
                
                sections: [
                    {
                        items: [
                            { 
                                icon: "inbox", 
                                label: "Inbox", 
                                badge: "24",
                                selected: selectedSection === 0 && selectedItem === 0,
                                onTriggered: function() { selectedSection = 0; selectedItem = 0 }
                            },
                            { 
                                icon: "send", 
                                label: "Outbox",
                                selected: selectedSection === 0 && selectedItem === 1,
                                onTriggered: function() { selectedSection = 0; selectedItem = 1 }
                            },
                            { 
                                icon: "favorite", 
                                label: "Favorites",
                                selected: selectedSection === 0 && selectedItem === 2,
                                onTriggered: function() { selectedSection = 0; selectedItem = 2 }
                            },
                            { 
                                icon: "delete", 
                                label: "Trash",
                                selected: selectedSection === 0 && selectedItem === 3,
                                onTriggered: function() { selectedSection = 0; selectedItem = 3 }
                            }
                        ]
                    },
                    {
                        title: "Labels",
                        items: [
                            { 
                                icon: "folder", 
                                label: "Label",
                                selected: selectedSection === 1 && selectedItem === 0,
                                onTriggered: function() { selectedSection = 1; selectedItem = 0 }
                            },
                            { 
                                icon: "folder", 
                                label: "Label",
                                selected: selectedSection === 1 && selectedItem === 1,
                                onTriggered: function() { selectedSection = 1; selectedItem = 1 }
                            }
                        ]
                    }
                ]
            }
            
            Text {
                text: "Modal navigation drawer"
                font.pixelSize: 14
                color: Components.ColorPalette.onSurfaceVariant
                anchors.horizontalCenter: modalDrawer.horizontalCenter
            }
        }
    }
}
