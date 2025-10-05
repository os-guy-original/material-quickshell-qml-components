import QtQuick 2.15
import "../../colors.js" as Palette

Rectangle {
    id: root
    // Slightly brighter than standard container; intended for small, rounded controls
    property int padding: 8
    property real cornerRadius: 14
    radius: cornerRadius
    color: Palette.isDarkMode() ? Qt.lighter(Palette.palette().surface, 1.08)
                                : Qt.darker(Palette.palette().surface, 1.03)
    border.width: 0
    clip: true

    // Content
    default property alias content: contentItem.data
    implicitWidth: Math.max(0, contentItem.childrenRect.width + padding * 2)
    implicitHeight: Math.max(0, contentItem.childrenRect.height + padding * 2)

    Item {
        id: contentItem
        x: root.padding
        y: root.padding
    }
}


