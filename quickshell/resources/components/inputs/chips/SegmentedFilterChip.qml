import QtQuick 2.15
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
  property bool isFirst: false
  property bool isLast: false
  
  readonly property int _padX: 12
  readonly property int _padY: 6
  readonly property int _gap: 6
  readonly property int _innerRadius: 6
  readonly property real _hairline: 1 / Screen.devicePixelRatio
  readonly property int _iconWidth: checked ? 16 : 0
  readonly property real _targetWidth: label.implicitWidth + _padX*2 + (checked ? _iconWidth + _gap : 0)

  signal toggled(bool checked)

  implicitWidth: _targetWidth
  implicitHeight: 32
  width: _targetWidth
  height: implicitHeight
  clip: true
  
  Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

  property real t: checked ? 1 : 0
  property bool itemPressed: false
  property real animatedRadius: 16  // Animated corner radius for smooth transitions (only for outer corners)
  
  Behavior on t { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  // Animate radius for checked chips or chips with exposed corners
  Behavior on animatedRadius { 
    enabled: checked || isFirst || isLast
    NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } 
  }
  
  onTChanged: bg.requestPaint()
  onItemPressedChanged: { 
    // Update animatedRadius for chips that should animate
    if (checked || isFirst || isLast) {
      animatedRadius = itemPressed ? 4 : 16
    }
    bg.requestPaint()
  }
  onCheckedChanged: { 
    t = checked ? 1 : 0
    // Reset radius when check state changes
    animatedRadius = itemPressed ? 4 : 16
    bg.requestPaint()
  }
  onAnimatedRadiusChanged: bg.requestPaint()

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
        Canvas {
          id: maskCanvas
          anchors.fill: parent
          onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var w = width
            var h = height
            var outerRadius = root.animatedRadius
            var pillRadius = h / 2
            // Checked chips: all corners animate (fully pill-shaped, animates to sharp when pressed)
            // Unchecked first chip: left corners (exposed) animate, right corners (sticked) stay at _innerRadius
            // Unchecked last chip: right corners (exposed) animate, left corners (sticked) stay at _innerRadius
            // Unchecked middle chip: all corners stay at _innerRadius (sticked on both sides)
            var rTL = root.checked ? outerRadius : (root.isFirst ? outerRadius : root._innerRadius)
            var rTR = root.checked ? outerRadius : (root.isLast ? outerRadius : root._innerRadius)
            var rBR = root.checked ? outerRadius : (root.isLast ? outerRadius : root._innerRadius)
            var rBL = root.checked ? outerRadius : (root.isFirst ? outerRadius : root._innerRadius)
            
            ctx.beginPath()
            ctx.moveTo(rTL, 0)
            ctx.lineTo(w - rTR, 0)
            ctx.arcTo(w, 0, w, rTR, rTR)
            ctx.lineTo(w, h - rBR)
            ctx.arcTo(w, h, w - rBR, h, rBR)
            ctx.lineTo(rBL, h)
            ctx.arcTo(0, h, 0, h - rBL, rBL)
            ctx.lineTo(0, rTL)
            ctx.arcTo(0, 0, rTL, 0, rTL)
            ctx.closePath()
            ctx.fillStyle = "white"
            ctx.fill()
          }
          
          Connections {
            target: root
            function onItemPressedChanged() { maskCanvas.requestPaint() }
            function onCheckedChanged() { maskCanvas.requestPaint() }
            function onAnimatedRadiusChanged() { maskCanvas.requestPaint() }
          }
          Component.onCompleted: requestPaint()
        }
      }
    }
    
    Canvas {
      id: bg
      anchors.fill: parent
      onPaint: {
        var ctx = getContext('2d')
        ctx.reset()
        var w = width
        var h = height
        var outerRadius = animatedRadius
        var pillRadius = h / 2
        // Checked chips: all corners animate (fully pill-shaped, animates to sharp when pressed)
        // Unchecked first chip: left corners (exposed) animate, right corners (sticked) stay at _innerRadius
        // Unchecked last chip: right corners (exposed) animate, left corners (sticked) stay at _innerRadius
        // Unchecked middle chip: all corners stay at _innerRadius (sticked on both sides)
        var rTL = checked ? outerRadius : (isFirst ? outerRadius : _innerRadius)
        var rTR = checked ? outerRadius : (isLast ? outerRadius : _innerRadius)
        var rBR = checked ? outerRadius : (isLast ? outerRadius : _innerRadius)
        var rBL = checked ? outerRadius : (isFirst ? outerRadius : _innerRadius)
        
        function drawRoundRect(radTL, radTR, radBR, radBL) {
          ctx.beginPath()
          ctx.moveTo(radTL, 0)
          ctx.lineTo(w - radTR, 0)
          ctx.arcTo(w, 0, w, radTR, radTR)
          ctx.lineTo(w, h - radBR)
          ctx.arcTo(w, h, w - radBR, h, radBR)
          ctx.lineTo(radBL, h)
          ctx.arcTo(0, h, 0, h - radBL, radBL)
          ctx.lineTo(0, radTL)
          ctx.arcTo(0, 0, radTL, 0, radTL)
          ctx.closePath()
        }
        
        // unselected base
        ctx.fillStyle = Palette.palette().surfaceVariant
        drawRoundRect(rTL, rTR, rBR, rBL)
        ctx.fill()
        
        // overlay primary with animated alpha for selection
        if (t > 0) {
          ctx.globalAlpha = t
          ctx.fillStyle = Palette.palette().primary
          drawRoundRect(rTL, rTR, rBR, rBL)
          ctx.fill()
          ctx.globalAlpha = 1.0
        }
      }
    }
    
    Feedback.RippleEffect {
      id: rippleEffect
      rippleColor: checked ? Palette.palette().onPrimary : Palette.palette().onSurface
    }
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
      color: checked ? Palette.palette().onPrimary : Palette.palette().onSurface
    }
    
    // Default tick mark
    Canvas {
      id: tick
      visible: symbol === ""
      anchors.fill: parent
      
      property color tickColor: checked ? Palette.palette().onPrimary : Palette.palette().onSurface
      
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
    color: checked ? Palette.palette().onPrimary : Palette.palette().onSurface
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
        root.itemPressed = true
        rippleEffect.startHold(mouseX, mouseY)
      }
    }
    onReleased: {
      if (enabled) {
        root.itemPressed = false
        rippleEffect.endHold()
      }
    }
    onCanceled: {
      if (enabled) {
        root.itemPressed = false
        rippleEffect.endHold()
      }
    }
    onExited: {
      if (enabled) {
        root.itemPressed = false
        rippleEffect.endHold()
      }
    }
    onClicked: { 
      root.checked = !root.checked
      root.toggled(root.checked)
    }
  }
}
