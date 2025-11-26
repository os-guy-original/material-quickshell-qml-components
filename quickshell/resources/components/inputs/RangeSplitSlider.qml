import QtQuick 2.15
import "../../colors.js" as Palette

// Range split slider - two handles for min/max selection
Item {
  id: root
  property real minValue: 0.25
  property real maxValue: 0.75
  property real thickness: 16
  property real cornerRadius: thickness / 2
  property color trackColor: Palette.isDarkMode() ? Palette.palette().surfaceVariant : Qt.darker(Palette.palette().background, 1.15)
  property color fillColor: Palette.palette().primary
  property color dividerColor: Palette.palette().primary
  property color endDotColor: "white"
  property real dividerWidth: 4
  readonly property real gapOnEachSide: dividerWidth * 1.5
  property real endDotSize: 5
  property real innerCornerRadius: Math.max(1, Math.min(cornerRadius, thickness * 0.25))
  property bool enabled: true

  implicitWidth: 260
  implicitHeight: thickness

  function setMinValue(v) {
    var clamped = Math.max(0, Math.min(maxValue - 0.05, v))
    minValue = clamped
  }
  function setMaxValue(v) {
    var clamped = Math.max(minValue + 0.05, Math.min(1, v))
    maxValue = clamped
  }

  readonly property real _minX: minValue * root.width
  readonly property real _maxX: maxValue * root.width
  readonly property real _dw: dividerWidth / 2
  readonly property real _halfSpan: _dw + gapOnEachSide

  // Left track (before min)
  Item {
    id: leftTrack
    x: 0
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, _minX - _halfSpan)
    height: thickness
    Rectangle {
      x: cornerRadius
      width: Math.max(0, parent.width - cornerRadius)
      height: thickness
      radius: innerCornerRadius
      color: trackColor
      antialiasing: true
      visible: width > 0
    }
    Rectangle {
      width: Math.min(thickness, parent.width)
      height: thickness
      radius: cornerRadius
      color: trackColor
      antialiasing: true
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // Center track (between min and max - filled)
  Item {
    id: centerTrack
    x: _minX + _halfSpan
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, (_maxX - _halfSpan) - (_minX + _halfSpan))
    height: thickness
    Rectangle {
      anchors.fill: parent
      radius: innerCornerRadius
      color: fillColor
      antialiasing: true
      visible: width > 0
    }
  }

  // Right track (after max)
  Item {
    id: rightTrack
    x: _maxX + _halfSpan
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, root.width - _maxX - _halfSpan)
    height: thickness
    Rectangle {
      x: 0
      width: Math.max(0, parent.width - cornerRadius)
      height: thickness
      radius: innerCornerRadius
      color: trackColor
      antialiasing: true
      visible: width > 0
    }
    Rectangle {
      width: Math.min(thickness, parent.width)
      height: thickness
      radius: cornerRadius
      color: trackColor
      antialiasing: true
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // Min divider
  Rectangle {
    id: minDivider
    width: dividerWidth
    height: thickness * 2.5
    radius: width / 2
    color: dividerColor
    anchors.verticalCenter: parent.verticalCenter
    x: _minX - width / 2
    z: 10
  }

  // Max divider
  Rectangle {
    id: maxDivider
    width: dividerWidth
    height: thickness * 2.5
    radius: width / 2
    color: dividerColor
    anchors.verticalCenter: parent.verticalCenter
    x: _maxX - width / 2
    z: 10
  }

  // End dots
  Rectangle {
    width: endDotSize
    height: endDotSize
    radius: width / 2
    color: endDotColor
    anchors.verticalCenter: parent.verticalCenter
    x: Math.round(endDotSize / 2)
    visible: minValue > 0.01
    opacity: 0.9
    z: 11
  }
  Rectangle {
    width: endDotSize
    height: endDotSize
    radius: width / 2
    color: endDotColor
    anchors.verticalCenter: parent.verticalCenter
    x: Math.round(root.width - endDotSize - endDotSize / 2)
    visible: maxValue < 0.99
    opacity: 0.9
    z: 11
  }

  property string _dragging: "" // "min", "max", or ""

  MouseArea {
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    preventStealing: true
    cursorShape: Qt.PointingHandCursor
    onPressed: function(e) {
      var rel = e.x / Math.max(1, root.width)
      var distMin = Math.abs(rel - minValue)
      var distMax = Math.abs(rel - maxValue)
      if (distMin < distMax) {
        root._dragging = "min"
        root.setMinValue(rel)
      } else {
        root._dragging = "max"
        root.setMaxValue(rel)
      }
    }
    onPositionChanged: function(e) {
      if (!pressed) return
      var rel = e.x / Math.max(1, root.width)
      if (root._dragging === "min") root.setMinValue(rel)
      else if (root._dragging === "max") root.setMaxValue(rel)
    }
    onReleased: root._dragging = ""
  }
}
