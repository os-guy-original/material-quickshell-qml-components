import QtQuick 2.15
import "../../colors.js" as Palette

Item {
  id: root
  property real value: 0.0            // 0..1
  property real step: 0.0             // 0 for continuous
  property color trackColor: Palette.isDarkMode() ? Palette.palette().surfaceVariant : Qt.darker(Palette.palette().background, 1.08)
  property color fillColor: Palette.palette().primary
  property color thumbColor: Palette.palette().onPrimary
  property real thickness: 4
  property real thumbSize: 16
  property bool enabled: true

  implicitWidth: 260
  implicitHeight: Math.max(thickness, thumbSize)

  // normalized value clamped
  function setValue(v) {
    var c = Math.max(0, Math.min(1, v))
    if (step > 0) {
      var steps = Math.round(c / step)
      c = Math.max(0, Math.min(1, steps * step))
    }
    value = c
  }

  Rectangle {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right
    height: thickness
    radius: height / 2
    color: trackColor
  }

  Rectangle {
    id: fill
    anchors.verticalCenter: track.verticalCenter
    anchors.left: track.left
    height: thickness
    radius: height / 2
    width: Math.max(0, Math.min(1, root.value)) * track.width
    color: fillColor
    Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
  }

  Rectangle {
    id: thumb
    width: thumbSize
    height: thumbSize
    radius: width / 2
    color: enabled ? thumbColor : Qt.rgba(0.82,0.82,0.82,1)
    border.width: enabled ? 0 : 1
    border.color: Palette.palette().outline
    anchors.verticalCenter: track.verticalCenter
    x: Math.max(0, Math.min(1, root.value)) * (track.width - width) + track.x
    Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    preventStealing: true
    cursorShape: Qt.PointingHandCursor
    onPressed: (e) => {
      var rel = (e.x - track.x) / Math.max(1, track.width)
      root.setValue(rel)
    }
    onPositionChanged: (e) => {
      if (!pressed) return
      var rel = (e.x - track.x) / Math.max(1, track.width)
      root.setValue(rel)
    }
    onWheel: (wheel) => {
      if (step <= 0) return
      var dir = wheel.angleDelta.y > 0 ? 1 : -1
      root.setValue(root.value + dir * step)
    }
  }
}
