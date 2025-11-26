import QtQuick 2.15
import Quickshell
import "../resources/components" as Components

PanelWindow {
    id: window
    width: 800
    height: 600
    visible: true
    color: Components.ColorPalette.surface

    Rectangle {
        anchors.fill: parent
        color: Components.ColorPalette.surface

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "Button Ripple Effect Test"
                font.pixelSize: 24
                color: Components.ColorPalette.onSurface
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Contained button (default)
            Components.Button {
                text: "Contained Button"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: console.log("Contained button clicked")
            }

            // Outlined button
            Components.Button {
                text: "Outlined Button"
                outlined: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: console.log("Outlined button clicked")
            }

            // Tonal button
            Components.Button {
                text: "Tonal Button"
                tonal: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: console.log("Tonal button clicked")
            }

            // Text button
            Components.Button {
                text: "Text Button"
                textButton: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: console.log("Text button clicked")
            }

            // Danger button
            Components.Button {
                text: "Danger Button"
                kind: "danger"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: console.log("Danger button clicked")
            }

            // Disabled button
            Components.Button {
                text: "Disabled Button"
                enabled: false
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Click buttons to see ripple effects"
                font.pixelSize: 12
                color: Components.ColorPalette.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 20
            }
        }
    }
}
