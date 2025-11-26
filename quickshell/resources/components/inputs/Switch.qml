import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root
    property bool checked: false
    property bool enabled: true
    property color accent: Palette.palette().primary
    property bool hovered: false
    property bool pressed: false
    signal toggled(bool checked)

    implicitWidth: 52
    implicitHeight: 32

    // Material 3 state layer color depending on selected state
    property color stateLayerColor: checked ? Palette.palette().onPrimary : Palette.palette().onSurface

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: {
            if (!root.enabled) {
                return root.checked ? Qt.rgba(0.28,0.28,0.28,1) : Qt.rgba(0.18,0.18,0.18,1)
            }
            
            var inactiveColor = Palette.isDarkMode() 
                ? Qt.darker(Palette.palette().surfaceVariant, 1.4)
                : Qt.darker(Palette.palette().background, 1.15)
            var activeColor = accent
            
            return root.checked ? activeColor : inactiveColor
        }
        opacity: !root.enabled ? 0.5 : 1.0
        border.width: (!root.checked ? 2 : (root.checked && !root.enabled ? 1 : 0))
        border.color: root.enabled ? Palette.palette().onSurface : Qt.rgba(0.35,0.35,0.35,1)
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        // Hover/press overlay
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: root.enabled ? root.stateLayerColor : Qt.rgba(1,1,1,1)
            opacity: root.enabled ? (root.pressed ? 0.12 : (root.hovered ? 0.08 : 0.0)) : 0.0
            Behavior on opacity { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
        }
    }

    Item {
        id: thumbContainer
        width: 24; height: 24
        anchors.verticalCenter: parent.verticalCenter
        x: checked ? (parent.width - width - 4) : 4
        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Rectangle {
            id: thumb
            anchors.centerIn: parent
            width: 24; height: 24
            radius: 12
            color: {
                if (!root.enabled) {
                    return root.checked ? Qt.rgba(0.5,0.5,0.5,1) : Qt.rgba(0.45,0.45,0.45,1)
                }
                return root.checked ? Palette.palette().onPrimary : Palette.palette().onSurfaceVariant
            }
            border.width: (!root.enabled || root.checked) ? 0 : 1
            border.color: Palette.palette().onSurface
            scale: pressed ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on border.width { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

            Canvas {
                id: symbolCanvas
                anchors.centerIn: parent
                width: 12
                height: 12
                onPaint: {
                    var ctx = getContext('2d')
                    ctx.reset()
                    
                    if (root.checked) {
                        ctx.strokeStyle = root.enabled ? root.accent : Qt.rgba(0.28,0.28,0.28,1)
                        ctx.lineWidth = 2
                        ctx.lineCap = 'round'
                        ctx.lineJoin = 'round'
                        ctx.beginPath()
                        ctx.moveTo(2, 6)
                        ctx.lineTo(5, 9)
                        ctx.lineTo(10, 3)
                        ctx.stroke()
                    } else {
                        if (root.enabled) {
                            var inactiveColor = Palette.isDarkMode() ? Palette.palette().surfaceVariant : Qt.darker(Palette.palette().background, 1.08)
                            ctx.strokeStyle = inactiveColor
                        } else {
                            ctx.strokeStyle = Qt.rgba(0.22,0.22,0.22,1)
                        }
                        ctx.lineWidth = 2
                        ctx.lineCap = 'round'
                        ctx.beginPath()
                        ctx.moveTo(3, 3)
                        ctx.lineTo(9, 9)
                        ctx.moveTo(9, 3)
                        ctx.lineTo(3, 9)
                        ctx.stroke()
                    }
                }
                
                Connections {
                    target: root
                    function onCheckedChanged() { symbolCanvas.requestPaint() }
                    function onEnabledChanged() { symbolCanvas.requestPaint() }
                    function onAccentChanged() { symbolCanvas.requestPaint() }
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: root.enabled
        onClicked: { 
            if (root.enabled) { 
                root.checked = !root.checked
                root.toggled(root.checked)
            } 
        }
        onPressedChanged: if (root.enabled) root.pressed = pressed
        onEntered: if (root.enabled) root.hovered = true
        onExited: { if (root.enabled) { root.hovered = false; root.pressed = false } }
    }

    Rectangle {
        anchors.centerIn: thumbContainer
        width: 28
        height: 28
        radius: width / 2
        color: root.stateLayerColor
        opacity: enabled ? (pressed ? 0.12 : (hovered ? 0.08 : 0.0)) : 0.0
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }
}


