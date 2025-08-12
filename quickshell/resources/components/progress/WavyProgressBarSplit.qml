import QtQuick 2.15
import "../../colors.js" as Palette
import "../../metrics.js" as Metrics

Item {
  id: root
  property real progress: 0.0 // 0..1
  property color filledColor: Palette.palette().primary
  property color emptyColor: Palette.palette().surfaceVariant
  property real amplitude: 8
  property real wavelength: 32
  property real strokeWidth: 4
  property real phase: 0
  // small gap between wavy filled and flat empty part
  property real gap: 8
  // round caps on both ends
  property bool roundCaps: true
  // primary color end tip length (constant across bars)
  property real endTipLength: Metrics.endTipLength

  implicitWidth: 240
  // Height depends only on wave amplitude and stroke
  implicitHeight: Math.max(2 * amplitude + strokeWidth, strokeWidth)
  clip: false

  function yOf(x, amp) {
    var mid = height / 2
    if (wavelength <= 0 || amp <= 0) return mid
    return mid + amp * Math.sin(phase + (x / wavelength) * Math.PI * 2)
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
      var r = root.strokeWidth / 2

      var clamped = Math.max(0, Math.min(1, root.progress))
      var endX = w - r
      var startX = r
      var splitX = startX + clamped * (endX - startX)

      var safePad = root.strokeWidth
      var amp = Math.max(0, Math.min(root.amplitude, (h - safePad) / 2))

      // Filled wavy part
      ctx.lineWidth = root.strokeWidth
      // Round caps for ends
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.strokeStyle = root.filledColor
      ctx.beginPath()
      var wavyEnd = Math.max(startX, Math.min(endX, splitX - root.gap/2))
      ctx.moveTo(startX, yOf(startX, amp))
      for (var x = startX + 1; x <= wavyEnd; x += 1) {
        ctx.lineTo(x, yOf(x, amp))
      }
      ctx.stroke()

      // Flat empty part (track) starting after a small gap, with round caps
      ctx.strokeStyle = root.emptyColor
      ctx.beginPath()
      var flatStart = Math.max(startX, Math.min(endX, splitX + root.gap/2))
      ctx.lineCap = 'round'
      ctx.moveTo(flatStart, mid)
      ctx.lineTo(endX, mid)
      ctx.stroke()

      // Primary-colored short tip integrated into end of bar (constant length)
      var tipLen = Math.max(2, root.endTipLength)
      var tipStart = Math.max(flatStart, endX - tipLen)
      ctx.strokeStyle = root.filledColor
      ctx.beginPath()
      ctx.moveTo(tipStart, mid)
      ctx.lineTo(endX, mid)
      ctx.stroke()
    }

    Behavior on width { NumberAnimation { duration: 120 } }
    Behavior on height { NumberAnimation { duration: 120 } }
  }

  onProgressChanged: canvas.requestPaint()
  onAmplitudeChanged: canvas.requestPaint()
  onWavelengthChanged: canvas.requestPaint()
  onStrokeWidthChanged: canvas.requestPaint()
  onPhaseChanged: canvas.requestPaint()
  onFilledColorChanged: canvas.requestPaint()
  onEmptyColorChanged: canvas.requestPaint()
  onGapChanged: canvas.requestPaint()
  onEndTipLengthChanged: canvas.requestPaint()
  Component.onCompleted: canvas.requestPaint()
}


