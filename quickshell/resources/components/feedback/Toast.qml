import QtQuick 2.15
import "../../colors.js" as Palette
import "../actions" as Actions

/*
  Toast - Simple notification that appears from screen edges
  
  Properties:
  - message: string - The text to display
  - position: string - "top", "bottom", "left", "right" (default: "bottom")
  - actionText: string - Optional action button text
  - duration: int - Auto-hide duration in ms (0 = no auto-hide)
  
  Signals:
  - actionClicked() - Emitted when action button is clicked
  - dismissed() - Emitted when toast is dismissed
*/

Item {
    id: root
    anchors.fill: parent
    
    property string message: "Toast notification"
    property string position: "bottom"  // top, bottom, left, right
    property string actionText: ""
    property int duration: 3000
    property bool showing: false
    
    signal actionClicked()
    signal dismissed()
    
    function show() {
        showing = true
        if (duration > 0) {
            hideTimer.restart()
        }
    }
    
    function hide() {
        showing = false
        dismissed()
    }
    
    Timer {
        id: hideTimer
        interval: root.duration
        onTriggered: root.hide()
    }
    
    // Toast container
    Rectangle {
        id: toast
        width: Math.min(contentRow.implicitWidth + 32, parent.width - 32)
        height: 56
        radius: 28
        color: Palette.palette().primaryContainer
        
        x: {
            if (position === "left") {
                return showing ? 16 : -width
            } else if (position === "right") {
                return showing ? parent.width - width - 16 : parent.width
            } else {
                return (parent.width - width) / 2
            }
        }
        
        y: {
            if (position === "top") {
                return showing ? 16 : -height
            } else if (position === "bottom") {
                return showing ? parent.height - height - 16 : parent.height
            } else {
                return (parent.height - height) / 2
            }
        }
        
        opacity: showing ? 1 : 0
        visible: opacity > 0
        
        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        Behavior on y {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 16
            
            Text {
                text: root.message
                font.pixelSize: 14
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Actions.Button {
                visible: root.actionText !== ""
                text: root.actionText
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    root.actionClicked()
                    root.hide()
                }
            }
        }
    }
}
