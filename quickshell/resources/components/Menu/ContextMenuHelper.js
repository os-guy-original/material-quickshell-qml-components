// Context menu helper library

// RightClickMenu helper: centralizes default items and opening logic

var _rcmComponent = null
// Component.Status constants (avoid referencing QML's Component enum from JS lib)
var STATUS_NULL = 0
var STATUS_READY = 1
var STATUS_LOADING = 2
var STATUS_ERROR = 3

function _ensureMenuComponent() {
  try {
    if (_rcmComponent && _rcmComponent.status === STATUS_READY) return _rcmComponent
    _rcmComponent = Qt.createComponent(Qt.resolvedUrl("RightClickMenu.qml"))
    return _rcmComponent
  } catch (e) {
    console.log("ContextMenuHelper: failed to create component:", e)
    _rcmComponent = null
    return null
  }
}

function _getOverlayHost(item) {
  if (!item) return null
  try {
    if (item.window && item.window.contentItem) return item.window.contentItem
  } catch (e) {}
  var t = item
  while (t && t.parent) t = t.parent
  return t
}

// Default items for a TextInput-like control
function defaultTextInputItems(input) {
  var hasSel = false
  try { hasSel = input.selectionStart !== input.selectionEnd } catch (e) {}
  return [
    { label: "Undo", onTriggered: function(){ try { input.undo() } catch(e){} } },
    { label: "Redo", onTriggered: function(){ try { input.redo() } catch(e){} } },
    { label: "Cut",  enabled: hasSel, onTriggered: function(){ try { input.cut() } catch(e){} } },
    { label: "Copy", enabled: hasSel, onTriggered: function(){ try { input.copy() } catch(e){} } },
    { label: "Paste", onTriggered: function(){ try { input.paste() } catch(e){} } },
    { label: "Select word", onTriggered: function(){ try { input.selectWord() } catch(e){} } },
    { label: "Select all", onTriggered: function(){ try { input.selectAll() } catch(e){} } }
  ]
}

// Open RightClickMenu at the given anchor point with provided items
// owner: the control that owns the menu (will store _contextMenu)
// anchorItem: item used for coordinate mapping (fallback to owner)
function openMenu(owner, anchorItem, mouseX, mouseY, items) {
  if (!owner) return
  var host = _getOverlayHost(owner)
  var comp = _ensureMenuComponent()
  if (!comp || !host) { console.log("ContextMenuHelper: missing component or host"); return }

  function doOpen() {
    try {
      if (!owner._contextMenu) owner._contextMenu = comp.createObject(host)
    } catch (e) {
      console.log("ContextMenuHelper: createObject failed:", e)
      owner._contextMenu = null
    }
    if (!owner._contextMenu) return
    owner._contextMenu.items = items || []
    // Prefer anchored opening so the menu follows the item when scrolling
    if (anchorItem && owner._contextMenu.openAtAnchor) {
      try { owner._contextMenu.openAtAnchor(anchorItem, mouseX, mouseY); return } catch (e) { /* fallback below */ }
    }
    var p
    try {
      if (anchorItem && anchorItem.mapToItem) p = anchorItem.mapToItem(host, mouseX, mouseY)
      else if (owner.mapToItem) p = owner.mapToItem(host, mouseX, mouseY)
      else p = { x: mouseX, y: mouseY }
    } catch (e) { p = { x: mouseX, y: mouseY } }
    owner._contextMenu.openAt(Math.round(p.x), Math.round(p.y))
  }

  if (comp.status === STATUS_READY) doOpen()
  else if (comp.status === STATUS_LOADING) {
    comp.statusChanged.connect(function(){ if (comp.status === STATUS_READY) doOpen() })
  } else if (comp.status === STATUS_ERROR) {
    console.log("ContextMenuHelper: component error:", comp.errorString())
  }
}


