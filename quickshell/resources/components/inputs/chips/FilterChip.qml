import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects
import "../../../colors.js" as Palette
import "../../feedback" as Feedback

Item {
  id: root
  property alias text: label.text
  property string symbol: ""  // Custom symbol/icon (empty = use tick)
  property bool checked: false
  property bool enabled: true
  property bool pill: false
  property bool noBorder: false
  property bool primaryWhenSelected: false
  property bool pressed: false
  
  readonly property int _padX: 10
  readonly property int _padY: 6
  readonly property int _gap: 6
  readonly property real _hairline: 1 / Screen.devicePixelRatio
  readonly property int _iconWidth: checked ? 16 : 0
  readonly property real _baseRadius: pill ? height / 2 : 8
  readonly property real _targetWidth: label.implicitWidth + _padX*2 + (checked ? _iconWidth + _gap : 0)
  
  property real _cornerRadius: _baseRadius

  signal toggled(bool checked)

  implicitWidth: _targetWidth
  implicitHeight: Math.max(28, label.implicitHeight + _padY*2)
  width: _targetWidth
  height: implicitHeight
  clip: true
  
  Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  Behavior on _cornerRadius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
  
  onPressedChanged: _cornerRadius = pressed ? 4 : _baseRadius
  on_BaseRadiusChanged: if (!pressed) _cornerRadius = _baseRadius

  // Background with ripple - using layer.effect for masking
  Item {
    id: background
    anchors.fill: parent
    layer.enabled: true
    layer.smooth: true
    layer.effect: OpacityMask {
      maskSource: Item {
        width: background.width
        height: background.height
        Rectangle {
          anchors.fill: parent
          radius: root._cornerRadius
          smooth: true
          Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
        }
      }
    }
    
    Rectangle {
      id: bg
      anchors.fill: parent
      color: {
        if (checked) {
          if (primaryWhenSelected) return Palette.palette().primary
          return Palette.isDarkMode() ? Palette.palette().primaryContainer : Qt.lighter(Palette.palette().primary, 3.3)
        }
        return Palette.palette().surface
      }
      
      Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }
    
    Feedback.RippleEffect {
      id: rippleEffect
      rippleColor: {
        if (checked && primaryWhenSelected) return Palette.palette().onPrimary
        return Palette.palette().onSurface
      }
    }
  }
  
  // Border (outside masking)
  Rectangle {
    id: borderRect
    anchors.fill: parent
    radius: _cornerRadius
    color: "transparent"
    border.width: (checked || noBorder) ? 0 : _hairline
    border.color: Palette.palette().outline
    
    Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
    Behavior on border.width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  }

  Item {
    id: iconContainer
    width: 16
    height: 16
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: _padX
    opacity: checked ? 1 : 0
    scale: checked ? 1 : 0.3
    
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
    
    // Custom symbol text
    Text {
      id: symbolText
      visible: symbol !== ""
      anchors.centerIn: parent
      text: symbol
      font.pixelSize: 14
      color: {
        if (!root.enabled) return Qt.rgba(0.5, 0.5, 0.5, 1)
        if (root.checked && root.primaryWhenSelected) return Palette.palette().onPrimary
        return Palette.palette().onSurface
      }
    }
    
    // Default tick mark
    Canvas {
      id: tick
      visible: symbol === ""
      anchors.fill: parent
      
      property color tickColor: {
        if (!root.enabled) return Qt.rgba(0.5, 0.5, 0.5, 1)
        if (root.checked && root.primaryWhenSelected) return Palette.palette().onPrimary
        return Palette.palette().onSurface
      }
      
      onTickColorChanged: requestPaint()
      
      onPaint: {
        var ctx = getContext('2d')
        ctx.reset()
        ctx.strokeStyle = tickColor
        ctx.lineWidth = 2
        ctx.lineCap = 'round'
        ctx.lineJoin = 'round'
        
        var px = 2, py = height / 2
        var mx = width * 0.4, my = height - 3
        var ex = width - 2, ey = 3
        
        ctx.beginPath()
        ctx.moveTo(px, py)
        ctx.lineTo(mx, my)
        ctx.lineTo(ex, ey)
        ctx.stroke()
      }
      
      Connections {
        target: root
        function onCheckedChanged() { tick.requestPaint() }
      }
    }
  }

  Text {
    id: label
    y: Math.round((parent.height - height) / 2)
    x: Math.round(checked ? (_padX + _iconWidth + _gap) : _padX)
    color: {
      if (!enabled) return Qt.rgba(0.5, 0.5, 0.5, 1)
      if (checked && primaryWhenSelected) return Palette.palette().onPrimary
      return Palette.palette().onSurface
    }
    font.pixelSize: 14
    text: ""
    renderType: Text.NativeRendering
    
    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.enabled
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onPressed: {
      if (enabled) {
        root.pressed = true
        rippleEffect.startHold(mouseX, mouseY)
      }
    }
    onReleased: {
      if (enabled) {
        root.pressed = false
        rippleEffect.endHold()
      }
    }
    onCanceled: {
      if (enabled) {
        root.pressed = false
        rippleEffect.endHold()
      }
    }
    onExited: {
      if (enabled) {
        root.pressed = false
        rippleEffect.endHold()
      }
    }
    onClicked: { 
      root.checked = !root.checked
      root.toggled(root.checked)
    }
  }
}
