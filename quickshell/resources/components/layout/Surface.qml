import QtQuick 2.15
import ".." as Components

Rectangle {
    id: root

    // Material-like surface with outline
    property real cornerRadius: 14
    property real outlineWidth: 1
    property color surfaceColor: Components.ColorPalette.surface
    property color outlineColor: Components.ColorPalette.outline
    property real padding: 12

    color: surfaceColor
    radius: cornerRadius
    border.color: outlineColor
    border.width: outlineWidth

    default property alias content: contentItem.data

    implicitWidth: Math.max(contentItem.implicitWidth + padding * 2, 64)
    implicitHeight: Math.max(contentItem.implicitHeight + padding * 2, 32)

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: padding
    }
}


