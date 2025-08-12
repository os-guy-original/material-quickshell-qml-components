import QtQuick 2.15
import "../../colors.js" as Palette
import "../icons" as Icon

Item {
    id: root
    property string iconName: ""
    property url iconSource: ""
    property bool enabled: true
    property int diameter: 36
    signal clicked()

    implicitWidth: diameter
    implicitHeight: diameter

    Rectangle {
        id: background
        anchors.fill: parent
        radius: width / 2
        // Neutral surface-ish background, no primary/tonal usage
        color: Palette.isDarkMode() ? Qt.lighter(Palette.palette().surface, 1.08)
                                    : Qt.darker(Palette.palette().surface, 1.03)
        border.width: 0
        opacity: root.enabled ? 1.0 : 0.38
        antialiasing: true
    }

    Item {
        id: iconHolder
        anchors.centerIn: background
        width: Math.round(root.diameter * 0.60)
        height: width

        Icon.Icon {
            anchors.fill: parent
            name: root.iconName
            size: parent.width
            color: Palette.palette().onSurface
            visible: root.iconName && root.iconName.length > 0
        }
        Image {
            anchors.fill: parent
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            visible: !(root.iconName && root.iconName.length > 0) && root.iconSource !== ""
            smooth: true
            cache: true
        }
    }

    // Hover/press overlay without using primary/tonal colors
    Rectangle {
        anchors.fill: background
        radius: background.radius
        color: Palette.palette().onSurface
        opacity: mouseArea.pressed ? 0.14 : (mouseArea.containsMouse ? 0.06 : 0.0)
        visible: root.enabled
        Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}


