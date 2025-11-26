import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import "../../colors.js" as Palette
import "."
import "../feedback" as Feedback
import "../actions" as Actions

Item {
  id: root
  property int hour: (new Date()).getHours()
  property int minute: (new Date()).getMinutes()
  property bool is24h: false
  property bool selectingHour: true
  property int minuteStep: 1
  property bool showHeader: true
  property bool showButtons: true
  property bool transparentBackground: false
  
  signal timeChanged(int hour, int minute)
  signal accepted()
  signal cancelled()

  width: 328
  height: (showHeader ? 440 : 400) - (showButtons ? 0 : 48)

  function pad2(n) { return (n < 10 ? "0" + n : "" + n) }
  function displayHour() {
    if (is24h) return pad2(hour)
    var h = hour % 12
    if (h === 0) h = 12
    return pad2(h)
  }
  function setHourFromDisplay(h) {
    if (is24h) {
      hour = Math.max(0, Math.min(23, h))
    } else {
      var isPM = hour >= 12
      var base = (h % 12) + (isPM ? 12 : 0)
      hour = Math.max(0, Math.min(23, base))
    }
    timeChanged(hour, minute)
  }
  function setMinute(m) {
    var mm = Math.round(m)
    minute = Math.max(0, Math.min(59, mm))
    timeChanged(hour, minute)
  }

  function updateHandForCurrent() {
    var deg = 0
    if (selectingHour) {
      var disp = hour % 12
      if (disp === 0) disp = 12
      deg = disp * 30 - 90
    } else {
      deg = minute * 6 - 90
    }
    var targetRad = deg * Math.PI / 180
    if (hand && hand.animateTo) {
      hand.animateTo(targetRad)
    } else if (dialArea && dialArea.setHandAngle) {
      dialArea.setHandAngle(targetRad, true)
    } else {
      hand.angleRad = targetRad
    }
  }

  // Main container
  Rectangle {
    id: container
    anchors.fill: parent
    color: transparentBackground ? "transparent" : Palette.palette().surfaceContainerHighest
    radius: transparentBackground ? 0 : 16

    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - 24
      spacing: 8

      // Header
      Text {
        visible: showHeader
        height: showHeader ? implicitHeight : 0
        text: "Select time"
        color: Palette.palette().onSurfaceVariant
        font.pixelSize: 12
      }

      // Time display row
      Row {
        id: fields
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
          id: hourTile
          width: 80; height: 56
          
          Item {
            id: hourTileBg
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            layer.effect: OpacityMask {
              maskSource: Item {
                width: hourTileBg.width
                height: hourTileBg.height
                Rectangle { anchors.fill: parent; radius: 8 }
              }
            }
            
            Rectangle {
              anchors.fill: parent
              radius: 8
              color: selectingHour ? Palette.palette().primaryContainer : Palette.palette().surfaceVariant
              Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }
            
            Feedback.RippleEffect {
              id: hourRipple
              rippleColor: selectingHour ? Palette.palette().onPrimaryContainer : Palette.palette().onSurface
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: root.displayHour()
            color: selectingHour ? Palette.palette().onPrimaryContainer : Palette.palette().onSurface
            font.pixelSize: 32; font.bold: true
            Behavior on color { ColorAnimation { duration: 140 } }
          }
          
          MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) {
              hourRipple.trigger(mouse.x, mouse.y)
              selectingHour = true
            }
          }
        }

        Text { text: ":"; color: Palette.palette().onSurfaceVariant; anchors.verticalCenter: hourTile.verticalCenter; font.pixelSize: 32; font.bold: true }

        Item {
          id: minuteTile
          width: 80; height: 56
          
          Item {
            id: minuteTileBg
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            layer.effect: OpacityMask {
              maskSource: Item {
                width: minuteTileBg.width
                height: minuteTileBg.height
                Rectangle { anchors.fill: parent; radius: 8 }
              }
            }
            
            Rectangle {
              anchors.fill: parent
              radius: 8
              color: !selectingHour ? Palette.palette().primaryContainer : Palette.palette().surfaceVariant
              Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }
            
            Feedback.RippleEffect {
              id: minuteRipple
              rippleColor: !selectingHour ? Palette.palette().onPrimaryContainer : Palette.palette().onSurface
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: pad2(root.minute)
            color: !selectingHour ? Palette.palette().onPrimaryContainer : Palette.palette().onSurface
            font.pixelSize: 32; font.bold: true
            Behavior on color { ColorAnimation { duration: 140 } }
          }
          
          MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) {
              minuteRipple.trigger(mouse.x, mouse.y)
              selectingHour = false
            }
          }
        }

        // AM/PM segment
        Column {
          visible: !is24h
          anchors.verticalCenter: hourTile.verticalCenter
          spacing: 4

          Item {
            id: amButton
            width: 40; height: 40
            
            Item {
              id: amButtonBg
              anchors.fill: parent
              layer.enabled: true
              layer.smooth: true
              layer.effect: OpacityMask {
                maskSource: Item {
                  width: amButtonBg.width
                  height: amButtonBg.height
                  Rectangle { anchors.fill: parent; radius: 20 }
                }
              }
              
              Rectangle {
                anchors.fill: parent
                radius: 20
                color: root.hour < 12 ? Palette.palette().primaryContainer : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }
              }
              
              Feedback.RippleEffect {
                id: amRipple
                rippleColor: root.hour < 12 ? Palette.palette().onPrimaryContainer : Palette.palette().onSurfaceVariant
              }
            }
            
            Text {
              anchors.centerIn: parent
              text: "AM"
              font.pixelSize: 12
              font.bold: true
              color: root.hour < 12 ? Palette.palette().onPrimaryContainer : Palette.palette().onSurfaceVariant
              Behavior on color { ColorAnimation { duration: 140 } }
            }
            
            MouseArea {
              anchors.fill: parent
              onClicked: function(mouse) {
                amRipple.trigger(mouse.x, mouse.y)
                if (root.hour >= 12) {
                  root.hour -= 12
                  root.timeChanged(root.hour, root.minute)
                }
              }
            }
          }

          Item {
            id: pmButton
            width: 40; height: 40
            
            Item {
              id: pmButtonBg
              anchors.fill: parent
              layer.enabled: true
              layer.smooth: true
              layer.effect: OpacityMask {
                maskSource: Item {
                  width: pmButtonBg.width
                  height: pmButtonBg.height
                  Rectangle { anchors.fill: parent; radius: 20 }
                }
              }
              
              Rectangle {
                anchors.fill: parent
                radius: 20
                color: root.hour >= 12 ? Palette.palette().primaryContainer : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }
              }
              
              Feedback.RippleEffect {
                id: pmRipple
                rippleColor: root.hour >= 12 ? Palette.palette().onPrimaryContainer : Palette.palette().onSurfaceVariant
              }
            }
            
            Text {
              anchors.centerIn: parent
              text: "PM"
              font.pixelSize: 12
              font.bold: true
              color: root.hour >= 12 ? Palette.palette().onPrimaryContainer : Palette.palette().onSurfaceVariant
              Behavior on color { ColorAnimation { duration: 140 } }
            }
            
            MouseArea {
              anchors.fill: parent
              onClicked: function(mouse) {
                pmRipple.trigger(mouse.x, mouse.y)
                if (root.hour < 12) {
                  root.hour += 12
                  root.timeChanged(root.hour, root.minute)
                }
              }
            }
          }
        }
      }

      // Clock dial
      Item {
        id: dialContainer
        width: 256
        height: 256
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
          id: dialBg
          anchors.fill: parent
          radius: width / 2
          color: Palette.palette().surfaceVariant
        }

        // Clock hand
        Item {
          id: hand
          anchors.centerIn: parent
          width: parent.width
          height: parent.height
          property real angleRad: -Math.PI / 2
          property real targetAngleRad: -Math.PI / 2
          property bool animEnabled: true
          
          // Calculate shortest angular distance (handles wrap-around)
          function angularDistance(from, to) {
            var diff = to - from
            // Normalize to [-PI, PI]
            while (diff > Math.PI) diff -= 2 * Math.PI
            while (diff < -Math.PI) diff += 2 * Math.PI
            return Math.abs(diff)
          }
          
          // Duration based on distance: ~50ms per 30 degrees, min 100ms, max 400ms
          function calculateDuration(from, to) {
            var dist = angularDistance(from, to)
            var degDist = dist * 180 / Math.PI
            var duration = Math.max(100, Math.min(400, degDist * 50 / 30))
            return duration
          }
          
          function animateTo(newAngle) {
            if (!animEnabled) {
              angleRad = newAngle
              return
            }
            handAnimation.stop()
            handAnimation.from = angleRad
            // Calculate shortest path
            var diff = newAngle - angleRad
            while (diff > Math.PI) diff -= 2 * Math.PI
            while (diff < -Math.PI) diff += 2 * Math.PI
            handAnimation.to = angleRad + diff
            handAnimation.duration = calculateDuration(angleRad, newAngle)
            handAnimation.start()
          }
          
          NumberAnimation {
            id: handAnimation
            target: hand
            property: "angleRad"
            duration: 200
            easing.type: Easing.OutCubic
          }

          // Center dot
          Rectangle {
            anchors.centerIn: parent
            width: 8; height: 8; radius: 4
            color: Palette.palette().primary
          }

          // Hand line
          Rectangle {
            id: handLine
            width: 2
            height: dialContainer.width / 2 - 40
            color: Palette.palette().primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            transformOrigin: Item.Bottom
            rotation: hand.angleRad * 180 / Math.PI + 90
          }

          // Knob at end of hand
          Rectangle {
            id: knob
            width: 40; height: 40; radius: 20
            color: Palette.palette().primary
            x: parent.width / 2 + Math.cos(hand.angleRad) * (dialContainer.width / 2 - 40) - 20
            y: parent.height / 2 + Math.sin(hand.angleRad) * (dialContainer.width / 2 - 40) - 20
          }
        }

        // Hour numbers - base layer (normal color)
        Item {
          id: hourNumbersBase
          anchors.fill: parent
          visible: selectingHour
          opacity: selectingHour ? 1 : 0
          scale: selectingHour ? 1 : 0.9
          Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
          Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

          Repeater {
            model: 12
            delegate: Item {
              property int displayNum: index === 0 ? 12 : index
              property real angle: (index * 30 - 90) * Math.PI / 180
              property real radius: dialContainer.width / 2 - 40
              x: dialContainer.width / 2 + Math.cos(angle) * radius - 20
              y: dialContainer.height / 2 + Math.sin(angle) * radius - 20
              width: 40; height: 40

              Text {
                anchors.centerIn: parent
                text: parent.displayNum
                font.pixelSize: 16
                color: Palette.palette().onSurface
              }

              MouseArea {
                anchors.fill: parent
                onClicked: root.setHourFromDisplay(parent.displayNum)
              }
            }
          }
        }

        // Hour numbers - highlighted layer (masked by knob)
        Item {
          id: hourNumbersHighlight
          anchors.fill: parent
          visible: false
          layer.enabled: true

          Repeater {
            model: 12
            delegate: Item {
              property int displayNum: index === 0 ? 12 : index
              property real angle: (index * 30 - 90) * Math.PI / 180
              property real radius: dialContainer.width / 2 - 40
              x: dialContainer.width / 2 + Math.cos(angle) * radius - 20
              y: dialContainer.height / 2 + Math.sin(angle) * radius - 20
              width: 40; height: 40

              Text {
                anchors.centerIn: parent
                text: parent.displayNum
                font.pixelSize: 16
                color: Palette.palette().onPrimary
              }
            }
          }
        }

        // Knob mask source for hours
        Item {
          id: hourKnobMask
          anchors.fill: parent
          visible: false

          Rectangle {
            width: 40; height: 40; radius: 20
            color: "white"
            x: dialContainer.width / 2 + Math.cos(hand.angleRad) * (dialContainer.width / 2 - 40) - 20
            y: dialContainer.height / 2 + Math.sin(hand.angleRad) * (dialContainer.width / 2 - 40) - 20
          }
        }

        // OpacityMask for hour highlight
        OpacityMask {
          anchors.fill: hourNumbersHighlight
          source: hourNumbersHighlight
          maskSource: hourKnobMask
          visible: selectingHour
          opacity: selectingHour ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // Minute numbers - base layer (normal color)
        Item {
          id: minuteNumbersBase
          anchors.fill: parent
          visible: !selectingHour
          opacity: !selectingHour ? 1 : 0
          scale: !selectingHour ? 1 : 0.9
          Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
          Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

          Repeater {
            model: 12
            delegate: Item {
              property int displayNum: index * 5
              property real angle: (index * 30 - 90) * Math.PI / 180
              property real radius: dialContainer.width / 2 - 40
              x: dialContainer.width / 2 + Math.cos(angle) * radius - 20
              y: dialContainer.height / 2 + Math.sin(angle) * radius - 20
              width: 40; height: 40

              Text {
                anchors.centerIn: parent
                text: root.pad2(parent.displayNum)
                font.pixelSize: 16
                color: Palette.palette().onSurface
              }

              MouseArea {
                anchors.fill: parent
                onClicked: root.setMinute(parent.displayNum)
              }
            }
          }
        }

        // Minute numbers - highlighted layer (masked by knob)
        Item {
          id: minuteNumbersHighlight
          anchors.fill: parent
          visible: false
          layer.enabled: true

          Repeater {
            model: 12
            delegate: Item {
              property int displayNum: index * 5
              property real angle: (index * 30 - 90) * Math.PI / 180
              property real radius: dialContainer.width / 2 - 40
              x: dialContainer.width / 2 + Math.cos(angle) * radius - 20
              y: dialContainer.height / 2 + Math.sin(angle) * radius - 20
              width: 40; height: 40

              Text {
                anchors.centerIn: parent
                text: root.pad2(parent.displayNum)
                font.pixelSize: 16
                color: Palette.palette().onPrimary
              }
            }
          }
        }

        // Knob mask source for minutes
        Item {
          id: minuteKnobMask
          anchors.fill: parent
          visible: false

          Rectangle {
            width: 40; height: 40; radius: 20
            color: "white"
            x: dialContainer.width / 2 + Math.cos(hand.angleRad) * (dialContainer.width / 2 - 40) - 20
            y: dialContainer.height / 2 + Math.sin(hand.angleRad) * (dialContainer.width / 2 - 40) - 20
          }
        }

        // OpacityMask for minute highlight
        OpacityMask {
          anchors.fill: minuteNumbersHighlight
          source: minuteNumbersHighlight
          maskSource: minuteKnobMask
          visible: !selectingHour
          opacity: !selectingHour ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // Dial interaction area
        MouseArea {
          id: dialArea
          anchors.fill: parent

          function setHandAngle(rad, animate) {
            if (animate) {
              hand.animateTo(rad)
            } else {
              hand.animEnabled = false
              hand.angleRad = rad
              hand.animEnabled = true
            }
          }

          function angleFromPoint(px, py) {
            var cx = width / 2
            var cy = height / 2
            return Math.atan2(py - cy, px - cx)
          }

          function updateFromAngle(angle) {
            if (selectingHour) {
              var deg = angle * 180 / Math.PI + 90
              if (deg < 0) deg += 360
              var h = Math.round(deg / 30) % 12
              if (h === 0) h = 12
              root.setHourFromDisplay(h)
            } else {
              var deg = angle * 180 / Math.PI + 90
              if (deg < 0) deg += 360
              var m = Math.round(deg / 6) % 60
              root.setMinute(m)
            }
          }

          property bool isDragging: false
          
          onPressed: function(mouse) {
            isDragging = false
            var angle = angleFromPoint(mouse.x, mouse.y)
            // Animate to clicked position
            hand.animateTo(angle)
            updateFromAngle(angle)
          }

          onPositionChanged: function(mouse) {
            if (pressed) {
              isDragging = true
              // During drag, move instantly (no animation)
              hand.animEnabled = false
              handAnimation.stop()
              var angle = angleFromPoint(mouse.x, mouse.y)
              hand.angleRad = angle
              updateFromAngle(angle)
            }
          }

          onReleased: {
            hand.animEnabled = true
            if (selectingHour) {
              selectingHour = false
            }
          }
        }
      }

      // Action buttons
      Item {
        visible: showButtons
        width: parent.width
        height: showButtons ? 40 : 0

        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          Actions.Button {
            text: "Cancel"
            textButton: true
            onClicked: cancelled()
          }

          Actions.Button {
            text: "OK"
            textButton: true
            onClicked: accepted()
          }
        }
      }
    }
  }

  // Update hand position when mode changes
  Connections {
    target: root
    function onSelectingHourChanged() {
      root.updateHandForCurrent()
    }
  }

  Component.onCompleted: updateHandForCurrent()
}
