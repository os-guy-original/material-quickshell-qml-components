import QtQuick 2.15
import QtQuick.Window 2.15
import "../resources/components" as Components
import "../resources/components/navigation" as Navigation

Window {
    id: window
    visible: true
    width: 900
    height: 500
    title: "Tabs Preview"
    color: Components.ColorPalette.surfaceVariant

    Column {
        anchors.centerIn: parent
        spacing: 60

        // Primary Tabs
        Column {
            spacing: 16
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Label
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Components.ColorPalette.inverseSurface
                    
                    Text {
                        anchors.centerIn: parent
                        text: "1"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: Components.ColorPalette.inverseOnSurface
                    }
                }
            }
            
            Navigation.Tabs {
                id: primaryTabs
                variant: "primary"
                currentIndex: 0
                
                tabs: [
                    { icon: "flight", label: "Flights" },
                    { icon: "luggage", label: "Trips" },
                    { icon: "explore", label: "Explore" }
                ]
                
                onTabClicked: console.log("Primary tab clicked:", index)
            }
            
            Text {
                text: "Primary tabs"
                font.pixelSize: 14
                color: Components.ColorPalette.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Secondary Tabs
        Column {
            spacing: 16
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Label
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Components.ColorPalette.inverseSurface
                    
                    Text {
                        anchors.centerIn: parent
                        text: "2"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: Components.ColorPalette.inverseOnSurface
                    }
                }
            }
            
            Navigation.Tabs {
                id: secondaryTabs
                variant: "secondary"
                currentIndex: 0
                
                tabs: [
                    { label: "Overview" },
                    { label: "Specifications" }
                ]
                
                onTabClicked: console.log("Secondary tab clicked:", index)
            }
            
            Text {
                text: "Secondary tabs"
                font.pixelSize: 14
                color: Components.ColorPalette.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
