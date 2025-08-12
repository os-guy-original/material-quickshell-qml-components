import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root
    property int itemSize: 48
    property int spacingSize: 6
    property int selectedIndex: -1
    default property alias content: items.data

    implicitWidth: items.implicitWidth + 16
    implicitHeight: items.implicitHeight + 16

    Column {
        id: items
        anchors.fill: parent
        anchors.margins: 8
        spacing: spacingSize
    }
}


