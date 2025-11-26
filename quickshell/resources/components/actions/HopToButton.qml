import QtQuick 2.15
import Quickshell.Hyprland
import ".." as Components
import "../typography" as Type
import "../feedback" as Feedback
import "../behavior" as BehaviorComponents
import "../../../shell/utils/hyprland.js" as HyprlandUtils

Item {
    id: root
    
    property string appName: ""
    property string desktopEntry: ""
    property int cornerRadius: 16
    
    BehaviorComponents.HoverDetector {
        id: hoverDetector
    }
    
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: mouseArea.containsMouse ? 1 : 0
        visible: opacity > 0
        clip: true
        layer.enabled: true
        layer.smooth: true
        
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        
        Feedback.RippleEffect {
            id: ripple
            rippleColor: Qt.rgba(1, 1, 1, 0.3)
        }
        
        Column {
            anchors.centerIn: parent
            spacing: 2
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                
                Text {
                    text: "Hop To"
                    font.pixelSize: 12
                    color: Components.ColorPalette.onSurface
                }
                
                Text {
                    text: "→"
                    font.pixelSize: 14
                    font.bold: true
                    color: Components.ColorPalette.onSurface
                }
            }
            
            Type.Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.appName
                pixelSize: 14
                bold: true
                color: Components.ColorPalette.onSurface
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: function(mouse) { ripple.startHold(mouse.x, mouse.y) }
        onReleased: ripple.endHold()
        onCanceled: ripple.endHold()
        onClicked: {
            console.log("[HopToButton] Clicked! appName:", root.appName, "desktopEntry:", root.desktopEntry);
            
            if (!root.desktopEntry) {
                console.log("[HopToButton] No desktop entry provided");
                return;
            }
            
            var workspace = HyprlandUtils.findWorkspaceByClass(Hyprland, root.desktopEntry);
            if (!workspace) {
                console.log("[HopToButton] Trying by title...");
                workspace = HyprlandUtils.findWorkspaceByTitle(Hyprland, root.appName);
            }
            
            if (workspace) {
                console.log("[HopToButton] Activating workspace:", workspace.name);
                workspace.activate();
            } else {
                console.log("[HopToButton] No workspace found!");
            }
        }
    }
}
