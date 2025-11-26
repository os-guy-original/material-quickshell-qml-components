import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import ".." as Components

Item {
  id: root
  // Public API
  property string text: "Action"
  // "right" => dropdown on right, main action on left; "left" => dropdown on left
  property string orientation: "right"
  property bool enabled: true
  property bool showIcon: false  // Show plus icon
  property int gapWidth: 8
  property int gapRadius: 6
  // Visual divider between segments (pixels)
  property int dividerWidth: 1
  // Optional items for a simple built-in popup menu
  // Each item: { label: string, onTriggered: function(){} }
  property var menuItems: []
  signal actionClicked()
  signal menuOpened()
  signal menuClosed()
  // Internal reference to window-wide hamburger overlay
  property var _menu: null

  readonly property int collapsedHeight: 48
  readonly property int _innerRadius: 4
  property bool _menuOpen: false
  property real _menuCornerRadius: _innerRadius
  
  implicitHeight: collapsedHeight
  // Width strictly follows content size (main segment + divider + chevron segment)
  implicitWidth: mainSegment.implicitWidth + dividerWidth + menuSegment.width
  
  Behavior on _menuCornerRadius {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }

  function openMenu() {
    if (!Array.isArray(menuItems) || menuItems.length === 0) return
    _menuOpen = true
    _menuCornerRadius = menuSegment.height / 2
    // Resolve a suitable overlay host (prefer window.contentItem, else top-most parent)
    var host = null
    try {
      if (root.window && root.window.contentItem) host = root.window.contentItem
    } catch(e) {}
    if (!host) {
      var p = root
      while (p && p.parent) p = p.parent
      host = p
    }
    if (!host) return
    // Create once and reuse so click-away works consistently
    if (!_menu) {
      var comp = Qt.createComponent(Qt.resolvedUrl("../Menu/HamburgerMenu.qml"))
      function finishCreate() {
        _menu = comp.createObject(host, {})
        if (!_menu) return
        _menu.z = 2000
        _menu.closed.connect(function(){ 
          root._menuOpen = false
          root._menuCornerRadius = root._innerRadius
          root.menuClosed() 
        })
        _menu.closed.connect(function(){ root.menuClosed() })
        _menu.items = menuItems
        _menu.openAtItem(menuSegment)
        root.menuOpened()
      }
      if (comp.status === Component.Ready) {
        finishCreate()
      } else if (comp.status === Component.Error) {
        console.log("SplitButton: failed to load HamburgerMenu:", comp.errorString())
        return
      } else {
        comp.statusChanged.connect(function(){
          if (comp.status === Component.Ready) finishCreate()
          else if (comp.status === Component.Error) console.log("SplitButton: failed to load HamburgerMenu:", comp.errorString())
        })
      }
      return
    }
    _menu.items = menuItems
    _menu.openAtItem(menuSegment)
    root.menuOpened()
  }

  Component.onDestruction: {
    try { if (_menu) { _menu.close(); _menu.destroy(); } } catch(e) {}
  }

  Canvas {
    id: container
    anchors.fill: parent
    opacity: root.enabled ? 1.0 : 0.55
    
    onPaint: {
      var ctx = getContext('2d')
      ctx.reset()
      var h = height
      var pillRadius = h / 2
      var innerR = _innerRadius
      
      ctx.fillStyle = Components.ColorPalette.primary
      
      if (orientation === "right") {
        // Main segment on left
        var mainW = mainSegment.width
        ctx.beginPath()
        ctx.moveTo(pillRadius, 0)
        ctx.lineTo(mainW - innerR, 0)
        ctx.arcTo(mainW, 0, mainW, innerR, innerR)
        ctx.lineTo(mainW, h - innerR)
        ctx.arcTo(mainW, h, mainW - innerR, h, innerR)
        ctx.lineTo(pillRadius, h)
        ctx.arcTo(0, h, 0, h - pillRadius, pillRadius)
        ctx.lineTo(0, pillRadius)
        ctx.arcTo(0, 0, pillRadius, 0, pillRadius)
        ctx.closePath()
        ctx.fill()
        
        // Menu segment on right
        var menuX = mainW + dividerWidth
        var menuW = menuSegment.width
        var menuInnerR = _menuCornerRadius  // sticked side (animates)
        var menuOuterR = pillRadius  // outer side (stays pill)
        ctx.beginPath()
        ctx.moveTo(menuX + menuInnerR, 0)
        ctx.lineTo(menuX + menuW - menuOuterR, 0)
        ctx.arcTo(menuX + menuW, 0, menuX + menuW, menuOuterR, menuOuterR)
        ctx.lineTo(menuX + menuW, h - menuOuterR)
        ctx.arcTo(menuX + menuW, h, menuX + menuW - menuOuterR, h, menuOuterR)
        ctx.lineTo(menuX + menuInnerR, h)
        ctx.arcTo(menuX, h, menuX, h - menuInnerR, menuInnerR)
        ctx.lineTo(menuX, menuInnerR)
        ctx.arcTo(menuX, 0, menuX + menuInnerR, 0, menuInnerR)
        ctx.closePath()
        ctx.fill()
      } else {
        // Menu segment on left
        var menuW = menuSegment.width
        var menuOuterR = pillRadius  // outer side (stays pill)
        var menuInnerR = _menuCornerRadius  // sticked side (animates)
        ctx.beginPath()
        ctx.moveTo(menuOuterR, 0)
        ctx.lineTo(menuW - menuInnerR, 0)
        ctx.arcTo(menuW, 0, menuW, menuInnerR, menuInnerR)
        ctx.lineTo(menuW, h - menuInnerR)
        ctx.arcTo(menuW, h, menuW - menuInnerR, h, menuInnerR)
        ctx.lineTo(menuOuterR, h)
        ctx.arcTo(0, h, 0, h - menuOuterR, menuOuterR)
        ctx.lineTo(0, menuOuterR)
        ctx.arcTo(0, 0, menuOuterR, 0, menuOuterR)
        ctx.closePath()
        ctx.fill()
        
        // Main segment on right
        var mainX = menuW + dividerWidth
        var mainW = mainSegment.width
        ctx.beginPath()
        ctx.moveTo(mainX + innerR, 0)
        ctx.lineTo(mainX + mainW - pillRadius, 0)
        ctx.arcTo(mainX + mainW, 0, mainX + mainW, pillRadius, pillRadius)
        ctx.lineTo(mainX + mainW, h - pillRadius)
        ctx.arcTo(mainX + mainW, h, mainX + mainW - pillRadius, h, pillRadius)
        ctx.lineTo(mainX + innerR, h)
        ctx.arcTo(mainX, h, mainX, h - innerR, innerR)
        ctx.lineTo(mainX, innerR)
        ctx.arcTo(mainX, 0, mainX + innerR, 0, innerR)
        ctx.closePath()
        ctx.fill()
      }
    }
    
    Connections {
      target: root
      function on_MenuCornerRadiusChanged() { container.requestPaint() }
    }
    
    Component.onCompleted: requestPaint()
  }

  // Main action area
  Item {
    id: mainSegment
    anchors.top: parent.top
    anchors.bottom: parent.top
    anchors.bottomMargin: -(collapsedHeight)
    anchors.left: root.orientation === "right" ? parent.left : undefined
    anchors.right: root.orientation === "left" ? parent.right : undefined
    // Content-based width: margins + optional icon + spacing + text
    implicitWidth: 16 + (root.showIcon ? (plusGlyph.width + 8) : 0) + textItem.implicitWidth + 16
    width: implicitWidth

    // Hover/press overlay with custom shape
    Canvas {
      id: mainOverlay
      anchors.fill: parent
      opacity: (ma.pressed ? 0.14 : (ma.containsMouse ? 0.08 : 0))
      visible: root.enabled
      
      Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
      
      onPaint: {
        var ctx = getContext('2d')
        ctx.reset()
        var w = width
        var h = height
        var pillRadius = h / 2
        
        var rTL, rTR, rBR, rBL
        if (root.orientation === "right") {
          // Main on left: left corners pill, right corners small (sticked)
          rTL = pillRadius
          rBL = pillRadius
          rTR = root._innerRadius
          rBR = root._innerRadius
        } else {
          // Main on right: right corners pill, left corners small (sticked)
          rTL = root._innerRadius
          rBL = root._innerRadius
          rTR = pillRadius
          rBR = pillRadius
        }
        
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
        
        ctx.fillStyle = Components.ColorPalette.onPrimary
        ctx.fill()
      }
      
      Component.onCompleted: requestPaint()
    }

    // vertical divider (toward menu side)
    Rectangle {
      width: dividerWidth
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.right: root.orientation === "right" ? parent.right : undefined
      anchors.left: root.orientation === "left" ? parent.left : undefined
      color: Components.ColorPalette.onPrimary
      opacity: 0.35
      visible: true
    }

    Row {
      id: contentRow
      anchors.fill: parent
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      spacing: 8
      layoutDirection: root.orientation === "right" ? Qt.LeftToRight : Qt.RightToLeft

      // Plus glyph in a soft circular chip (optional)
      Canvas {
        id: plusGlyph
        visible: root.showIcon
        width: 18; height: 18
        anchors.verticalCenter: parent.verticalCenter
        onPaint: {
          var ctx = getContext('2d'); ctx.reset();
          var w = width, h = height
          // circular background
          ctx.beginPath(); ctx.arc(w/2, h/2, Math.min(w,h)/2, 0, Math.PI*2);
          ctx.fillStyle = Components.ColorPalette.onPrimary
          ctx.fill()
          // plus sign
          ctx.strokeStyle = Components.ColorPalette.primary
          ctx.lineWidth = 1.5
          ctx.lineCap = 'round'
          var r = Math.min(w,h) * 0.30
          ctx.beginPath(); ctx.moveTo(w/2 - r, h/2); ctx.lineTo(w/2 + r, h/2); ctx.stroke()
          ctx.beginPath(); ctx.moveTo(w/2, h/2 - r); ctx.lineTo(w/2, h/2 + r); ctx.stroke()
        }
      }

      Text {
        id: textItem
        text: root.text
        color: Components.ColorPalette.onPrimary
        font.pixelSize: 15
        font.weight: Font.Medium
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.enabled
      cursorShape: Qt.PointingHandCursor
      onClicked: root.actionClicked()
    }
  }

  // Dropdown area
  Item {
    id: menuSegment
    anchors.top: parent.top
    anchors.bottom: parent.top
    anchors.bottomMargin: -(collapsedHeight)
    anchors.right: root.orientation === "right" ? parent.right : undefined
    anchors.left: root.orientation === "left" ? parent.left : undefined
    width: height * 1.1 // slightly wider than square

    // Hover/press overlay with custom shape
    Canvas {
      id: menuOverlay
      anchors.fill: parent
      opacity: (mb.pressed ? 0.14 : (mb.containsMouse ? 0.08 : 0))
      visible: root.enabled
      
      Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
      
      onPaint: {
        var ctx = getContext('2d')
        ctx.reset()
        var w = width
        var h = height
        var pillR = h / 2
        var menuInnerR = root._menuCornerRadius
        
        var rTL, rTR, rBR, rBL
        if (root.orientation === "right") {
          // Menu on right: left corners animate (sticked), right corners stay pill
          rTL = menuInnerR
          rBL = menuInnerR
          rTR = pillR
          rBR = pillR
        } else {
          // Menu on left: right corners animate (sticked), left corners stay pill
          rTL = pillR
          rBL = pillR
          rTR = menuInnerR
          rBR = menuInnerR
        }
        
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
        
        ctx.fillStyle = Components.ColorPalette.onPrimary
        ctx.fill()
      }
      
      Connections {
        target: root
        function on_MenuCornerRadiusChanged() { menuOverlay.requestPaint() }
      }
      
      Component.onCompleted: requestPaint()
    }

    // Chevron glyph with rotation
    Canvas {
      id: chevron
      anchors.centerIn: parent
      width: 18; height: 18
      rotation: root._menuOpen ? 180 : 0
      
      Behavior on rotation {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }
      
      onPaint: {
        var ctx = getContext('2d'); ctx.reset();
        var w = width, h = height
        ctx.strokeStyle = Components.ColorPalette.onPrimary
        ctx.lineWidth = 2
        ctx.lineCap = 'round'
        ctx.beginPath()
        ctx.moveTo(w*0.20, h*0.40)
        ctx.lineTo(w*0.50, h*0.65)
        ctx.lineTo(w*0.80, h*0.40)
        ctx.stroke()
      }
    }

    MouseArea {
      id: mb
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.enabled
      cursorShape: Qt.PointingHandCursor
      onClicked: openMenu()
    }
  }

  // Disable old gap visuals
  Rectangle { id: gap; visible: false; width: 0; height: 0 }
}


