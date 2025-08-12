import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root

    // Public API (visual only)
    property int diameter: 36
    property bool enabled: true
    property bool showBackground: true
    property bool showGlyph: true

    signal clicked()

    implicitWidth: diameter
    implicitHeight: diameter

    // Background pill
    Rectangle {
        id: background
        anchors.fill: parent
        radius: width / 2
        color: Palette.isDarkMode() ? Qt.lighter(Palette.palette().surface, 1.08)
                                    : Qt.darker(Palette.palette().surface, 1.03)
        border.width: 0
        opacity: root.enabled ? 1.0 : 0.38
        antialiasing: true
        visible: root.showBackground
    }

    // Hover/press overlay
    Rectangle {
        id: overlay
        anchors.fill: background
        radius: background.radius
        color: Palette.palette().onSurface
        opacity: mouseArea.pressed ? 0.14 : (mouseArea.containsMouse ? 0.06 : 0.0)
        visible: root.enabled
        Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
    }

    // Hamburger glyph (three bars)
    Item {
        id: glyph
        anchors.centerIn: parent
        width: Math.round(root.diameter * 0.60)
        height: width
        visible: root.showGlyph

        readonly property int barThickness: Math.max(2, Math.round(width * 0.08))
        readonly property int barLength: Math.round(width * 0.80)
        readonly property color barColor: Palette.palette().onSurface

        Rectangle { // top
            width: glyph.barLength
            height: glyph.barThickness
            radius: height / 2
            color: glyph.barColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            y: -Math.round(glyph.barLength * 0.18)
        }
        Rectangle { // middle
            width: glyph.barLength
            height: glyph.barThickness
            radius: height / 2
            color: glyph.barColor
            anchors.centerIn: parent
        }
        Rectangle { // bottom
            width: glyph.barLength
            height: glyph.barThickness
            radius: height / 2
            color: glyph.barColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            y: Math.round(glyph.barLength * 0.18)
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onClicked: root.clicked()
    }
}


