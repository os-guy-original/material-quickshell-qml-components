import QtQuick 2.15
import ".." as Components

Item {
    id: root
    // Material-like circular indeterminate loader
    property real size: 28
    property color color: Qt.darker(Components.ColorPalette.primary, 1.2)
    property real strokeWidth: 3
    property bool running: true
    // speed and pulsing sweep
    property int periodMs: 700
    property real minSweep: Math.PI * 0.6
    property real maxSweep: Math.PI * 1.6

    implicitWidth: size
    implicitHeight: size

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var cx = width / 2
            var cy = height / 2
            var r = Math.min(width, height) / 2 - root.strokeWidth
            var t = Date.now()
            var start = (t % root.periodMs) / root.periodMs * Math.PI * 2
            // pulse sweep length
            var s = (Math.sin(t / (root.periodMs/2) * Math.PI) + 1) / 2
            var len = root.minSweep + s * (root.maxSweep - root.minSweep)
            ctx.lineWidth = root.strokeWidth
            ctx.lineCap = 'round'
            ctx.strokeStyle = root.color
            ctx.beginPath()
            ctx.arc(cx, cy, r, start, start + len, false)
            ctx.stroke()
        }
    }

    Timer {
        interval: 12
        running: root.running
        repeat: true
        onTriggered: canvas.requestPaint()
    }
}


