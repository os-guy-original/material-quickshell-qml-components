import QtQuick 2.15
import QtQml 2.15
import Qt5Compat.GraphicalEffects
import ".." as Components
import "../icons" as Icon
import "../feedback" as Feedback

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
  property color accent: Components.ColorPalette.primary
  signal triggered()
  // Rounded square radius when compact
  property int cornerRadiusSquare: Math.max(8, Math.round(diameter * 0.22))

  z: 1200
  width: menuOpen ? diameter : (isExtended ? Math.max(diameter, txt.implicitWidth + diameter - 20 + 28) : diameter)
  height: diameter
  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  // Track pressed state for shadow
  property bool _pressed: false

  // Shadow source rectangle (behind everything)
  Rectangle {
    id: shadowSource
    anchors.fill: parent
    radius: menuOpen ? (height / 2) : cornerRadiusSquare
    color: Components.ColorPalette.surface
    visible: false
    Behavior on radius { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  }

  // Shadow effect
  DropShadow {
    anchors.fill: shadowSource
    source: shadowSource
    horizontalOffset: 0
    verticalOffset: root._pressed ? 6 : 4
    radius: root._pressed ? 18 : 12
    samples: 25
    color: Qt.rgba(0, 0, 0, root._pressed ? 0.35 : 0.25)
    spread: 0
    Behavior on verticalOffset { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.OutCubic } }
  }

  // Background shape with ripple
  Item {
    id: bgShape
    anchors.fill: parent
    layer.enabled: true
    layer.smooth: true
    layer.effect: OpacityMask {
      maskSource: Item {
        width: bgShape.width
        height: bgShape.height
        Rectangle {
          anchors.fill: parent
          radius: menuOpen ? (height / 2) : cornerRadiusSquare
          smooth: true
          Behavior on radius { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }
      }
    }
    
    Rectangle {
      id: bg
      anchors.fill: parent
      color: menuOpen ? Components.ColorPalette.primary : Components.ColorPalette.onPrimary
      Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
    
    Feedback.RippleEffect {
      id: rippleEffect
      rippleColor: menuOpen ? Components.ColorPalette.onPrimary : Qt.rgba(0.95, 0.95, 0.95, 1)
    }
  }

  // Icon/plus morph to X when menuOpen
  Item {
    id: glyph
    width: diameter * 0.35
    height: width
    anchors.left: parent.left
    anchors.leftMargin: Math.round((root.height - height) / 2)
    anchors.verticalCenter: parent.verticalCenter
    // Two bars form a plus; rotate to make an X when menuOpen
    Rectangle {
      id: bar1
      anchors.centerIn: parent
      width: parent.width
      height: 2
      radius: 1
      color: menuOpen ? Components.ColorPalette.onPrimary : Qt.rgba(0.95, 0.95, 0.95, 1)
      rotation: menuOpen ? 45 : 0
      Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
    Rectangle {
      id: bar2
      anchors.centerIn: parent
      width: parent.width
      height: 2
      radius: 1
      color: menuOpen ? Components.ColorPalette.onPrimary : Qt.rgba(0.95, 0.95, 0.95, 1)
      rotation: menuOpen ? -45 : 90
      Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }
  }

  // Extended label text with negative-erase animation
  Item {
    id: textContainer
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: glyph.right
    anchors.leftMargin: 10
    anchors.right: parent.right
    anchors.rightMargin: 14
    height: txt.height
    clip: true
    visible: root.isExtended
    
    Text {
      id: txt
      text: root.text
      color: Qt.rgba(0.95, 0.95, 0.95, 1)
      font.pixelSize: 14
      x: root.isExtended ? 0 : txt.implicitWidth
      Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }
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
        Item {
          id: menuItemContainer
          anchors.fill: parent
          layer.enabled: true
          layer.smooth: true
          layer.effect: OpacityMask {
            maskSource: Item {
              width: menuItemContainer.width
              height: menuItemContainer.height
              Rectangle {
                anchors.fill: parent
                radius: height / 2
                smooth: true
              }
            }
          }
          
          Rectangle {
            anchors.fill: parent
            color: Components.ColorPalette.onPrimary
          }
          
          Feedback.RippleEffect {
            id: menuItemRipple
            rippleColor: Qt.rgba(0.95, 0.95, 0.95, 1)
          }
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
          Icon.Icon { anchors.fill: parent; name: modelData && modelData.icon ? modelData.icon : ""; color: Qt.rgba(0.95, 0.95, 0.95, 1); size: parent.width }
        }
        Text {
          id: lbl
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: iconBox.visible ? iconBox.right : parent.left
          anchors.leftMargin: 12
          text: (modelData && modelData.label) ? modelData.label : ""
          color: Qt.rgba(0.95, 0.95, 0.95, 1)
          font.pixelSize: 14
          font.italic: false
          font.weight: Font.Medium
        }
        MouseArea {
          id: menuItemMouseArea
          anchors.fill: parent
          hoverEnabled: true
          onPressed: menuItemRipple.startHold(mouseX, mouseY)
          onReleased: menuItemRipple.endHold()
          onCanceled: menuItemRipple.endHold()
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
    id: mainMouseArea
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onPressed: { root._pressed = true; rippleEffect.startHold(mouseX, mouseY) }
    onReleased: { root._pressed = false; rippleEffect.endHold() }
    onCanceled: { root._pressed = false; rippleEffect.endHold() }
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


