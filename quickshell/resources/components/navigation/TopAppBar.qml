import QtQuick 2.15
import "../../colors.js" as Palette

Rectangle {
    id: root
    property alias title: titleText.text
    // Add action items as children of the bar; they will be placed on the right
    default property alias actionItems: actions.data

    property real barHeight: 56
    property color backgroundColor: Palette.palette().surface
    property color foregroundColor: Palette.palette().onSurface

    color: backgroundColor
    height: barHeight
    width: parent ? parent.width : implicitWidth
    border.width: 0

    Text {
        id: titleText
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        color: foregroundColor
        text: "Title"
        font.pixelSize: 18
    }

    Row {
        id: actions
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}


