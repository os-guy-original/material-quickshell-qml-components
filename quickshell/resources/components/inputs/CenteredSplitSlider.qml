import QtQuick 2.15
import "../../colors.js" as Palette

// Centered split slider - divider moves, fill extends from center to divider
Item {
  id: root
  // 0..1 (0.5 = center)
  property real value: 0.5
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

  function setValue(v) {
    value = Math.max(0, Math.min(1, v))
  }

  readonly property real _clamped: Math.max(0, Math.min(1, value))
  readonly property real _centerX: root.width / 2
  readonly property real _valueX: _clamped * root.width
  readonly property real _dw: dividerWidth / 2
  readonly property real _gap: gapOnEachSide
  readonly property real _halfSpan: _dw + _gap

  // When value < 0.5: left of divider is track, between divider and center is fill, right of center is track
  // When value > 0.5: left of center is track, between center and divider is fill, right of divider is track
  // When value = 0.5: all track

  // Left track segment (always track color, from start to before the fill/divider area)
  Item {
    id: leftTrack
    x: 0
    anchors.verticalCenter: parent.verticalCenter
    width: _clamped < 0.5 ? Math.max(0, _valueX - _halfSpan) : Math.max(0, _centerX)
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

  // Fill segment (between center and divider)
  Item {
    id: fillSegment
    visible: Math.abs(_clamped - 0.5) > 0.01
    anchors.verticalCenter: parent.verticalCenter
    height: thickness
    
    // When left of center: fill is from (valueX + halfSpan) to centerX
    // When right of center: fill is from centerX to (valueX - halfSpan)
    x: _clamped < 0.5 ? (_valueX + _halfSpan) : _centerX
    width: _clamped < 0.5 ? Math.max(0, _centerX - _valueX - _halfSpan) : Math.max(0, _valueX - _halfSpan - _centerX)
    
    Rectangle {
      anchors.fill: parent
      radius: innerCornerRadius
      color: fillColor
      antialiasing: true
    }
  }

  // Right track segment (always track color, from after the fill/divider area to end)
  Item {
    id: rightTrack
    anchors.verticalCenter: parent.verticalCenter
    height: thickness
    x: _clamped > 0.5 ? (_valueX + _halfSpan) : _centerX
    width: _clamped > 0.5 ? Math.max(0, root.width - _valueX - _halfSpan) : Math.max(0, root.width - _centerX)
    
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

  // Moving divider (follows value)
  Rectangle {
    id: dividerLine
    width: dividerWidth
    height: thickness * 2.5
    radius: width / 2
    color: dividerColor
    anchors.verticalCenter: parent.verticalCenter
    x: _valueX - width / 2
    z: 10
  }

  // End dots - visible on the track (unfilled) side
  // Left dot: visible when value >= 0.5 (left side is track)
  Rectangle {
    width: endDotSize
    height: endDotSize
    radius: width / 2
    color: endDotColor
    anchors.verticalCenter: parent.verticalCenter
    x: Math.round(endDotSize / 2)
    visible: _clamped >= 0.5
    opacity: 0.9
    z: 11
  }
  // Right dot: visible when value <= 0.5 (right side is track)
  Rectangle {
    width: endDotSize
    height: endDotSize
    radius: width / 2
    color: endDotColor
    anchors.verticalCenter: parent.verticalCenter
    x: Math.round(root.width - endDotSize - endDotSize / 2)
    visible: _clamped <= 0.5
    opacity: 0.9
    z: 11
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    preventStealing: true
    cursorShape: Qt.PointingHandCursor
    onPressed: function(e) {
      root.setValue(e.x / root.width)
    }
    onPositionChanged: function(e) {
      if (!pressed) return
      root.setValue(e.x / root.width)
    }
  }
}
