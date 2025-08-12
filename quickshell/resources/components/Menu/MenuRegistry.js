// Simple singleton shim so HamburgerMenu can coordinate open/close across overlays
.pragma library

var _openMenus = []

function requestOpen(menu) {
  try {
    // Close others on open to behave like a global menu overlay
    for (var i = 0; i < _openMenus.length; i++) {
      var m = _openMenus[i]
      if (m && m !== menu && m.close) {
        try { m.close() } catch (e) {}
      }
    }
  } catch (e) { /* ignore */ }
  _openMenus = [menu]
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


