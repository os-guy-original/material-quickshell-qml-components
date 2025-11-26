import QtQuick 2.15
import ".." as Components

Item {
    id: root
    property real value: 0.5 // 0..1
    property bool indeterminate: false
    property int heightPixels: 4
    property int gap: 4 // Horizontal gap on left and right sides of the stick
    implicitHeight: heightPixels
    implicitWidth: 200

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Components.ColorPalette.surfaceVariant
        clip: true

        // determinate bar with horizontal gaps
        Rectangle {
            visible: !root.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            x: root.gap
            width: Math.max(0, Math.min(1, root.value)) * (track.width - root.gap * 2)
            radius: height / 2
            color: Components.ColorPalette.primary
            Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }

        // indeterminate sweeping segment with horizontal gaps
        Rectangle {
            id: sweep
            visible: root.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: (track.width - root.gap * 2) * 0.25
            radius: height / 2
            color: Components.ColorPalette.primary
            x: root.gap - width
            SequentialAnimation on x {
                running: root.indeterminate
                loops: Animation.Infinite
                NumberAnimation { from: root.gap - sweep.width; to: track.width - root.gap; duration: 900; easing.type: Easing.InOutQuad }
            }
        }
    }
}


