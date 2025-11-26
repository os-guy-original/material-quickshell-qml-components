import QtQuick 2.15
import QtQml 2.15
import ".." as Components
import "../actions" as Actions

/*
  Tooltip overlay (callable)
  - Programmatically open near a point or anchored to an item
  - Tries to avoid colliding with the mouse by offsetting placement
  - Can host buttons via actions model or fully custom content

  Public API:
    property bool open
    property string title
    property string text
    property var actions    // Array of { label, onTriggered?() }
    property Component contentComponent  // optional fully custom content

    function openAt(x, y)
    function openAtAnchor(item, localX, localY)
    function close()
*/

Item {
  id: overlay
  anchors.fill: parent
  visible: open || closing
  z: 998

  property bool attachToWindow: true
  property bool closing: false
  
  function _host() {
    try { if (overlay.window && overlay.window.contentItem) return overlay.window.contentItem } catch (e) {}
    var t = overlay; while (t.parent) t = t.parent; return t
  }
  function _ensureOnHost() {
    if (!attachToWindow) return
    var h = _host()
    if (h && overlay.parent !== h) {
      overlay.parent = h
      overlay.anchors.fill = h
    }
  }
  Component.onCompleted: _ensureOnHost()
  onVisibleChanged: if (visible) _ensureOnHost()

  // State
  property bool open: false
  property string title: ""
  property string text: ""
  property var actions: []
  property Component contentComponent: null

  // Placement
  property real _targetX: 0
  property real _targetY: 0
  property Item anchorItem: null
  property real anchorLocalX: 0
  property real anchorLocalY: 0
  readonly property bool anchored: anchorItem !== null

  // Follow anchor position updates
  Timer {
    id: followTimer
    interval: 16
    repeat: true
    running: overlay.open && overlay.anchored
    onTriggered: overlay._updateAnchoredPosition()
  }

  function _updateAnchoredPosition() {
    if (!anchorItem) return
    try {
      var p = anchorItem.mapToItem(overlay, anchorLocalX, anchorLocalY)
      var placed = _placeWithinViewport(p.x, p.y)
      _targetX = placed.x
      _targetY = placed.y
    } catch (e) {}
  }

  function _placeWithinViewport(px, py) {
    var panelW = panel.width > 0 ? panel.width : 150
    var panelH = panel.height > 0 ? panel.height : 40
    
    // Offset from cursor
    var ox = Math.round(px + 12)
    var oy = Math.round(py + 8)
    
    // Prefer above if too close to bottom
    if (oy + panelH > overlay.height - 8) {
      oy = Math.max(8, py - panelH - 12)
    }
    // Clamp horizontally
    if (ox + panelW > overlay.width - 8) {
      ox = Math.max(8, overlay.width - panelW - 8)
    }
    if (ox < 8) ox = 8
    if (oy < 8) oy = 8
    
    return { x: ox, y: oy }
  }

  onOpenChanged: {
    if (open) {
      closing = false
      panel.visible = true
      panel.opacity = 1
    } else {
      closing = true
      panel.opacity = 0
    }
  }

  function openAt(x, y) {
    anchorItem = null
    var p = _placeWithinViewport(x, y)
    _targetX = p.x
    _targetY = p.y
    // Set position immediately before showing
    panel.x = _targetX
    panel.y = _targetY
    open = true
  }

  function openAtAnchor(item, lx, ly) {
    if (!item) { openAt(0, 0); return }
    anchorItem = item
    anchorLocalX = lx
    anchorLocalY = ly
    // Calculate position first
    try {
      var p = item.mapToItem(overlay, lx, ly)
      var placed = _placeWithinViewport(p.x, p.y)
      _targetX = placed.x
      _targetY = placed.y
    } catch (e) {
      _targetX = 0
      _targetY = 0
    }
    // Set position immediately before showing
    panel.x = _targetX
    panel.y = _targetY
    open = true
  }

  function openFromEvent(item, mouseX, mouseY) {
    openAtAnchor(item, mouseX, mouseY)
  }

  function close() {
    open = false
    anchorItem = null
  }

  // Click-away background
  MouseArea {
    anchors.fill: parent
    visible: overlay.open
    enabled: visible
    acceptedButtons: Qt.AllButtons
    onClicked: overlay.close()
  }

  // Panel
  Rectangle {
    id: panel
    x: overlay._targetX
    y: overlay._targetY
    visible: false
    opacity: 0
    
    radius: 8
    color: Components.ColorPalette.isDarkMode 
           ? Qt.lighter(Components.ColorPalette.surface, 1.12)
           : Qt.darker(Components.ColorPalette.surface, 1.06)
    border.width: 0
    antialiasing: true
    
    width: contentCol.width + 20
    height: contentCol.height + 14
    
    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    
    Behavior on opacity { 
      NumberAnimation { 
        duration: 160
        easing.type: Easing.OutCubic
        onRunningChanged: {
          if (!running && panel.opacity === 0 && overlay.closing) {
            panel.visible = false
            overlay.closing = false
          }
        }
      }
    }

    Column {
      id: contentCol
      anchors.centerIn: parent
      spacing: 4

      // Custom content loader
      Loader {
        id: customLoader
        active: overlay.contentComponent !== null
        sourceComponent: overlay.contentComponent
      }

      // Default content (title)
      Text {
        id: titleText
        text: overlay.title
        visible: overlay.title.length > 0 && customLoader.item === null
        color: Components.ColorPalette.onSurface
        font.pixelSize: 13
        font.weight: Font.Medium
        wrapMode: Text.NoWrap
      }
      
      // Default content (text/description)
      Text {
        id: descText
        text: overlay.text
        visible: overlay.text.length > 0 && customLoader.item === null
        color: Components.ColorPalette.onSurfaceVariant
        font.pixelSize: 12
        wrapMode: Text.NoWrap
      }
      
      // Actions row
      Row {
        spacing: 12
        visible: Array.isArray(overlay.actions) && overlay.actions.length > 0 && customLoader.item === null
        topPadding: 4
        
        Repeater {
          model: Array.isArray(overlay.actions) ? overlay.actions : []
          delegate: Text {
            text: (modelData && modelData.label) ? modelData.label : ""
            color: Components.ColorPalette.primary
            font.pixelSize: 12
            font.weight: Font.Medium
            
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                try { if (modelData && modelData.onTriggered) modelData.onTriggered() } catch(e) {}
                overlay.close()
              }
            }
          }
        }
      }
    }
  }
}
