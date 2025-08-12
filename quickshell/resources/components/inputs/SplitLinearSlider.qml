import QtQuick 2.15
import "../../colors.js" as Palette

Item {
  id: root
  // 0..1
  property real value: 0.0
  // visual
  // A bit thicker by default
  property real thickness: 16
  property real cornerRadius: thickness / 2
  property color trackColor: Palette.palette().surfaceVariant
  property color fillColor: Palette.palette().primary
  property color dividerColor: Palette.palette().primary
  property color endDotColor: "white"
  property real dividerWidth: 4
  // Gap on each side of the divider: 3.1x divider thickness
  readonly property real gapOnEachSide: dividerWidth * 3.1
  readonly property real totalGap: gapOnEachSide * 2 + dividerWidth
  // A single end dot on the empty side (right end)
  property real endDotSize: 5
  // Slightly softer inner corners where bars meet the gap (outer ends remain fully round)
  property real innerCornerRadius: Math.max(1, Math.min(cornerRadius, thickness * 0.25))
  property bool enabled: true

  implicitWidth: 260
  implicitHeight: thickness

  function setValue(v) {
    var c = Math.max(0, Math.min(1, v))
    value = c
  }

  // Track background
  // Derived geometry
  readonly property real _clamped: Math.max(0, Math.min(1, value))
  readonly property real _centerX: _clamped * root.width
  // Keep a real gap around divider; shrink near edges so fill can reach bar ends
  readonly property real _dw: dividerWidth / 2
  readonly property real _halfSpanBase: _dw + gapOnEachSide
  readonly property real _availLeft: _centerX
  readonly property real _availRight: root.width - _centerX
  readonly property real _s: Math.min(1,
                                      Math.max(0, _availLeft / Math.max(1, _halfSpanBase)),
                                      Math.max(0, _availRight / Math.max(1, _halfSpanBase)))
  readonly property real _leftEdge: Math.max(0, _centerX - _s * _halfSpanBase)
  readonly property real _rightEdge: Math.min(root.width, _centerX + _s * _halfSpanBase)

  // Left (filled) segment (body trimmed away from outer end + outer round cap)
  Item {
    id: leftGroup
    x: 0
    anchors.verticalCenter: parent.verticalCenter
    width: _leftEdge
    height: thickness
    // main body starts after the outer round end, inner side slightly rounded
    Rectangle {
      x: cornerRadius
      width: Math.max(0, parent.width - cornerRadius)
      height: thickness
      radius: innerCornerRadius
      color: fillColor
      antialiasing: true
      visible: width > 0
    }
    // outer cap to keep leftmost end fully round
    Rectangle {
      width: Math.min(thickness, parent.width)
      height: thickness
      radius: cornerRadius
      color: fillColor
      antialiasing: true
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
    }
    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
  }

  // Right (empty) segment (body trimmed away from outer end + outer round cap)
  Item {
    id: rightGroup
    x: _rightEdge
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, root.width - _rightEdge)
    height: thickness
    // main body ends before the outer round end, inner side slightly rounded
    Rectangle {
      x: 0
      width: Math.max(0, parent.width - cornerRadius)
      height: thickness
      radius: innerCornerRadius
      color: trackColor
      antialiasing: true
      visible: width > 0
    }
    // outer cap to keep rightmost end fully round
    Rectangle {
      width: Math.min(thickness, parent.width)
      height: thickness
      radius: cornerRadius
      color: trackColor
      antialiasing: true
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
    }
    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
  }

  // Divider line above the track and taller than the bar
  Rectangle {
    id: dividerLine
    width: dividerWidth
    height: thickness * 2.5
    radius: width / 2
    color: dividerColor
    anchors.verticalCenter: parent.verticalCenter
    x: _centerX - width / 2
    z: 10
    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
  }

  // Single end dot on the empty side's outer end; only visible when there is empty region
  Rectangle {
    id: rightDot
    width: endDotSize
    height: endDotSize
    radius: width/2
    color: endDotColor
    anchors.verticalCenter: parent.verticalCenter
    x: Math.round(root.width - endDotSize - Math.max(2, endDotSize/2))
    visible: (_rightEdge < root.width - 0.0001)
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
      var rel = (e.x) / Math.max(1, root.width)
      root.setValue(rel)
    }
    onPositionChanged: function(e) {
      if (!pressed) return
      var rel = (e.x) / Math.max(1, root.width)
      root.setValue(rel)
    }
    onWheel: function(wheel) {
      // Optional: implement step if needed later
    }
  }
}


