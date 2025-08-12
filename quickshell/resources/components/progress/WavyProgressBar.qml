import QtQuick 2.15
import "../../colors.js" as Palette
import "../../metrics.js" as Metrics

Item {
    id: root
    // Generic wavy progress bar (Material You-like squiggle)
    property real progress: 0.0 // 0..1
    property color trackColor: Palette.palette().surfaceVariant
    property color progressColor: Palette.palette().primary
    property real amplitude: 8            // px
    property real wavelength: 32          // px
    property real strokeWidth: 4          // px
    property real phase: 0                // optional phase shift
    property string knobShape: "circle"   // "none" | "circle" | "diamond"
    property real knobSize: 12
    // Use the same tiny end tip for visual consistency if someone disables knob
    property bool showEndTip: false

    implicitWidth: 240
    // ensure enough vertical room for wave + knob without clipping
    implicitHeight: Math.max(2 * amplitude + knobSize + strokeWidth, knobSize + strokeWidth)
    clip: false

    function yAt(x) {
        var mid = height / 2
        if (wavelength <= 0) return mid
        return mid + amplitude * Math.sin(phase + (x / wavelength) * Math.PI * 2)
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()

            var w = width
            var h = height
            var mid = h / 2

            // keep knob fully visible by padding drawing area
            var pad = (root.knobShape !== 'none') ? root.knobSize / 2 : 0
            var startX = pad
            var endX = w - pad
            var drawW = Math.max(1, endX - startX)

            // effective amplitude considering available height and knob size
            var amp = Math.max(0, Math.min(root.amplitude, (h - (root.knobSize + root.strokeWidth)) / 2))
            function yOf(x) { return mid + amp * Math.sin(root.phase + (x / root.wavelength) * Math.PI * 2) }

            // draw full track squiggle
            ctx.lineWidth = strokeWidth
            ctx.lineCap = 'round'
            ctx.lineJoin = 'round'
            ctx.strokeStyle = trackColor
            ctx.beginPath()
            ctx.moveTo(startX, yOf(startX))
            for (var x = startX + 1; x <= endX; x += 1) {
                ctx.lineTo(x, yOf(x))
            }
            ctx.stroke()

            // draw progress portion on top
            var clamped = Math.max(0, Math.min(1, root.progress))
            var pw = startX + clamped * drawW
            if (pw > startX) {
                ctx.strokeStyle = progressColor
                ctx.beginPath()
                ctx.moveTo(startX, yOf(startX))
                for (var x2 = startX + 1; x2 <= pw; x2 += 1) {
                    ctx.lineTo(x2, yOf(x2))
                }
                ctx.stroke()
            }

            // draw knob at progress position
            if (root.knobShape !== 'none') {
                var kx = pw
                var ky = yOf(kx)
                var s = knobSize
                ctx.fillStyle = progressColor
                ctx.save()
                ctx.translate(kx, ky)
                if (root.knobShape === 'diamond') {
                    ctx.rotate(Math.PI / 4)
                    ctx.fillRect(-s/2, -s/2, s, s)
                } else { // circle
                    ctx.beginPath()
                    ctx.arc(0, 0, s/2, 0, Math.PI * 2)
                    ctx.fill()
                }
                ctx.restore()
            } else if (root.showEndTip) {
                // tiny end tip line segment for consistency
                var tipLen = Math.max(2, Metrics.endTipLength)
                var mid = h / 2
                ctx.strokeStyle = progressColor
                ctx.lineCap = 'round'
                ctx.beginPath()
                ctx.moveTo(Math.max(startX, pw - tipLen), mid)
                ctx.lineTo(pw, mid)
                ctx.stroke()
            }
        }

        Behavior on width { NumberAnimation { duration: 120 } }
        Behavior on height { NumberAnimation { duration: 120 } }
    }

    onProgressChanged: canvas.requestPaint()
    onAmplitudeChanged: canvas.requestPaint()
    onWavelengthChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()
    onPhaseChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onProgressColorChanged: canvas.requestPaint()
    onKnobShapeChanged: canvas.requestPaint()
    onKnobSizeChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()
}



