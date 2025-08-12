import QtQuick 2.15
import QtQml 2.15
import "../../colors.js" as Palette
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
  // Show only while open/fading; don't keep overlay alive when closed
  visible: open || panel.opacity > 0.01
  // Ensure above normal content and typical containers; below menus/Hamburger
  z: 998

  // Attach to window root so tooltip draws above other branches of the tree
  property bool attachToWindow: true
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
  onZChanged: _ensureOnHost()

  // State
  property bool open: false
  property string title: ""
  property string text: ""
  property var actions: []
  property Component contentComponent: null

  // Placement
  property int _x: 0
  property int _y: 0
  property Item anchorItem: null
  property real anchorLocalX: 0
  property real anchorLocalY: 0
  readonly property bool anchored: anchorItem !== null
  // follow anchor (e.g., on scroll)
  property int _tick: 0
  Timer { id: follow; interval: 16; repeat: true; running: overlay.open && overlay.anchored; onTriggered: overlay._tick++ }
  // Snapshot of last pointer position (used if window cursor is unavailable)
  property int _mouseX: 0
  property int _mouseY: 0

  function _placeWithinViewport(px, py) {
    // Try to avoid cursor by offsetting 14px right and 10px down, then clamp
    var ox = Math.round(px + 14)
    var oy = Math.round(py + 10)
    // Prefer above if too close to bottom
    if (oy + panel.implicitHeight > overlay.height) oy = Math.max(0, py - panel.implicitHeight - 12)
    if (ox + panel.implicitWidth > overlay.width) ox = Math.max(0, overlay.width - panel.implicitWidth - 6)
    return { x: ox, y: oy }
  }

  function openAt(x, y) {
    anchorItem = null
    _x = x; _y = y
    open = true
    // Compute position immediately to avoid initial jump to (0,0)
    var p = _placeWithinViewport(_x, _y); panel.x = p.x; panel.y = p.y
    console.log("Tooltip.openAt:", x, y)
  }
  function openNearPointer() {
    anchorItem = null
    var cx = _mouseX
    var cy = _mouseY
    try {
      if (overlay.window && overlay.window.mapFromGlobal) {
        // Prefer direct window mapping when available
        var gp = overlay.window.mapFromGlobal(Qt.point(Qt.cursorPos.x, Qt.cursorPos.y))
        cx = gp.x; cy = gp.y
      } else if (overlay.window && overlay.window.contentItem && overlay.window.contentItem.mapFromGlobal) {
        var mapped = overlay.window.contentItem.mapFromGlobal(Qt.cursorPos.x, Qt.cursorPos.y)
        cx = mapped.x; cy = mapped.y
      }
    } catch (e) {}
    var p = _placeWithinViewport(cx, cy)
    _x = p.x; _y = p.y
    open = true
    console.log("Tooltip.openNearPointer at", _x, _y)
  }
  function openAtAnchor(item, lx, ly) {
    try {
      anchorItem = item; anchorLocalX = lx; anchorLocalY = ly; open = true; overlay._tick++
      console.log("Tooltip.openAtAnchor for", item)
    } catch (e) { console.log("Tooltip.openAtAnchor failed:", e); openAt(0,0) }
  }
  function openFromEvent(item, mouseX, mouseY) {
    try {
      anchorItem = item; anchorLocalX = mouseX; anchorLocalY = mouseY; open = true; overlay._tick++
      console.log("Tooltip.openFromEvent for", item, mouseX, mouseY)
    } catch (e) { console.log("Tooltip.openFromEvent failed:", e); openAt(0,0) }
  }
  function close() { open = false; anchorItem = null }

  // Click-away
  MouseArea {
    anchors.fill: parent
    visible: overlay.open
    enabled: visible
    acceptedButtons: Qt.AllButtons
    propagateComposedEvents: true
    onClicked: overlay.close()
  }

  // Panel
  Rectangle {
    id: panel
    // anchored mapping
    x: overlay.anchored ? (function(){ overlay._tick; var p = overlay.anchorItem ? overlay.anchorItem.mapToItem(overlay, overlay.anchorLocalX, overlay.anchorLocalY) : { x: overlay._x }; var q = overlay._placeWithinViewport(p.x, p.y); return q.x })() : _x
    y: overlay.anchored ? (function(){ overlay._tick; var p = overlay.anchorItem ? overlay.anchorItem.mapToItem(overlay, overlay.anchorLocalX, overlay.anchorLocalY) : { y: overlay._y }; var q = overlay._placeWithinViewport(p.x || 0, p.y || 0); return q.y })() : _y
    visible: overlay.open || opacity > 0.01
    opacity: overlay.open ? 1.0 : 0.0
    radius: 10
    // Slightly stronger background for readability
    color: Palette.isDarkMode() ? Qt.lighter(Palette.palette().surface, 1.04)
                                 : Qt.darker(Palette.palette().surface, 1.06)
    border.width: 0
    antialiasing: true
    width: contentCol.implicitWidth + 18
    height: contentCol.implicitHeight + 14
    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Column {
      id: contentCol
      anchors.margins: 10
      anchors.fill: parent
      spacing: 8

      // Default content if no custom content provided
      Loader {
        id: custom
        visible: item !== null
        sourceComponent: overlay.contentComponent
        anchors.left: parent.left
        anchors.right: parent.right
      }

      Item {
        id: defaultBlock
        visible: custom.item === null
        implicitWidth: col.implicitWidth
        implicitHeight: col.implicitHeight
        Column { id: col; spacing: 6
          Text { text: overlay.title; visible: text && text.length > 0; color: Palette.palette().onSurface; font.pixelSize: 14; font.bold: true; wrapMode: Text.Wrap }
          Text { text: overlay.text;  visible: text && text.length > 0; color: Palette.palette().onSurfaceVariant; font.pixelSize: 13; wrapMode: Text.Wrap }
          // Actions row
          Row { spacing: 8; visible: Array.isArray(overlay.actions) && overlay.actions.length > 0
            Repeater { model: Array.isArray(overlay.actions) ? overlay.actions : []
              delegate: Item {
                property int minHeight: 24
                height: Math.max(minHeight, lbl.implicitHeight)
                width: lbl.implicitWidth
                // No background; text only, left aligned with body text
                Text { id: lbl; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: (modelData && modelData.label) ? modelData.label : ""; color: Palette.palette().primary; font.pixelSize: 12 }
                MouseArea { anchors.fill: parent; onClicked: { try { if (modelData && modelData.onTriggered) modelData.onTriggered() } catch(e){} overlay.close() } }
              }
            }
          }
        }
      }
    }
  }
}


