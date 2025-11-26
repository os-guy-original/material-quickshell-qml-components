import QtQuick 2.15
import ".." as Components
import "../../metrics.js" as Metrics

Item {
    id: root
    property real progress: 0.0
    property color trackColor: Components.ColorPalette.isDarkMode ? Components.ColorPalette.surfaceVariant : Qt.darker(Components.ColorPalette.background, 1.15)
    property color progressColor: Components.ColorPalette.primary
    property real thickness: 4
    property bool showDivider: false
    property real dividerThickness: 2

    implicitWidth: 240
    implicitHeight: thickness

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var midY = height / 2
            ctx.lineCap = 'round'
            ctx.lineWidth = thickness
            // track
            ctx.strokeStyle = trackColor
            ctx.beginPath()
            ctx.moveTo(0, midY)
            ctx.lineTo(width, midY)
            ctx.stroke()
            // progress
            ctx.strokeStyle = progressColor
            ctx.beginPath()
            var clamped = Math.max(0, Math.min(1, root.progress))
            var endX = clamped * width
            endX = Math.max(endX, ctx.lineWidth / 2)
            ctx.moveTo(0, midY)
            ctx.lineTo(endX, midY)
            ctx.stroke()
            // tiny tip at end for consistency
            var tipLen = Math.max(2, Metrics.endTipLength)
            ctx.beginPath()
            ctx.moveTo(Math.max(0, endX - tipLen), midY)
            ctx.lineTo(endX, midY)
            ctx.stroke()
            // optional divider in the middle
            if (root.showDivider) {
                ctx.lineWidth = dividerThickness
                ctx.strokeStyle = Components.ColorPalette.onSurfaceVariant
                ctx.beginPath()
                ctx.moveTo(width/2, 0)
                ctx.lineTo(width/2, height)
                ctx.stroke()
            }
        }
    }

    onProgressChanged: canvas.requestPaint()
    onThicknessChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onProgressColorChanged: canvas.requestPaint()
    onShowDividerChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()
}


