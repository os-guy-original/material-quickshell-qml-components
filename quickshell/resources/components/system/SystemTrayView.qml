import QtQuick 2.15
import QtQml.Models 2.15
import Quickshell
import Quickshell.Services.SystemTray
import "../Menu" as MenuComp
import "../../colors.js" as Palette

Item {
  id: trayRoot
  property var parentWindow: null
  // Optional external overlay menu instance (HamburgerMenu) to use
  // If not provided, an internal one scoped to this component will be used
  property var externalMenuOverlay: null
  property int iconSize: 22
  property int spacing: 6
  implicitHeight: row.implicitHeight
  implicitWidth: row.implicitWidth

  Row {
    id: row
    // Let implicit size drive the parent; do not stretch
    spacing: trayRoot.spacing

    Repeater {
      id: rep
      model: SystemTray.items
      delegate: Item {
        id: iconBox
        width: trayRoot.iconSize + 10
        height: trayRoot.iconSize + 10
        property var itemRef: modelData
        property bool hovered: false

        // Material You-style hover state layer (circular)
        Rectangle {
          anchors.centerIn: parent
          width: trayRoot.iconSize + 12
          height: width
          radius: width / 2
          color: Palette.palette().onSurface
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
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: iconBox.hovered = true
          onExited: iconBox.hovered = false
          onClicked: function(mouse) {
            if (!iconBox.itemRef) return
            if (mouse.button === Qt.RightButton) {
              var menu = trayRoot.externalMenuOverlay || trayMenu
              menu.items = trayRoot.menuItemsFor(iconBox.itemRef, iconBox)
              if (menu.openAtItem) menu.openAtItem(iconBox)
            } else if (mouse.button === Qt.LeftButton) {
              if (iconBox.itemRef.onlyMenu && iconBox.itemRef.hasMenu) {
                trayRoot.openAppMenuAt(iconBox.itemRef, iconBox)
              } else {
                try { iconBox.itemRef.activate() } catch (e) { console.log("activate failed:", e) }
              }
            } else if (mouse.button === Qt.MiddleButton) {
              try { iconBox.itemRef.secondaryActivate() } catch (e2) { console.log("secondaryActivate failed:", e2) }
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

  function menuItemsFor(item, iconItem) {
    var label = (item && item.title && item.title.length) ? item.title : (item && item.id ? item.id : "Tray Item")
    var hasMenu = item && item.hasMenu
    var onlyMenu = item && item.onlyMenu
    var items = []
    items.push({ label: label, enabled: false })
    if (!onlyMenu) {
      items.push({ label: "Activate", onTriggered: function(){ try { item.activate() } catch(e){} } })
      items.push({ label: "Secondary action", onTriggered: function(){ try { item.secondaryActivate() } catch(e){} } })
    }
    if (hasMenu) {
      items.push({ label: "App menu…", onTriggered: function(){ trayRoot.openAppMenuAt(item, iconItem) } })
    }
    if (item && item.tooltipTitle) {
      items.push({ label: "— " + item.tooltipTitle, enabled: false })
    }
    if (item && item.tooltipDescription) {
      var desc = String(item.tooltipDescription)
      if (desc.length > 60) desc = desc.slice(0, 57) + "…"
      items.push({ label: desc, enabled: false })
    }
    return items
  }

  // Anchor to open app-provided SNI/DBus menus natively
  QsMenuAnchor {
    id: sniAnchor
  }
}


