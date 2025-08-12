import QtQuick 2.15
import QtQml 2.15
import "../../colors.js" as Palette
import "./MenuRegistry.js" as MenuRegistry

/*
  Hamburger popup menu with open grow animation and nested submenus.
  Usage:
    HamburgerMenu {
      id: menu
      anchors.fill: parent // overlay that captures clicks outside
      items: [
        { label: "File", submenu: [ { label: "New" }, { label: "Open" } ] },
        { label: "Edit" }
      ]
    }
    menu.openAtItem(someItem)
*/
Item {
  id: overlayRoot
  anchors.fill: parent
  visible: overlayRoot.open || panel.opacity > 0.01 || Boolean(activeSubmenu)
  z: 999

  // Public API
  property bool open: false
  property var items: [] // Array of { label, enabled?, submenu?, onTriggered?() }
  property int menuX: 0
  property int menuY: 0
  // Minimum width for the panel; set to 0 to fully respect text width
  property int minWidth: 0
  onItemsChanged: {
    // Reset measurement cache when content changes
    try { panel.maxRowWidth = 0 } catch(e) {}
  }
  property bool isSubmenu: false
  property var parentRowItem: null // for submenus, reference to the row that spawned it
  property var parentMenu: null // for submenus, reference to parent menu instance
  signal closed()
  onClosed: {
    // Allow fade-out to complete before overlay hides entirely
    Qt.callLater(function(){ if (panel.opacity <= 0.01) overlayRoot.visible = false })
  }

  // Internal
  property Item activeSubmenu: null
  property Item activeRowItem: null
  property Item submenuOwnerRow: null
  // Animation/morph helpers for submenus
  property bool firstOpen: false
  // Pivot inside submenu panel to grow from (relative to panel coords)
  property real openPivotY: 0
  // Indicates that the active child submenu opens to the left of this menu
  property bool childOpensLeft: false
  // Whether THIS instance (when it is a submenu) should open to the left of its parent anchor
  property bool opensToLeft: false

  onFirstOpenChanged: {
    if (firstOpen && isSubmenu) {
      panel.submenuOpenScaleY = 0.01
      Qt.callLater(function(){ panel.submenuOpenScaleY = 1.0; overlayRoot.firstOpen = false })
    }
  }
  // Expose panel geometry in overlay coordinates for seam calculation from siblings
  property real panelTop: panel.y
  property real panelBottom: panel.y + panel.height

  function overlapLen(a1, a2, b1, b2) {
    var start = Math.max(a1, b1)
    var end = Math.min(a2, b2)
    return Math.max(0, end - start)
  }

  onActiveRowItemChanged: {
    if (activeRowItem && activeRowItem.itemData && activeRowItem.itemData.submenu) {
      openSubmenuForRow(activeRowItem)
    } else if (activeSubmenu) {
      try { activeSubmenu.close() } catch(e) {}
      activeSubmenu = null
      submenuOwnerRow = null
    }
  }

  function openAt(x, y) {
    menuX = x
    menuY = y
    open = true
    MenuRegistry.requestOpen(overlayRoot)
    console.log("HamburgerMenu: openAt", x, y)
  }
  function openAtItem(item) {
    if (!item || !item.mapToItem) { openAt(0, 0); return }
    var p = item.mapToItem(overlayRoot, 0, item.height)
    var ox = Math.round(p.x)
    var oy = Math.round(p.y)
    console.log("HamburgerMenu: openAtItem mapped to", ox, oy)
    openAt(ox, oy)
  }
  function close() {
    open = false
    if (activeSubmenu) {
      try { activeSubmenu.close() } catch (e) {}
      activeSubmenu = null
    }
    MenuRegistry.notifyClosed(overlayRoot)
    closed()
  }

  // Click-away catcher
  MouseArea {
    anchors.fill: parent
    visible: !overlayRoot.isSubmenu && overlayRoot.open
    enabled: visible
    hoverEnabled: true
    onClicked: overlayRoot.close()
    z: 0
  }

  // Menu panel
  Rectangle {
    id: panel
    // For submenus, adjust x to align right edge to anchor if opening left
    x: overlayRoot.isSubmenu && overlayRoot.opensToLeft ? (overlayRoot.menuX - width + 1) : overlayRoot.menuX
    // For main menus, if not enough space below, open upwards by shifting y; always clamp to viewport
    property bool openUpwards: !overlayRoot.isSubmenu && (overlayRoot.menuY + height > overlayRoot.height)
    y: overlayRoot.isSubmenu
       ? Math.max(0, Math.min(overlayRoot.menuY, overlayRoot.height - height))
       : (panel.openUpwards
            ? Math.max(0, overlayRoot.menuY - height)
            : Math.min(overlayRoot.menuY, overlayRoot.height - height))
    visible: overlayRoot.open || panel.opacity > 0.01
    opacity: overlayRoot.open ? 1.0 : 0.0
    scale: overlayRoot.isSubmenu ? 1.0 : (overlayRoot.open ? 1.0 : 0.92)
    transformOrigin: Item.TopLeft
    radius: 10
    // Match right-click menu contrast: slightly grayish panel
    color: Palette.isDarkMode()
           ? Qt.lighter(Palette.palette().surfaceVariant, 1.08)
           : Qt.darker(Palette.palette().surfaceVariant, 1.06)
    border.color: Palette.palette().outline
    border.width: 1
    antialiasing: true
    z: overlayRoot.isSubmenu ? 2 : 1

    // Custom transform to allow submenu to grow from a pivot (row center)
    property real submenuOpenScaleY: 1.0
    // Track widest row implicit width for proper panel sizing
    property int maxRowWidth: 0
    transform: [
      Scale {
        id: growFromPivot
        origin.x: 0
        origin.y: overlayRoot.isSubmenu ? overlayRoot.openPivotY : 0
        xScale: 1
        yScale: overlayRoot.isSubmenu ? panel.submenuOpenScaleY : 1
      }
    ]

    // Derived seam metrics for when two menus touch side-by-side
    // Values are relative to this panel's coordinate space
    // Right seam metrics: if THIS menu owns a submenu (regardless of being a submenu itself)
    property real rightSeamStart: (overlayRoot.activeSubmenu)
                                  ? Math.max(0, Math.max(panel.y, overlayRoot.activeSubmenu.panelTop) - panel.y)
                                  : 0
    property real rightSeamEnd: (overlayRoot.activeSubmenu)
                                ? Math.max(0, Math.min(panel.y + panel.height, overlayRoot.activeSubmenu.panelBottom) - panel.y)
                                : 0
    // Left seam metrics when THIS menu owns a submenu that opens to the left
    property real childLeftSeamStart: (overlayRoot.activeSubmenu && overlayRoot.childOpensLeft)
                                      ? Math.max(0, Math.max(panel.y, overlayRoot.activeSubmenu.panelTop) - panel.y)
                                      : 0
    property real childLeftSeamEnd: (overlayRoot.activeSubmenu && overlayRoot.childOpensLeft)
                                    ? Math.max(0, Math.min(panel.y + panel.height, overlayRoot.activeSubmenu.panelBottom) - panel.y)
                                    : 0
    property real leftSeamStart: (overlayRoot.isSubmenu && overlayRoot.parentMenu)
                                 ? Math.max(0, Math.max(panel.y, overlayRoot.parentMenu.panelTop) - panel.y)
                                 : 0
    property real leftSeamEnd: (overlayRoot.isSubmenu && overlayRoot.parentMenu)
                               ? Math.max(0, Math.min(panel.y + panel.height, overlayRoot.parentMenu.panelBottom) - panel.y)
                               : 0

    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    // Animate position for morphing an already-open submenu to a new row
    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on submenuOpenScaleY { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    Component.onCompleted: {
      if (overlayRoot.isSubmenu && overlayRoot.firstOpen) {
        panel.submenuOpenScaleY = 0.01
        Qt.callLater(function(){ panel.submenuOpenScaleY = 1.0; overlayRoot.firstOpen = false })
      }
    }

    // Single hover rect for stability across rows
    property int hoverIndex: -1
    property real hoverY: 0
    property real hoverH: 0
    property bool hoverIsFirst: false
    property bool hoverIsLast: false
    MouseArea { id: panelHoverCatcher; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
    Rectangle {
      id: hoverRect
      z: 0
      x: 0
      width: panel.width
      y: contentCol.y + panel.hoverY - (panel.hoverIsFirst ? panel.radius : 0)
      height: Math.max(0, panel.hoverH + (panel.hoverIsFirst ? panel.radius : 0) + (panel.hoverIsLast ? panel.radius : 0))
      radius: (panel.hoverIsFirst || panel.hoverIsLast) ? panel.radius : 6
      color: (Palette.isDarkMode() ? Qt.lighter(Palette.palette().surfaceVariant, 1.32)
                                    : Qt.darker(Palette.palette().surfaceVariant, 1.22))
      opacity: panelHoverCatcher.containsMouse ? 1.0 : 0.0
      Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
      Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    }

    Column {
      id: contentCol
      anchors.margins: 8
      anchors.fill: parent
      spacing: 2
      Repeater {
        id: rep
        model: overlayRoot.items || []
        delegate: Item {
          id: row
          // Respect label width (+ paddings and optional chevron)
          implicitWidth: (txt.implicitWidth + 32 + (modelData && modelData.submenu ? 16 : 0))
          // Fill visible width, but don't affect Column's implicitWidth
          width: panel.width - 16
          height: 32

          property var itemData: modelData
          property bool hovered: false

          // Per-row hover visuals handled by panel-level hoverRect

          // Label
          Text {
            id: txt
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: itemData && itemData.label ? itemData.label : ""
            color: Palette.palette().onSurface
            font.pixelSize: 14
            opacity: itemData && itemData.enabled === false ? 0.38 : 1.0
          }

          // Update panel's maxRowWidth whenever our implicit width might change
          Component.onCompleted: panel.maxRowWidth = Math.max(panel.maxRowWidth, implicitWidth)
          onImplicitWidthChanged: panel.maxRowWidth = Math.max(panel.maxRowWidth, implicitWidth)

          // Submenu chevron — direction reacts to layout prediction
          Text {
            visible: !!(itemData && itemData.submenu && itemData.submenu.length > 0)
            text: (overlayRoot.childOpensLeft ? "‹" : "›")
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            color: Palette.palette().onSurfaceVariant
            font.pixelSize: 16
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
              row.hovered = true
              // Track current hover row for seam and interactions
              overlayRoot.activeRowItem = row
              panel.hoverIndex = index
              panel.hoverY = row.y
              panel.hoverH = row.height
              panel.hoverIsFirst = (index === 0)
              panel.hoverIsLast = (index === rep.count - 1)
              if (row.itemData && row.itemData.submenu) {
                openSubmenuForRow(row)
              } else if (overlayRoot.activeSubmenu) {
                try { overlayRoot.activeSubmenu.close() } catch (e) {}
                overlayRoot.activeSubmenu = null
                overlayRoot.submenuOwnerRow = null
              }
            }
            onExited: {
              row.hovered = false
            }
            onClicked: {
              if (row.itemData && row.itemData.enabled === false) return
              if (row.itemData && row.itemData.submenu) {
                // Toggle submenu on click as well
                openSubmenuForRow(row)
              } else {
                if (row.itemData && row.itemData.onTriggered) {
                  try { row.itemData.onTriggered() } catch(e) {}
                }
                overlayRoot.close()
              }
            }
          }
        }
      }
    }

    // Size binds after content built — use measured max row width
    width: Math.max(overlayRoot.minWidth, panel.maxRowWidth + 16)
    height: contentCol.implicitHeight + 16

    // Seam hider across entire touching edge while submenu is open
    // On the side where child submenu is attached, remove only the overlapping border segment
    Rectangle {
      id: seamRight
      width: panel.border.width
      color: panel.color
      visible: overlayRoot.activeSubmenu !== null && !overlayRoot.childOpensLeft && (height > 0)
      anchors.right: parent.right
      y: panel.rightSeamStart
      height: Math.max(0, panel.rightSeamEnd - panel.rightSeamStart)
      z: 3
    }

    Rectangle {
      id: seamLeftForChild
      width: panel.border.width
      color: panel.color
      visible: overlayRoot.activeSubmenu !== null && overlayRoot.childOpensLeft && (height > 0)
      anchors.left: parent.left
      y: panel.childLeftSeamStart
      height: Math.max(0, panel.childLeftSeamEnd - panel.childLeftSeamStart)
      z: 3
    }

    // For submenu, hide the border on the side that touches the parent
    // If the submenu opens to the RIGHT of the parent, its LEFT border overlaps the parent's right border
    Rectangle {
      id: seamLeft
      width: panel.border.width
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu !== null && !overlayRoot.opensToLeft && (height > 0)
      anchors.left: parent.left
      y: panel.leftSeamStart
      height: Math.max(0, panel.leftSeamEnd - panel.leftSeamStart)
      z: 3
    }
    // If the submenu opens to the LEFT of the parent, its RIGHT border overlaps the parent's left border
    Rectangle {
      id: seamRightForSub
      width: panel.border.width
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu !== null && overlayRoot.opensToLeft && (height > 0)
      anchors.right: parent.right
      y: panel.leftSeamStart
      height: Math.max(0, panel.leftSeamEnd - panel.leftSeamStart)
      z: 3
    }

    // Rounded connectors so two menus appear attached with a curved elbow
    // Show a quarter-circle at the start/end of the seam if it is near a corner
    // Right edge connectors (when child opens to the right)
    Rectangle {
      // Top-right connector
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && !overlayRoot.childOpensLeft && (panel.rightSeamStart > 0) && (panel.rightSeamStart < panel.radius) && (panel.rightSeamStart > 0.5)
      anchors.right: parent.right
      y: panel.rightSeamStart - height
      z: 4
    }
    Rectangle {
      // Bottom-right connector
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && !overlayRoot.childOpensLeft && (panel.height - panel.rightSeamEnd > 0) && ((panel.height - panel.rightSeamEnd) < panel.radius) && ((panel.height - panel.rightSeamEnd) > 0.5)
      anchors.right: parent.right
      y: panel.rightSeamEnd
      z: 4
    }

    // Submenu connectors (edge that touches the parent)
    Rectangle {
      // Top-left connector (submenu opens to the RIGHT of parent)
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && !overlayRoot.opensToLeft && (panel.leftSeamStart > 0) && (panel.leftSeamStart < panel.radius) && (panel.leftSeamStart > 0.5)
      anchors.left: parent.left
      y: panel.leftSeamStart - height
      z: 4
    }
    Rectangle {
      // Bottom-left connector (submenu opens to the RIGHT of parent)
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && !overlayRoot.opensToLeft && (panel.height - panel.leftSeamEnd > 0) && ((panel.height - panel.leftSeamEnd) < panel.radius) && ((panel.height - panel.leftSeamEnd) > 0.5)
      anchors.left: parent.left
      y: panel.leftSeamEnd
      z: 4
    }
    // Right edge connectors when submenu opens to the LEFT of parent
    Rectangle {
      // Top-right connector
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && overlayRoot.opensToLeft && (panel.leftSeamStart > 0) && (panel.leftSeamStart < panel.radius) && (panel.leftSeamStart > 0.5)
      anchors.right: parent.right
      y: panel.leftSeamStart - height
      z: 4
    }
    Rectangle {
      // Bottom-right connector
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && overlayRoot.opensToLeft && (panel.height - panel.leftSeamEnd > 0) && ((panel.height - panel.leftSeamEnd) < panel.radius) && ((panel.height - panel.leftSeamEnd) > 0.5)
      anchors.right: parent.right
      y: panel.leftSeamEnd
      z: 4
    }

    // Parent-left connectors (when a child opens to the left of this menu)
    Rectangle {
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && overlayRoot.childOpensLeft && (panel.childLeftSeamStart > 0) && (panel.childLeftSeamStart < panel.radius) && (panel.childLeftSeamStart > 0.5)
      anchors.left: parent.left
      y: panel.childLeftSeamStart - height
      z: 4
    }
    Rectangle {
      width: panel.radius; height: panel.radius
      radius: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && overlayRoot.childOpensLeft && (panel.height - panel.childLeftSeamEnd > 0) && ((panel.height - panel.childLeftSeamEnd) < panel.radius) && ((panel.height - panel.childLeftSeamEnd) > 0.5)
      anchors.left: parent.left
      y: panel.childLeftSeamEnd
      z: 4
    }

    // Corner flatteners: if the seam meets the very top/bottom edge, corners should be sharp
    // and the border should not draw a rounded arc. We overlay a square in panel color to mask it.
    // Right side (for any menu that owns a submenu opening to the right)
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && !overlayRoot.childOpensLeft && (panel.rightSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.right: parent.right
      z: 5
    }
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && !overlayRoot.childOpensLeft && ((panel.height - panel.rightSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      z: 5
    }
    // Left side flatteners for parent when child opens left
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && overlayRoot.childOpensLeft && (panel.childLeftSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.left: parent.left
      z: 5
    }
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.activeSubmenu && overlayRoot.childOpensLeft && ((panel.height - panel.childLeftSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      z: 5
    }
    // Submenu panel (left/right side flatteners depending on orientation)
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && !overlayRoot.opensToLeft && (panel.leftSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.left: parent.left
      z: 5
    }
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && !overlayRoot.opensToLeft && ((panel.height - panel.leftSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      z: 5
    }
    // Right side flatteners when submenu opens to the left
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && overlayRoot.opensToLeft && (panel.leftSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.right: parent.right
      z: 5
    }
    Rectangle {
      width: panel.radius; height: panel.radius
      color: panel.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && overlayRoot.opensToLeft && ((panel.height - panel.leftSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      z: 5
    }

    // Restore horizontal border lines when corners are sharp (masked by corner flattener)
    // Right side — top and bottom edges near seam
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.activeSubmenu && !overlayRoot.childOpensLeft && (panel.rightSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.right: parent.right
      z: 6
    }
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.activeSubmenu && !overlayRoot.childOpensLeft && ((panel.height - panel.rightSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      z: 6
    }
    // Left side — top and bottom edges near seam when child opens left
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.activeSubmenu && overlayRoot.childOpensLeft && (panel.childLeftSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.left: parent.left
      z: 6
    }
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.activeSubmenu && overlayRoot.childOpensLeft && ((panel.height - panel.childLeftSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      z: 6
    }
    // Submenu — top and bottom edges near touching side
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && !overlayRoot.opensToLeft && (panel.leftSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.left: parent.left
      z: 6
    }
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && !overlayRoot.opensToLeft && ((panel.height - panel.leftSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      z: 6
    }
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && overlayRoot.opensToLeft && (panel.leftSeamStart <= 0.5)
      anchors.top: parent.top
      anchors.right: parent.right
      z: 6
    }
    Rectangle {
      height: panel.border.width
      width: panel.radius
      color: panel.border.color
      visible: overlayRoot.isSubmenu && overlayRoot.parentMenu && overlayRoot.opensToLeft && ((panel.height - panel.leftSeamEnd) <= 0.5)
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      z: 6
    }
  }

  // Helper to open submenu for a row
  function openSubmenuForRow(rowItem) {
    if (!rowItem || !rowItem.itemData || !rowItem.itemData.submenu) return
    // If submenu is already open for this row, do nothing
    if (overlayRoot.activeSubmenu && overlayRoot.submenuOwnerRow === rowItem) {
      return
    }
    // Predict opening side using a conservative min width; set opensToLeft for child
    var minWidth = 160
    var preferLeft = (panel.x + panel.width + minWidth + 8 > overlayRoot.width)
    overlayRoot.childOpensLeft = preferLeft
    // Compute anchor point: if opening left, anchor at left edge (+1), else right edge (-1)
    var localX = preferLeft ? 1 : (panel.width - 1)
    var pos = panel.mapToItem(overlayRoot, localX, rowItem.y + contentCol.y)
    if (overlayRoot.activeSubmenu) {
      try {
        overlayRoot.activeSubmenu.items = rowItem.itemData.submenu
        overlayRoot.activeSubmenu.openPivotY = Math.round((rowItem.height / 2) + 8)
        overlayRoot.activeSubmenu.opensToLeft = preferLeft
        overlayRoot.activeSubmenu.menuX = Math.round(pos.x)
        overlayRoot.activeSubmenu.menuY = Math.round(pos.y)
        overlayRoot.activeSubmenu.isSubmenu = true
        overlayRoot.activeSubmenu.parentRowItem = rowItem
        overlayRoot.activeSubmenu.parentMenu = overlayRoot
        overlayRoot.activeSubmenu.open = true
        // trigger subtle grow-from-center on morph as well
        overlayRoot.activeSubmenu.firstOpen = true
        overlayRoot.submenuOwnerRow = rowItem
      } catch (e) {
        console.log("Failed to morph submenu, recreating:", e)
        try { overlayRoot.activeSubmenu.close() } catch (e2) {}
      overlayRoot.activeSubmenu = null
      }
    }
    if (!overlayRoot.activeSubmenu) {
    var comp = Qt.createComponent(Qt.resolvedUrl("HamburgerMenu.qml"))
    function finishCreate() {
      var inst = comp.createObject(overlayRoot, {
        items: rowItem.itemData.submenu,
        menuX: Math.round(pos.x),
        menuY: Math.round(pos.y),
        open: true,
        isSubmenu: true,
          firstOpen: true,
          openPivotY: Math.round((rowItem.height / 2) + 8),
          opensToLeft: preferLeft,
        parentRowItem: rowItem,
        parentMenu: overlayRoot
      })
      overlayRoot.activeSubmenu = inst
      overlayRoot.submenuOwnerRow = rowItem
      inst.closed.connect(function(){ if (overlayRoot.activeSubmenu === inst) overlayRoot.activeSubmenu = null })
    }
    if (comp.status === Component.Ready) {
      finishCreate()
    } else if (comp.status === Component.Error) {
      console.log("Failed to load submenu:", comp.errorString())
    } else {
      comp.statusChanged.connect(function(){
        if (comp.status === Component.Ready) finishCreate()
        else if (comp.status === Component.Error) console.log("Failed to load submenu:", comp.errorString())
      })
      }
    }
  }
}


