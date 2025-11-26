import QtQuick 2.15
import QtQml 2.15
import "../../colors.js" as Palette

/*
  Simplified context menu intended for text inputs.
  Differences vs HamburgerMenu:
  - No outline; subtle surface background
  - Smaller corner radius
  - Row hover fills the entire row area with no rounded hover chip
  - No nested submenus (flat list)

  Usage:
    RightClickMenu {
      id: ctx
      anchors.fill: parent   // overlay region; typically a window/root item
      items: [
        { label: "Copy", onTriggered: function() { console.log("copy") } }
      ]
    }
    ctx.openAt(mouseX, mouseY)
*/
Item {
  id: overlay
  anchors.fill: parent
  visible: open || panel.opacity > 0.01
  z: 999

  property bool open: false
  // Suppress the first click (mouse release) that opened the menu so it doesn't immediately close
  property bool _ignoreFirstClick: false
  property var items: [] // Array of { label, enabled?, onTriggered?() }
  onItemsChanged: { try { panel.maxRowWidth = 0 } catch (e) {} }
  property int menuX: 0
  property int menuY: 0
  property int minWidth: 140
  // Anchor support: follow an item's position (e.g., when its container scrolls)
  property Item anchorItem: null
  property real anchorLocalX: 0
  property real anchorLocalY: 0
  readonly property bool anchored: anchorItem !== null
  // Tick to refresh mapping while anchored and open
  property int _positionTick: 0
  Timer {
    id: _anchorTracker
    interval: 16
    repeat: true
    running: overlay.open && overlay.anchored
    onTriggered: overlay._positionTick++
  }

  function openAt(x, y) {
    anchorItem = null
    menuX = x; menuY = y;
    // Delay clamp after layout to ensure panel.width/height are up to date
    open = true
    _ignoreFirstClick = true
    console.log("RightClickMenu.openAt request:", x, y, "overlay wh:", overlay.width, overlay.height)
    Qt.callLater(function(){
      panel.x = Math.max(0, Math.min(menuX, overlay.width - panel.width))
      panel.y = Math.max(0, Math.min(menuY, overlay.height - panel.height))
      console.log("RightClickMenu.clamped:", panel.x, panel.y, "panel wh:", panel.width, panel.height)
    })
  }

  function openAtAnchor(item, localX, localY) {
    try {
      anchorItem = item
      anchorLocalX = localX
      anchorLocalY = localY
      _ignoreFirstClick = true
      open = true
      // Nudge mapping once immediate
      overlay._positionTick++
    } catch (e) {
      console.log("RightClickMenu.openAtAnchor failed:", e)
      openAt(0, 0)
    }
  }

  Component.onCompleted: console.log("RightClickMenu created. overlay wh:", overlay.width, overlay.height)
  onVisibleChanged: console.log("RightClickMenu overlay visible:", visible, "open:", open)
  
  function close() {
    open = false
    // Keep overlay visible during fade-out animation
    closeTimer.start()
  }
  
  // Delay cleanup until fade animation completes
  Timer {
    id: closeTimer
    interval: 150 // Match panel opacity animation duration
    onTriggered: {
      anchorItem = null
    }
  }

  // Click-away catcher: ignore the first release that opened the menu
  MouseArea {
    anchors.fill: parent
    visible: overlay.open
    enabled: visible
    acceptedButtons: Qt.AllButtons
    propagateComposedEvents: false
    z: 0
    onClicked: function(mouse) {
      console.log("RightClickMenu: overlay clicked, _ignoreFirstClick:", overlay._ignoreFirstClick)
      if (overlay._ignoreFirstClick) { 
        overlay._ignoreFirstClick = false
        mouse.accepted = true
        return
      }
      overlay.close()
      mouse.accepted = true
    }
  }

  Rectangle {
    id: panel
    // If anchored, continuously map the anchor's local point to overlay coordinates
    x: overlay.anchored
       ? (function(){ overlay._positionTick; var p = overlay.anchorItem ? overlay.anchorItem.mapToItem(overlay, overlay.anchorLocalX, overlay.anchorLocalY) : { x: overlay.menuX }; return Math.round(p.x) })()
       : Math.round(overlay.menuX)
    y: overlay.anchored
       ? (function(){ overlay._positionTick; var p = overlay.anchorItem ? overlay.anchorItem.mapToItem(overlay, overlay.anchorLocalX, overlay.anchorLocalY) : { y: overlay.menuY }; return Math.round(p.y) })()
       : Math.round(overlay.menuY)
    visible: overlay.open || opacity > 0.01
    opacity: overlay.open ? 1.0 : 0.0
    radius: 10
    // Slightly grayish surface for better contrast vs background
    color: Palette.isDarkMode()
           ? Qt.lighter(Palette.palette().surfaceVariant, 1.08)
           : Qt.darker(Palette.palette().surfaceVariant, 1.06)
    clip: true
    border.width: 0
    antialiasing: true
    z: 1
    // Track widest row for robust sizing, like HamburgerMenu
    property int maxRowWidth: 0
      // Hover fill tuned to be distinct from panel color
      // Use alpha overlay for clear hover contrast
      property color hoverFillColor: Palette.isDarkMode()
                                     ? Qt.rgba(1, 1, 1, 0.08)
                                     : Qt.rgba(0, 0, 0, 0.08)
    // Centralized hover state
    property int hoverIndex: -1
    property real hoverY: 0
    property real hoverH: 0
    property bool hoverIsFirst: false
    property bool hoverIsLast: false
    property bool hoverVisible: panelHoverCatcher.containsMouse && hoverIndex >= 0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    // Track mouse presence over the panel; no click handling
    MouseArea {
      id: panelHoverCatcher
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      // Clear hover only when pointer leaves the panel entirely to avoid row-to-row flicker
      onExited: {
        panel.hoverIndex = -1
        panel.hoverH = 0
      }
    }


    // Single hover rectangle to avoid per-row stacking artifacts
    Rectangle {
      id: hoverRect
      z: 0
      x: 0
      width: panel.width
      y: contentCol.y + panel.hoverY - (panel.hoverIsFirst ? panel.radius : 0)
      height: Math.max(0, panel.hoverH + (panel.hoverIsFirst ? panel.radius : 0) + (panel.hoverIsLast ? panel.radius : 0))
      radius: (panel.hoverIsFirst || panel.hoverIsLast) ? panel.radius : 6
      color: panel.hoverFillColor
      opacity: panel.hoverVisible ? 1.0 : 0.0
      Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
      Behavior on height { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
      Behavior on opacity { NumberAnimation { duration: 70; easing.type: Easing.OutQuad } }
    }

    Column {
      id: contentCol
      anchors.margins: 0
      spacing: 0
      Component.onCompleted: console.log("RightClickMenu content created")
      Repeater {
        id: rep
        model: overlay.items || []
        delegate: Item {
          id: row
          property var itemData: modelData
          property bool hovered: false
          property bool hasComponent: !!(itemData && itemData.component)
          // Row positioning helpers
          property int idx: index
          property bool isFirst: idx === 0
          property bool isLast: idx === (rep.count - 1)
          onItemDataChanged: { if (itemData && itemData.enabled === false) hovered = false }

          // Measurement: prefer custom component implicit size when present
          implicitWidth: hasComponent && loader.item ? (loader.item.implicitWidth + 16)
                                                    : Math.max(overlay.minWidth, (txt.implicitWidth + 28))
          implicitHeight: hasComponent && loader.item ? Math.max(28, loader.item.implicitHeight + 8)
                                                      : 34
          width: panel.width
          height: implicitHeight

          // Hover background handled by panel-level hoverRect

          // Text fallback
          Text {
            id: txt
            visible: !row.hasComponent
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: (itemData && itemData.label) ? itemData.label : ""
            color: Palette.palette().onSurface
            font.pixelSize: 14
            opacity: (itemData && itemData.enabled === false) ? 0.38 : 1.0
          }

          // Custom component support
          Loader {
            id: loader
            visible: row.hasComponent
            anchors.fill: parent
            sourceComponent: row.hasComponent ? itemData.component : null
            onLoaded: { try { panel.maxRowWidth = Math.max(panel.maxRowWidth, row.implicitWidth) } catch (e) {} }
          }

          // Update panel's max width from this row
          Component.onCompleted: panel.maxRowWidth = Math.max(panel.maxRowWidth, row.implicitWidth)
          onImplicitWidthChanged: panel.maxRowWidth = Math.max(panel.maxRowWidth, row.implicitWidth)

          // Interaction for simple rows
          MouseArea {
            anchors.fill: parent
            visible: !row.hasComponent
            hoverEnabled: row.itemData && row.itemData.enabled !== false
            onEntered: {
              if (row.itemData && row.itemData.enabled !== false) {
                row.hovered = true
                panel.hoverIndex = index
                panel.hoverY = row.y
                panel.hoverH = row.height
                panel.hoverIsFirst = (index === 0)
                panel.hoverIsLast = (index === (rep.count - 1))
              }
            }
            onExited: {
              row.hovered = false
              // Do not clear hover when moving between rows; only clear when the pointer leaves the panel
              if (!panelHoverCatcher.containsMouse) {
                panel.hoverIndex = -1
                panel.hoverH = 0
              }
            }
            onClicked: {
              if (row.itemData && row.itemData.enabled === false) return
              try { if (row.itemData && row.itemData.onTriggered) row.itemData.onTriggered() } catch(e) {}
              overlay.close()
            }
          }
        }
      }
    }

    // size to contents (respect children like HamburgerMenu)
    width: Math.max(overlay.minWidth, panel.maxRowWidth)
    height: contentCol.implicitHeight
    onWidthChanged: console.log("RightClickMenu panel width:", width)
    onHeightChanged: console.log("RightClickMenu panel height:", height)
  }
}


