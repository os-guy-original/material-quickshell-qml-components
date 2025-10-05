import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root

    // Public API (visual only)
    // Use 48dp recommended touch target for Material
    property int diameter: 48
    property bool enabled: true
    property bool showBackground: true
    property bool showGlyph: true

    signal clicked()

    implicitWidth: diameter
    implicitHeight: diameter

    // Background tonal surface (Material You)
    Rectangle {
        id: background
        anchors.fill: parent
        radius: width / 2
        color: Palette.palette().surfaceVariant
        border.width: 0
        opacity: root.enabled ? 1.0 : 0.38
        antialiasing: true
        visible: root.showBackground
    }

    // Ink overlay for hover/pressed state
    Rectangle {
        id: overlay
        anchors.fill: background
        radius: background.radius
        color: Palette.palette().onSurface
        opacity: 0
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
    // Use onSurface for glyph to contrast with tonal background
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

    // Ripple for touch feedback
    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0; height: 0
        color: Palette.palette().onSurface
        opacity: 0
        radius: width/2
        z: 1
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onPressed: {
            overlay.opacity = 0.14
            ripple.width = root.diameter * 1.6; ripple.height = ripple.width; ripple.opacity = 0.12
        }
        onReleased: {
            overlay.opacity = containsMouse ? 0.06 : 0
            ripple.opacity = 0
        }
        onClicked: root.clicked()
    }
}


