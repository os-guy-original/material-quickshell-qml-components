import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import "../../colors.js" as Palette

Item {
  id: root
  // Public API
  property string text: "Action"
  // "right" => dropdown on right, main action on left; "left" => dropdown on left
  property string orientation: "right"
  property bool enabled: true
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

  readonly property int collapsedHeight: 40
  implicitHeight: collapsedHeight
  // Width strictly follows content size (main segment + divider + chevron segment)
  implicitWidth: mainSegment.implicitWidth + dividerWidth + menuSegment.width

  function openMenu() {
    if (!Array.isArray(menuItems) || menuItems.length === 0) return
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

  Rectangle {
    id: container
    anchors.fill: parent
    radius: height / 2
    color: Palette.palette().primary
    border.width: 0
    antialiasing: true
    opacity: root.enabled ? 1.0 : 0.55
    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  }

  // Main action area
  Item {
    id: mainSegment
    anchors.top: parent.top
    anchors.bottom: parent.top
    anchors.bottomMargin: -(collapsedHeight)
    anchors.left: root.orientation === "right" ? parent.left : undefined
    anchors.right: root.orientation === "left" ? parent.right : undefined
    // Content-based width: margins + icon + spacing + text
    implicitWidth: 12 + plusGlyph.width + 10 + textItem.implicitWidth + 12
    width: implicitWidth

    // inner visual split rounding is handled by outer container; we draw only overlays
    // Hover/press overlay
    Rectangle {
      anchors.fill: parent
      color: Palette.palette().onPrimary
      radius: container.radius
      opacity: (ma.pressed ? 0.14 : (ma.containsMouse ? 0.08 : 0))
      visible: root.enabled
      Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
    }

    // vertical divider (toward menu side)
    Rectangle {
      width: dividerWidth
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.right: root.orientation === "right" ? parent.right : undefined
      anchors.left: root.orientation === "left" ? parent.left : undefined
      color: Palette.palette().onPrimary
      opacity: 0.35
      visible: true
    }

    Row {
      id: contentRow
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      spacing: 10
      layoutDirection: root.orientation === "right" ? Qt.LeftToRight : Qt.RightToLeft

      // Plus glyph in a soft circular chip
      Canvas {
        id: plusGlyph
        width: 26; height: 26
        anchors.verticalCenter: parent.verticalCenter
        onPaint: {
          var ctx = getContext('2d'); ctx.reset();
          var w = width, h = height
          // circular background
          ctx.beginPath(); ctx.arc(w/2, h/2, Math.min(w,h)/2, 0, Math.PI*2);
          ctx.fillStyle = Palette.palette().onPrimary
          ctx.fill()
          // plus sign
          ctx.strokeStyle = Palette.palette().primary
          ctx.lineWidth = 2
          ctx.lineCap = 'round'
          var r = Math.min(w,h) * 0.28
          ctx.beginPath(); ctx.moveTo(w/2 - r, h/2); ctx.lineTo(w/2 + r, h/2); ctx.stroke()
          ctx.beginPath(); ctx.moveTo(w/2, h/2 - r); ctx.lineTo(w/2, h/2 + r); ctx.stroke()
        }
      }

      Text {
        id: textItem
        text: root.text
        color: Palette.palette().onPrimary
        font.pixelSize: 14
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
    width: height // circular end

    // Hover/press overlay
    Rectangle {
      anchors.fill: parent
      color: Palette.palette().onPrimary
      radius: container.radius
      opacity: (mb.pressed ? 0.14 : (mb.containsMouse ? 0.08 : 0))
      visible: root.enabled
      Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
    }

    // Chevron-down glyph
    Canvas {
      id: chevron
      anchors.centerIn: parent
      width: 18; height: 18
      onPaint: {
        var ctx = getContext('2d'); ctx.reset();
        var w = width, h = height
        ctx.strokeStyle = Palette.palette().onPrimary
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


