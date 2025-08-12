.pragma library

var host = null

function register(instance) {
  host = instance
}

function isRegistered() { return host !== null }

function show(opts) {
  if (!host) { return }
  opts = opts || {}
  if (typeof opts.title === 'string') host.title = opts.title
  if (typeof opts.text === 'string') host.text = opts.text
  if (typeof opts.primaryText === 'string') host.primaryText = opts.primaryText
  if (typeof opts.secondaryText === 'string') host.secondaryText = opts.secondaryText
  if (typeof opts.dismissible === 'boolean') host.dismissible = opts.dismissible
  if (typeof opts.preferredWidth === 'number') host.preferredWidth = opts.preferredWidth
  if (typeof opts.maxWidth === 'number') host.maxWidth = opts.maxWidth
  if (opts.clearContent === true && host.contentContainer) {
    // remove previous children
    var list = host.contentContainer.children.slice()
    for (var i = 0; i < list.length; i++) {
      var ch = list[i]
      try { if (ch && ch.destroy) ch.destroy() } catch (e) { /* ignore */ }
    }
  }
  if (typeof opts.onAccepted === 'function') {
    host._onAccepted = opts.onAccepted
  } else { host._onAccepted = null }
  if (typeof opts.onRejected === 'function') {
    host._onRejected = opts.onRejected
  } else { host._onRejected = null }

  // Optional dynamic content injection
  try {
    if (opts.contentQml && host.contentContainer) {
      // Inline QML string
      Qt.createQmlObject(opts.contentQml, host.contentContainer)
    } else if (opts.componentUrl && host.contentContainer) {
      // Create from external component URL
      var comp = Qt.createComponent(opts.componentUrl)
      if (comp.status === Component.Ready) {
        comp.createObject(host.contentContainer, opts.componentProps || {})
      } else if (comp.status === Component.Error) {
        console.warn('DialogService: Component load error for', opts.componentUrl, comp.errorString())
      } else {
        comp.statusChanged.connect(function() {
          if (comp.status === Component.Ready) {
            comp.createObject(host.contentContainer, opts.componentProps || {})
          } else if (comp.status === Component.Error) {
            console.warn('DialogService: Component load error for', opts.componentUrl, comp.errorString())
          }
        })
      }
    } else if (opts.items && host.contentContainer) {
      // Reparent existing items
      for (var i = 0; i < opts.items.length; i++) {
        var item = opts.items[i]
        if (item) {
          try { item.parent = host.contentContainer } catch (e) { /* ignore */ }
        }
      }
    }
  } catch (e) {
    console.warn('DialogService: content injection error', e)
  }
  host.open = true
}

function close() { if (host) host.open = false }


