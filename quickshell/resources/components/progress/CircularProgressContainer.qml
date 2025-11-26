import QtQuick 2.15
import ".." as Components
import "../../metrics.js" as Metrics

Item {
    id: root
    // Determinate circular progress with a center slot
    property real progress: 0.0 // 0..1
    property color trackColor: Components.ColorPalette.isDarkMode ? Components.ColorPalette.surfaceVariant : Qt.darker(Components.ColorPalette.surfaceVariant, 1.15)
    property color progressColor: Components.ColorPalette.primary
    property real strokeWidth: 6
    property real size: 72
    // Visual gap between progress end and remainder (empty) for determinate mode
    property real gapAngleDeg: 6
    // Permanent ring break (at 12 o'clock) so head and tail don't touch
    property real ringGapDeg: 4
    // Tiny constant end tip length (in degrees) for end-of-bar marker
    property real endTipDeg: 6
    property bool showEndTip: true

    // Optional convenience center label
    property string centerText: ""
    property alias content: centerContent.data

    default property alias children: centerContent.data

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
            var clamped = Math.max(0, Math.min(1, root.progress))
            var total = Math.PI * 2
            var ringGap = Math.max(0, root.ringGapDeg) * Math.PI / 180
            var gap = Math.max(0, root.gapAngleDeg) * Math.PI / 180
            var tip = Math.max(0, root.endTipDeg) * Math.PI / 180

            // Define an open ring arc (avoid head-tail join)
            var cap = Math.max(0.0001, (root.strokeWidth / 2) / Math.max(1, r))
            var startRing = -Math.PI/2 + ringGap/2 + cap
            var endRing = -Math.PI/2 + total - ringGap/2 - cap
            var usable = Math.max(0, endRing - startRing)

            // Progress arc within the open ring, leaving a small split gap
            var progEnd = startRing + clamped * usable
            var progStart = startRing
            var progEndWithGap = Math.max(progStart, progEnd - gap/2 - cap)
            var trackStart = Math.min(endRing, progEnd + gap/2 + cap)

            ctx.lineWidth = root.strokeWidth
            ctx.lineCap = 'round'

            // progress
            ctx.strokeStyle = root.progressColor
            ctx.beginPath(); ctx.arc(cx, cy, r, progStart, progEndWithGap, false); ctx.stroke()

            // track (remainder)
            ctx.strokeStyle = root.trackColor
            ctx.beginPath(); ctx.arc(cx, cy, r, trackStart, endRing, false); ctx.stroke()

            // fixed end-of-bar tip at the absolute end of the open ring
            if (root.showEndTip) {
                ctx.strokeStyle = root.progressColor
                ctx.beginPath(); ctx.arc(cx, cy, r, endRing - tip, endRing, false); ctx.stroke()
            }
        }
    }

    Item {
        id: center
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        // Convenience text centered
        Text { visible: root.centerText.length > 0; anchors.centerIn: parent; text: root.centerText; color: Components.ColorPalette.onSurface; font.pixelSize: 14 }
        Item { id: centerContent; anchors.centerIn: parent }
    }
}


