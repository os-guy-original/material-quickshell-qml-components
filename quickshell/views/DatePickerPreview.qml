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
    implicitWidth: 420
    implicitHeight: 520
    title: "Date Picker Preview"
    
    // Store original date for cancel
    property date _savedDate: new Date()

    Rectangle {
        anchors.fill: parent
        color: Components.ColorPalette.background
    }

    Navigation.HeaderBar {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: "Date Picker"
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

            Inputs.DatePicker {
                id: datePicker
                anchors.horizontalCenter: parent.horizontalCenter

                onDateChanged: function(newDate) {
                    console.log("Date changed:", newDate.toLocaleDateString())
                }

                onAccepted: {
                    console.log("Date accepted:", datePicker.selectedDate.toLocaleDateString())
                }

                onCancelled: {
                    console.log("Date selection cancelled")
                    window.visible = false
                }
            }
            
            // Button to open DatePicker as dialog
            Actions.Button {
                text: "Open as Dialog"
                tonal: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    // Store original date before opening
                    window._savedDate = new Date(dialogDatePicker.selectedDate.getTime())
                    datePickerDialog.open = true
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
                text: "Selected: " + datePicker.formatDate(datePicker.selectedDate)
                color: Components.ColorPalette.onSurfaceVariant
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: "Dialog: " + dialogDatePicker.formatDate(dialogDatePicker.selectedDate)
                color: Components.ColorPalette.onSurfaceVariant
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    // DatePicker Dialog
    Dialogs.Dialog {
        id: datePickerDialog
        title: "Select Date"
        text: ""
        primaryText: "OK"
        secondaryText: "Cancel"
        dismissible: true
        preferredWidth: 360
        
        onAccepted: {
            console.log("Dialog date accepted:", dialogDatePicker.selectedDate.toLocaleDateString())
        }
        
        onRejected: {
            // Restore original date on cancel
            dialogDatePicker.selectedDate = window._savedDate
            console.log("Dialog date cancelled - restored to:", window._savedDate.toLocaleDateString())
        }
        
        Inputs.DatePicker {
            id: dialogDatePicker
            anchors.horizontalCenter: parent.horizontalCenter
            showButtons: false
            transparentBackground: true
        }
    }
}
