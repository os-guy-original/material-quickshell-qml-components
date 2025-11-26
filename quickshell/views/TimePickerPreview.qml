import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/inputs" as Inputs
import "../resources/components/layout" as LayoutComponents
import "../resources/components/actions" as Actions
import "../resources/components/navigation" as Navigation
import "../resources/components/dialogs" as Dialogs

FloatingWindow {
    id: window
    visible: true
    implicitWidth: 380
    implicitHeight: 580
    title: "Time Picker Preview"
    
    // Store original values for cancel
    property int _savedHour: 0
    property int _savedMinute: 0

    Rectangle {
        anchors.fill: parent
        color: Components.ColorPalette.background
    }

    Navigation.HeaderBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: "Time Picker"
        titleAlignment: "center"
        onCloseRequested: window.visible = false
        z: 10
    }

    LayoutComponents.Container {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: infoBar.top
        anchors.margins: 16

        Column {
            anchors.centerIn: parent
            spacing: 16

            Inputs.TimePicker {
                id: timePicker
                anchors.horizontalCenter: parent.horizontalCenter
                minuteStep: 5

                onTimeChanged: function(h, m) {
                    console.log("Time changed:", h + ":" + (m < 10 ? "0" + m : m))
                }
                
                onAccepted: console.log("Time accepted:", timePicker.hour + ":" + timePicker.pad2(timePicker.minute))
                onCancelled: console.log("Time picker cancelled")
            }
            
            // Button to open TimePicker as dialog
            Actions.Button {
                text: "Open as Dialog"
                tonal: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    // Store original values before opening
                    window._savedHour = dialogTimePicker.hour
                    window._savedMinute = dialogTimePicker.minute
                    timePickerDialog.open = true
                }
            }
        }
    }

    // Bottom info bar
    Rectangle {
        id: infoBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 40
        color: Components.ColorPalette.surfaceVariant

        Row {
            anchors.centerIn: parent
            spacing: 16
            
            Text {
                text: "Selected: " + timePicker.displayHour() + ":" + timePicker.pad2(timePicker.minute) + (timePicker.is24h ? "" : (timePicker.hour < 12 ? " AM" : " PM"))
                color: Components.ColorPalette.onSurfaceVariant
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: "Dialog: " + dialogTimePicker.displayHour() + ":" + dialogTimePicker.pad2(dialogTimePicker.minute) + (dialogTimePicker.is24h ? "" : (dialogTimePicker.hour < 12 ? " AM" : " PM"))
                color: Components.ColorPalette.onSurfaceVariant
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    // TimePicker Dialog
    Dialogs.Dialog {
        id: timePickerDialog
        title: "Select Time"
        text: ""
        primaryText: "OK"
        secondaryText: "Cancel"
        dismissible: true
        preferredWidth: 360
        
        onAccepted: {
            console.log("Dialog time accepted:", dialogTimePicker.hour + ":" + dialogTimePicker.pad2(dialogTimePicker.minute))
        }
        
        onRejected: {
            // Restore original values on cancel
            dialogTimePicker.hour = window._savedHour
            dialogTimePicker.minute = window._savedMinute
            console.log("Dialog time cancelled - restored to:", window._savedHour + ":" + dialogTimePicker.pad2(window._savedMinute))
        }
        
        Inputs.TimePicker {
            id: dialogTimePicker
            anchors.horizontalCenter: parent.horizontalCenter
            showHeader: false
            showButtons: false
            transparentBackground: true
        }
    }
}
