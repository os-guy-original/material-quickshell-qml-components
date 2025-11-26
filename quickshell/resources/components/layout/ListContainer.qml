import QtQuick 2.15
import ".." as Components

Rectangle {
    id: root
    color: Components.ColorPalette.surface
    radius: 12
    // No border; slightly darker than surface via overlay
    layer.enabled: true
    layer.smooth: true
    property alias content: listContent.data
    property int padding: 8

    default property alias children: listContent.data

    // Provide natural size so it lays out correctly in Columns/Rows
    implicitWidth: Math.max(192, listContent.implicitWidth + padding * 2)
    implicitHeight: listContent.implicitHeight + padding * 2

    Column {
        id: listContent
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: 4
    }
}


