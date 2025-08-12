import QtQuick 2.15
import "../../colors.js" as Palette

Item {
  id: root
  property real value: 0.0            // 0..1
  property real step: 0.0             // snap
  property color trackColor: Palette.palette().surfaceVariant
  property color progressColor: Palette.palette().primary
  property real strokeWidth: 6
  property real size: 72
  property bool enabled: true

  implicitWidth: size
  implicitHeight: size

  function setValue(v) {
    var c = Math.max(0, Math.min(1, v))
    if (step > 0) {
      var steps = Math.round(c / step)
      c = Math.max(0, Math.min(1, steps * step))
    }
    value = c
  }

  Canvas {
    id: canvas
    anchors.fill: parent
    onPaint: {
      var ctx = getContext('2d')
      ctx.reset()
      var cx = width / 2
      var cy = height / 2
      var r = Math.min(width, height) / 2 - root.strokeWidth
      var end = Math.max(0, Math.min(1, root.value)) * Math.PI * 2
      ctx.lineWidth = root.strokeWidth
      ctx.lineCap = 'round'
      // track
      ctx.strokeStyle = root.trackColor
      ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2, false); ctx.stroke()
      // progress
      ctx.strokeStyle = root.progressColor
      ctx.beginPath(); ctx.arc(cx, cy, r, -Math.PI/2, -Math.PI/2 + end, false); ctx.stroke()
    }
  }

  // Thumb
  Rectangle {
    id: thumb
    width: strokeWidth + 6
    height: width
    radius: width / 2
    color: enabled ? Palette.palette().onPrimary : Qt.rgba(0.82,0.82,0.82,1)
    border.width: enabled ? 0 : 1
    border.color: Palette.palette().outline
    // Positioned purely by x/y; do not anchor to center, to avoid overriding coordinates
    // position around the circle
    property real angle: -Math.PI/2 + Math.max(0, Math.min(1, root.value)) * Math.PI * 2
    x: parent.width/2 + (Math.min(parent.width, parent.height)/2 - strokeWidth) * Math.cos(angle) - width/2
    y: parent.height/2 + (Math.min(parent.width, parent.height)/2 - strokeWidth) * Math.sin(angle) - height/2
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    preventStealing: true
    onPressed: (e) => {
      var dx = e.x - width/2
      var dy = e.y - height/2
      var ang = Math.atan2(dy, dx)
      var norm = (ang + Math.PI/2) / (Math.PI * 2)
      if (norm < 0) norm += 1
      root.setValue(norm)
    }
    onPositionChanged: (e) => {
      if (!pressed) return
      var dx = e.x - width/2
      var dy = e.y - height/2
      var ang = Math.atan2(dy, dx)
      var norm = (ang + Math.PI/2) / (Math.PI * 2)
      if (norm < 0) norm += 1
      root.setValue(norm)
    }
    onWheel: (wheel) => {
      if (step <= 0) return
      var dir = wheel.angleDelta.y > 0 ? 1 : -1
      root.setValue(root.value + dir * step)
    }
  }

  onValueChanged: canvas.requestPaint()
  onTrackColorChanged: canvas.requestPaint()
  onProgressColorChanged: canvas.requestPaint()
  onStrokeWidthChanged: canvas.requestPaint()
}
