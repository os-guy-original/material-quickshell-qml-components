import QtQuick 2.15
import Quickshell
import Quickshell.Services.SystemTray
import "../Menu" as MenuComp
import ".." as Components

Item {
  id: trayRoot
  property var parentWindow: null
  property var externalMenuOverlay: null
  property int iconSize: 22
  property int spacing: 6
  implicitHeight: iconSize
  implicitWidth: row.width

  Row {
    id: row
    spacing: trayRoot.spacing
    anchors.centerIn: parent

    Repeater {
      model: SystemTray.items
      delegate: Item {
        id: iconBox
        width: trayRoot.iconSize
        height: trayRoot.iconSize
        property var itemRef: modelData
        property bool hovered: false

        Rectangle {
          anchors.centerIn: parent
          width: trayRoot.iconSize
          height: width
          radius: width / 2
          color: Components.ColorPalette.onSurface
          opacity: hovered ? 0.08 : 0.0
          antialiasing: true
          Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
        }

        Image {
          anchors.centerIn: parent
          source: itemRef && itemRef.icon ? itemRef.icon : ""
          width: trayRoot.iconSize
          height: trayRoot.iconSize
          fillMode: Image.PreserveAspectFit
          smooth: true
          asynchronous: false
          visible: status === Image.Ready || status === Image.Loading
          onStatusChanged: {
            if (status === Image.Error) {
              visible = false
            }
          }
        }

        MouseArea {
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          onEntered: iconBox.hovered = true
          onExited: iconBox.hovered = false
          onClicked: function(mouse) {
            if (!iconBox.itemRef) return
            if (mouse.button === Qt.RightButton) {
              var menu = trayRoot.externalMenuOverlay || trayMenu
              var items = trayRoot.menuItemsFor(iconBox.itemRef, iconBox)
              if (items && items.length > 0) {
                menu.menuItems = items
                menu.openAt(0, 0)
              }
            } else if (mouse.button === Qt.LeftButton) {
              if (iconBox.itemRef.onlyMenu && iconBox.itemRef.hasMenu) {
                trayRoot.openAppMenuAt(iconBox.itemRef, iconBox)
              } else {
                try { iconBox.itemRef.activate() } catch (e) {}
              }
            } else if (mouse.button === Qt.MiddleButton) {
              try { iconBox.itemRef.secondaryActivate() } catch (e) {}
            }
          }
        }
      }
    }
  }

  // Custom context menu overlay (sized to window content without cross-parent anchors)
  MenuComp.HamburgerMenu {
    id: trayMenu
    x: 0
    y: 0
    width: (trayRoot.window && trayRoot.window.contentItem) ? trayRoot.window.contentItem.width : trayRoot.width
    height: (trayRoot.window && trayRoot.window.contentItem) ? trayRoot.window.contentItem.height : trayRoot.height
    z: 999
  }

  function openAppMenuAt(item, iconItem) {
    if (!item || !iconItem) return
    var win = parentWindow || trayRoot.window
    if (!win) return
    // Configure anchor for native menu
    sniAnchor.anchor.window = win
    // Position: bottom-left of icon relative to window
    var p = iconItem.mapToItem(win.contentItem || win, 0, iconItem.height)
    sniAnchor.anchor.rect.x = Math.round(p.x)
    sniAnchor.anchor.rect.y = Math.round(p.y)
    try {
      // Prefer native menu handle if available
      if (item.menu) {
        sniAnchor.menu = item.menu
        sniAnchor.open()
      } else {
        // Fallback: request platform display
        item.display(win, Math.round(p.x), Math.round(p.y))
      }
    } catch (e) {
      console.log("menu open failed:", e)
    }
  }

  QsMenuOpener {
    id: menuOpener
    property var pendingCallback: null
    onChildrenChanged: {
      if (pendingCallback && children && children.values.length > 0) {
        var cb = pendingCallback
        pendingCallback = null
        cb()
      }
    }
  }
  
  function menuItemsFor(item, iconItem) {
    if (item && item.menu) {
      menuOpener.menu = item.menu
      if (menuOpener.menu && menuOpener.menu.updateLayout) {
        menuOpener.menu.updateLayout()
      }
      // Wait for children to populate before returning items
      if (menuOpener.children && menuOpener.children.values.length > 0) {
        return buildMenuItems(menuOpener)
      }
      // Set up callback to open menu once children are ready
      if (!menuOpener.pendingCallback) {
        menuOpener.pendingCallback = function() {
          var menu = trayRoot.externalMenuOverlay || trayMenu
          menu.menuItems = buildMenuItems(menuOpener)
          if (menu.menuItems && menu.menuItems.length > 0) menu.openAt(0, 0)
        }
      }
      return []
    }
    var onlyMenu = item && item.onlyMenu
    var items = []
    if (!onlyMenu) {
      items.push({ label: "Activate", onTriggered: function(){ try { item.activate() } catch(e){} } })
      items.push({ label: "Secondary action", onTriggered: function(){ try { item.secondaryActivate() } catch(e){} } })
    }
    return items
  }
  
  function buildMenuItems(opener) {
    var items = []
    var lastWasSeparator = false
    for (var i = 0; i < opener.children.values.length; i++) {
      var entry = opener.children.values[i]
      if (entry.isSeparator) {
        if (!lastWasSeparator && items.length > 0) {
          items.push({ isSeparator: true })
          lastWasSeparator = true
        }
      } else {
        lastWasSeparator = false
        var hasChildren = entry.hasChildren
        var submenu = null
        if (hasChildren) {
          var subOpener = Qt.createQmlObject('import QtQuick 2.15; import Quickshell; QsMenuOpener {}', trayRoot)
          subOpener.menu = entry
          submenu = buildMenuItems(subOpener)
          subOpener.destroy()
        }
        items.push({ 
          label: entry.text,
          enabled: entry.enabled,
          submenu: submenu,
          onTriggered: hasChildren ? null : (function(e) { return function() { e.triggered() } })(entry)
        })
      }
    }
    if (items.length > 0 && items[items.length - 1].isSeparator) {
      items.pop()
    }
    return items
  }

  // Anchor to open app-provided SNI/DBus menus natively
  QsMenuAnchor {
    id: sniAnchor
  }
}


