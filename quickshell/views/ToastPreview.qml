import QtQuick 2.15
import QtQuick.Window 2.15
import "../resources/components" as Components
import "../resources/components/feedback" as Feedback
import "../resources/components/actions" as Actions

Window {
    id: window
    visible: true
    width: 800
    height: 600
    title: "Toast Notification Preview"
    color: Components.ColorPalette.surface

    Column {
        anchors.centerIn: parent
        spacing: 16
        
        Text {
            text: "Toast Notifications"
            font.pixelSize: 32
            font.weight: Font.Bold
            color: Components.ColorPalette.onSurface
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: "Click buttons to show toasts from different positions"
            font.pixelSize: 14
            color: Components.ColorPalette.onSurfaceVariant
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            
            Actions.Button {
                text: "Bottom"
                onClicked: bottomToast.show()
            }
            
            Actions.Button {
                text: "Top"
                onClicked: topToast.show()
            }
            
            Actions.Button {
                text: "Left"
                onClicked: leftToast.show()
            }
            
            Actions.Button {
                text: "Right"
                onClicked: rightToast.show()
            }
        }
        
        Actions.Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "With Action"
            onClicked: actionToast.show()
        }
    }
    
    // Toast notifications
    Feedback.Toast {
        id: bottomToast
        message: "Message sent successfully"
        position: "bottom"
        duration: 3000
    }
    
    Feedback.Toast {
        id: topToast
        message: "File downloaded"
        position: "top"
        duration: 3000
    }
    
    Feedback.Toast {
        id: leftToast
        message: "Settings saved"
        position: "left"
        duration: 3000
    }
    
    Feedback.Toast {
        id: rightToast
        message: "Connection established"
        position: "right"
        duration: 3000
    }
    
    Feedback.Toast {
        id: actionToast
        message: "Item deleted"
        position: "bottom"
        actionText: "UNDO"
        duration: 5000
        onActionClicked: console.log("Undo clicked!")
    }
}
