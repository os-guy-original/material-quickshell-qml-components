import QtQuick 2.15
import ".." as Components

Rectangle {
    id: root
    
    property real cornerRadius: 24
    property color baseColor: Components.ColorPalette.primaryContainer
    property real progress: 0
    property int gradientOrientation: Gradient.Horizontal
    
    color: "transparent"
    radius: cornerRadius
    layer.enabled: true
    layer.smooth: true
    
    default property alias contentData: contentItem.data
    
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        
        gradient: Gradient {
            orientation: root.gradientOrientation
            GradientStop { position: 0.0; color: root.baseColor }
            GradientStop { position: root.progress; color: root.baseColor }
            GradientStop { position: 1.0; color: Qt.darker(root.baseColor, 1.4) }
        }
    }
    
    Item {
        id: contentItem
        anchors.fill: parent
    }
}
