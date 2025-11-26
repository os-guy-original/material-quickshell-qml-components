// Simple singleton shim so HamburgerMenu can coordinate open/close across overlays
//.pragma library

var _openMenus = []

function requestOpen(menu) {
  try {
    // If this menu is a submenu, don't close other menus (so parent remains visible).
    if (menu && menu.isSubmenu) {
      // avoid duplicates
      var found = false
      for (var j = 0; j < _openMenus.length; j++) { if (_openMenus[j] === menu) { found = true; break } }
      if (!found) _openMenus.push(menu)
    } else {
      // Close others on open to behave like a global menu overlay
      for (var i = 0; i < _openMenus.length; i++) {
        var m = _openMenus[i]
        if (m && m !== menu && m.close) {
          try { m.close() } catch (e) {}
        }
      }
      _openMenus = [menu]
    }
  } catch (e) { /* ignore */ }
}

function notifyClosed(menu) {
  // Remove if present
  var next = []
  for (var i = 0; i < _openMenus.length; i++) {
    var m = _openMenus[i]
    if (m && m !== menu) next.push(m)
  }
  _openMenus = next
}


