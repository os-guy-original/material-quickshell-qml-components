import QtQuick 2.15
import ".." as Components

Rectangle {
    id: root
    // Slightly brighter than standard container; intended for small, rounded controls
    property int padding: 8
    property real cornerRadius: 14
    property var colorOverride: null
    radius: cornerRadius
    color: colorOverride !== null ? colorOverride
                                  : Qt.lighter(Components.ColorPalette.surface, 1.08)
    border.width: 0
    clip: true

    // Content
    default property alias content: contentItem.data
    implicitWidth: contentItem.childrenRect.width + padding * 2
    implicitHeight: contentItem.childrenRect.height + padding * 2

    Item {
        id: contentItem
        x: root.padding
        y: root.padding
    }
}


