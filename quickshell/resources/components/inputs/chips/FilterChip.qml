import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "../../../colors.js" as Palette

Item {
  id: root
  property alias text: label.text
  property bool checked: false
  property bool enabled: true
  // Minimal size and paddings
  readonly property int _padX: 10
  readonly property int _padY: 6
  // Sharper corners
  readonly property int _radius: 4
  readonly property int _gap: 8
  readonly property real _hairline: 1 / Screen.devicePixelRatio

  signal toggled(bool checked)

  implicitWidth: label.implicitWidth + _padX*2 + (checked ? 18 + _gap : 0)
  implicitHeight: Math.max(28, label.implicitHeight + _padY*2)
  width: implicitWidth
  height: implicitHeight

  Rectangle {
    id: bg
    anchors.fill: parent
    radius: _radius
    color: checked ? Palette.palette().surfaceVariant : Palette.palette().surface
    // Selected has no border; unselected has thin hairline border
    border.width: checked ? 0 : _hairline
    border.color: Palette.palette().outline
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
  }

  // Tick icon when selected (vector, centered, not font-skewed)
  Canvas {
    id: tick
    visible: checked
    width: 18; height: 18
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: _padX
    onPaint: {
      var ctx = getContext('2d')
      ctx.reset()
      ctx.strokeStyle = label.color
      ctx.lineWidth = 2
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      // Symmetric check
      var px = 3.5, py = height - 5.5
      var mx = 7.5, my = height - 3.5
      var ex = width - 3.5, ey = 4.5
      ctx.beginPath()
      ctx.moveTo(px, py)
      ctx.lineTo(mx, my)
      ctx.lineTo(ex, ey)
      ctx.stroke()
    }
  }

  Text {
    id: label
    anchors.verticalCenter: parent.verticalCenter
    color: enabled ? Palette.palette().onSurface : Qt.rgba(0.75,0.75,0.75,1)
    font.pixelSize: 14
    text: ""
    anchors.left: parent.left
    anchors.leftMargin: checked ? (_padX + 18 + _gap) : _padX
    anchors.right: parent.right
    anchors.rightMargin: _padX
    elide: Text.ElideRight
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.enabled
    onClicked: { root.checked = !root.checked; root.toggled(root.checked) }
  }
}


