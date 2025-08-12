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
        color: !root.enabled ? Qt.rgba(0.35,0.35,0.35,1)
               : (root.checked ? accent : Qt.lighter(Palette.palette().surfaceVariant, 1.25))
        opacity: 1.0
        // Show thicker outline when unchecked; also outline when checked but disabled
        border.width: (!root.checked ? 2 : (root.checked && !root.enabled ? 1 : 0))
        border.color: root.enabled ? Palette.palette().outline : Qt.rgba(0.5,0.5,0.5,1)
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        // Drag glow overlay that increases with thumb position while dragging/pressing
        Rectangle {
            id: dragGlow
            anchors.fill: parent
            radius: parent.radius
            // Material 3 state layer on track: uses onPrimary when checked, onSurface when unchecked
            color: root.enabled ? root.stateLayerColor : Qt.rgba(1,1,1,1)
            opacity: root.enabled ? ((mouse.drag.active || root.pressed) ? 0.12 : (root.hovered ? 0.08 : 0.0)) : 0.0
            visible: true
            Behavior on opacity { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
        }
    }

    // Container to keep position stable while inner thumb scales
    Item {
        id: thumbContainer
        width: 20; height: 20
        anchors.verticalCenter: parent.verticalCenter
        x: checked ? (parent.width - width - 6) : 6
        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Rectangle {
            id: thumb
            anchors.centerIn: parent
            width: 20; height: 20
            radius: 10
            // Thumb base colors per Material: onPrimary when checked, onSurface when unchecked
            color: root.enabled ? (root.checked ? Palette.palette().onPrimary : Palette.palette().onSurface) : Qt.rgba(0.82,0.82,0.82,1)
            border.width: (!root.enabled || root.checked) ? 0 : 1
            border.color: Palette.palette().outline
            scale: pressed ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on border.width { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        }
    }

    // normalized drag progress 0..1 across track
    property real minX: 6
    property real maxX: width - thumb.width - 6
    property real dragProgress: Math.max(0, Math.min(1, (thumbContainer.x - minX) / Math.max(1, (maxX - minX))))

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: root.enabled
        // disable drag when not enabled
        drag.target: root.enabled ? thumbContainer : undefined
        drag.axis: Drag.XAxis
        drag.minimumX: 6
        drag.maximumX: parent.width - thumb.width - 6
        onClicked: { if (root.enabled) { root.checked = !root.checked; root.toggled(root.checked); } }
        onPressedChanged: if (root.enabled) root.pressed = pressed
        onEntered: if (root.enabled) root.hovered = true
        onExited: { if (root.enabled) { root.hovered = false; root.pressed = false } }
        onReleased: {
            // decide state by handle position relative to track
            var minX = 6
            var maxX = parent.width - thumb.width - 6
            var midpoint = (minX + maxX) / 2
            var atEnd = thumbContainer.x >= midpoint
            if (root.enabled) {
                root.checked = atEnd
                root.toggled(root.checked)
            }
            // snap to the new state's exact endpoint
            thumbContainer.x = atEnd ? (parent.width - thumb.width - 6) : 6
        }
    }

    // Hover/press overlay for better affordance
    Rectangle {
        anchors.centerIn: thumbContainer
        width: 28
        height: 28
        radius: width / 2
        // Material 3 state layer on thumb: onPrimary when checked, onSurface when unchecked
        color: root.stateLayerColor
        opacity: enabled ? ((mouse.drag.active || pressed) ? 0.12 : (hovered ? 0.08 : 0.0)) : 0.0
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }
}


