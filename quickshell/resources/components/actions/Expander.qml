import QtQuick 2.15
import ".." as Components
import "../feedback" as Feedback

Rectangle {
    id: root
    
    // Public properties
    property bool expanded: false
    property bool hasBackground: true
    property color backgroundColor: Components.ColorPalette.surfaceVariant
    property color iconColor: Components.ColorPalette.onSurfaceVariant
    property int size: 28
    property int iconSize: 16
    property string direction: "vertical" // "vertical" or "horizontal"
    
    // Signals
    signal clicked()
    signal toggled(bool isExpanded)
    
    // Visual properties
    width: size
    height: size
    radius: size / 2
    color: hasBackground ? backgroundColor : "transparent"
    
    Behavior on color {
        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    
    // Use Material Icons chevron
    Text {
        id: chevronIcon
        anchors.centerIn: parent
        text: "\uE5CC"  // expand_more icon
        font.family: "Material Icons"
        font.pixelSize: root.iconSize
        color: root.iconColor
        rotation: root.expanded ? (root.direction === "vertical" ? 270 : 180) : (root.direction === "vertical" ? 90 : 0)
        transformOrigin: Item.Center
        
        Behavior on rotation {
            NumberAnimation { 
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onClicked: {
            root.expanded = !root.expanded
            root.clicked()
            root.toggled(root.expanded)
        }
        
        onEntered: {
            if (root.hasBackground) {
                root.color = Qt.lighter(root.backgroundColor, 1.15)
            }
        }
        
        onExited: {
            if (root.hasBackground) {
                root.color = root.backgroundColor
            }
        }
    }
}
