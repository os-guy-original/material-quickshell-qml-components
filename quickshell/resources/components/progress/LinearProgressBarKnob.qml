import QtQuick 2.15
import ".." as Components

Item {
    id: root
    property real progress: 0.0
    property color trackColor: Components.ColorPalette.isDarkMode ? Components.ColorPalette.surfaceVariant : Qt.darker(Components.ColorPalette.surfaceVariant, 1.15)
    property color progressColor: Components.ColorPalette.primary
    property real heightPixels: 14
    property string knobShape: "circle" // "circle" | "diamond" | "none"
    property real knobSize: 10

    implicitWidth: 260
    implicitHeight: heightPixels

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: trackColor
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: Math.max(0, Math.min(1, root.progress)) * track.width
            radius: height / 2
            color: progressColor
            Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }
    }

    // Knob kept fully within bounds
    Canvas {
        id: knob
        anchors.verticalCenter: parent.verticalCenter
        x: (Math.max(0, Math.min(1, root.progress)) * (root.width - knob.width))
        width: knobSize
        height: knobSize
        visible: knobShape !== "none"
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            ctx.fillStyle = progressColor
            if (root.knobShape === 'diamond') {
                ctx.save();
                ctx.translate(width/2, height/2)
                ctx.rotate(Math.PI/4)
                ctx.fillRect(-width/2, -height/2, width, height)
                ctx.restore();
            } else {
                ctx.beginPath();
                ctx.arc(width/2, height/2, Math.min(width, height)/2, 0, Math.PI*2)
                ctx.fill();
            }
        }
        Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }
}


