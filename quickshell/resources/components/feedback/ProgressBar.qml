import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root
    property real value: 0.5 // 0..1
    property bool indeterminate: false
    property int heightPixels: 4
    implicitHeight: heightPixels
    implicitWidth: 200

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Palette.palette().surfaceVariant
        clip: true

        // determinate bar
        Rectangle {
            visible: !root.indeterminate
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: Math.max(0, Math.min(1, root.value)) * track.width
            radius: height / 2
            color: Palette.palette().primary
            Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }

        // indeterminate sweeping segment
        Rectangle {
            id: sweep
            visible: root.indeterminate
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: track.width * 0.25
            radius: height / 2
            color: Palette.palette().primary
            x: -width
            SequentialAnimation on x {
                running: root.indeterminate
                loops: Animation.Infinite
                NumberAnimation { from: -sweep.width; to: track.width; duration: 900; easing.type: Easing.InOutQuad }
            }
        }
    }
}


