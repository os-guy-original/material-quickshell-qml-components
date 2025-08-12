import QtQuick 2.15
import QtQml 2.15
import "../../colors.js" as Palette
import "../icons" as Icon

/*
  Floating Action Button (FAB)
  - Primary floating button drawn above content (high z-order)
  - Supports a compact circular form and an extended (pill) form with label
  - Optional menu fan-out: on click, reveals pill action buttons above the FAB

  Properties:
    diameter: base circle size (default 56)
    text: label for extended pill
    extendedStatic: if true, always extended; otherwise can auto-extend on hover
    autoExtendOnHover: if true, hovering extends when text is present
    menuItems: array of { label, onTriggered?() }
    menuOpen: whether the fan-out menu is visible
    accent: base accent color for contained variant

  Behavior:
    - Clicking when menuItems.length > 0 toggles menuOpen (plus morphs into X)
    - Otherwise emits triggered()
*/

Item {
  id: root
  property int diameter: 56
  property string text: ""
  property bool extendedStatic: false
  property bool autoExtendOnHover: true
  property bool hovered: false
  // Do not extend when menu is open (close mode)
  readonly property bool isExtended: !menuOpen && (extendedStatic || (autoExtendOnHover && hovered && text.length > 0))
  property var menuItems: []
  property bool menuOpen: false
  property color accent: Palette.palette().primary
  signal triggered()
  // Rounded square radius when compact
  property int cornerRadiusSquare: Math.max(8, Math.round(diameter * 0.22))

  z: 1200
  width: menuOpen ? diameter : (isExtended ? Math.max(diameter, txt.implicitWidth + diameter - 20 + 28) : diameter)
  height: diameter
  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  // Background (rounded square normally, circular in close mode)
  Rectangle {
    id: bg
    anchors.fill: parent
    radius: menuOpen ? (height / 2) : cornerRadiusSquare
    color: menuOpen ? Palette.palette().secondaryContainer : accent
    border.width: 0
  }

  // Icon/plus morph to X when menuOpen
  Item {
    id: glyph
    width: diameter * 0.44
    height: width
    anchors.left: parent.left
    anchors.leftMargin: Math.round((root.height - height) / 2)
    anchors.verticalCenter: parent.verticalCenter
    // Two bars form a plus; rotate to make an X when menuOpen
    Rectangle {
      id: bar1
      anchors.centerIn: parent
      width: parent.width
      height: 2.2
      radius: 1
      color: menuOpen ? Palette.palette().onSecondaryContainer : Palette.palette().onPrimary
      rotation: menuOpen ? 45 : 0
      Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
    Rectangle {
      id: bar2
      anchors.centerIn: parent
      width: parent.width
      height: 2.2
      radius: 1
      color: menuOpen ? Palette.palette().onSecondaryContainer : Palette.palette().onPrimary
      rotation: menuOpen ? -45 : 90
      Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
  }

  // Extended label text
  Text {
    id: txt
    visible: root.isExtended
    text: root.text
    color: Palette.palette().onPrimary
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: glyph.right
    anchors.leftMargin: 10
    font.pixelSize: 14
    elide: Text.ElideRight
    opacity: root.isExtended ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  }

  // Menu fan-out: pill buttons above the FAB, right edges aligned with FAB right edge
  Column {
    id: fanout
    spacing: 10
    anchors.bottom: parent.top
    anchors.bottomMargin: fanout.spacing // gap equals inter-pill spacing
    width: root.width
    opacity: (Array.isArray(menuItems) && menuItems.length > 0) ? (menuOpen ? 1.0 : 0.0) : 0.0
    visible: opacity > 0.01
    // No transform; right alignment handled per row
    Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

    Repeater {
      id: rep
      model: Array.isArray(menuItems) ? menuItems : []
      delegate: Item {
        id: pillRow
        // Right-align to FAB's right edge
        x: root.width - width
        width: Math.max(root.diameter, (iconBox.visible ? iconBox.width + 8 : 0) + lbl.implicitWidth + 28)
        height: root.diameter
        opacity: fanout.opacity
        scale: menuOpen ? 1.0 : 0.96
        Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Rectangle {
          anchors.fill: parent
          radius: height / 2
          // Use primary container for vivid pills
          color: Palette.palette().primaryContainer
          border.width: 0
        }
        // Optional icon on the left if provided in model
        Item {
          id: iconBox
          visible: !!(modelData && modelData.icon)
          width: root.diameter * 0.44
          height: width
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 10
          Icon.Icon { anchors.fill: parent; name: modelData && modelData.icon ? modelData.icon : ""; color: Palette.palette().onPrimaryContainer; size: parent.width }
        }
        Text {
          id: lbl
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: iconBox.visible ? iconBox.right : parent.left
          anchors.leftMargin: 12
          text: (modelData && modelData.label) ? modelData.label : ""
          color: Palette.palette().onPrimaryContainer
          font.pixelSize: 14
          font.italic: false
          font.weight: Font.Medium
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            console.log("FAB action clicked:", (modelData && modelData.label) ? modelData.label : "<no label>")
            try { if (modelData && modelData.onTriggered) modelData.onTriggered() } catch (e) {}
            root.menuOpen = false
          }
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: {
      var hasMenu = Array.isArray(root.menuItems) && root.menuItems.length > 0
      if (hasMenu) {
        console.log("FAB toggle menu:", !root.menuOpen)
        // In close mode, do not dispatch action beyond toggling
        root.menuOpen = !root.menuOpen
      } else {
        console.log("FAB triggered")
        root.triggered()
      }
    }
  }

  onMenuOpenChanged: console.log("FAB menuOpen:", menuOpen)
}


