import QtQuick 2.15
import "../../colors.js" as Palette

Rectangle {
    id: root

    property real padding: 16
    property real cornerRadius: 12
    property color backgroundColor: Palette.palette().surface
    property color outlineColor: Palette.palette().outline

    color: backgroundColor
    radius: cornerRadius
    border.width: 1
    border.color: outlineColor

    implicitWidth: Math.max(contentItem.implicitWidth + padding * 2, 160)
    implicitHeight: Math.max(contentItem.implicitHeight + padding * 2, 100)

    default property alias content: contentItem.data

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: padding
    }
}


