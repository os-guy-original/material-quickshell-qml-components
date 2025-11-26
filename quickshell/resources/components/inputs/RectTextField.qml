import QtQuick 2.15
import "../../colors.js" as Palette
import "."
import "../Menu/ContextMenuHelper.js" as Ctx

Item {
  id: root

  // API mirrors TextField for easy swap
  property alias text: input.text
  property string placeholderText: ""
  property bool useFloatingLabel: true
  property string labelText: ""
  property real labelFontSize: 14
  property real floatingFontSize: 12
  property bool floating: input.activeFocus || input.text.length > 0
  property bool enabled: true
  property bool filled: false
  property bool error: false
  // Context menu API
  property bool contextMenuEnabled: true
  // Internal instance holder for overlay
  property Item _contextMenu: null
  function _buildContextItems() { return Ctx.defaultTextInputItems(input) }
  function _openContextFrom(anchorItem, mouseX, mouseY) {
    if (!contextMenuEnabled) { console.log("RectTF ctx: disabled"); return }
    var items = _buildContextItems()
    Ctx.openMenu(root, anchorItem, mouseX, mouseY, items)
  }
  signal accepted(string text)

  // Rectangular styling
  property real rectRadius: 8
  property real borderWidth: 1.2

  // Visual height of the field box (excludes helper/error text)
  property int fieldHeight: 44
  implicitWidth: 240
  // Reserve space for helper/error text to avoid overlap with following content
  implicitHeight: fieldHeight + ((root.error && errorLabel.text.length > 0) ? (errorLabel.implicitHeight + 4) : 0)

  Rectangle {
    id: background
    z: 0
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: root.fieldHeight
    radius: rectRadius
    color: filled ? Palette.palette().surfaceVariant : Palette.palette().surface
    border.width: borderWidth
    border.color: error ? Palette.palette().error
                         : (input.activeFocus ? Palette.palette().primary
                                               : (Palette.palette().isDarkMode ? Qt.lighter(Palette.palette().outline, 1.3) : Qt.darker(Palette.palette().outline, 1.3)))
    opacity: enabled ? 1.0 : 0.38
    Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
  }

  // Clip text/selection to field bounds
  Item {
    id: inputClip
    z: 2
    anchors.fill: background
    anchors.leftMargin: 14
    anchors.rightMargin: 14
    anchors.topMargin: 1
    anchors.bottomMargin: 1
    clip: true

    TextInput {
      id: input
      anchors.fill: parent
      verticalAlignment: Text.AlignVCenter
      color: error ? Palette.palette().error : Palette.palette().onSurface
      selectionColor: Qt.darker(Palette.palette().primary, 1.8)
      selectByMouse: true
      mouseSelectionMode: TextInput.SelectCharacters
      cursorVisible: activeFocus
      font.pixelSize: 14
      enabled: root.enabled
      onAccepted: root.accepted(text)
    }
  }

  // Floating label + notch (rectangular notch)
  Item {
    id: labelLayer
    anchors.fill: parent
    visible: useFloatingLabel && !filled
    clip: false
    // keep under TextInput so text selection highlight stays on top
    z: 1

    Rectangle {
      id: notchEraser
      visible: true
      color: background.color
      height: floatingLabel.height
      width: root.floating ? (floatingLabel.paintedWidth + 12) : 0
      radius: Math.max(0, rectRadius - 1)
      x: floatingLabel.x - 6
      y: -borderWidth
      Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
      Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    // Hidden measurement label; overlay draws the visible label
    Text {
      id: floatingLabel
      visible: false
      text: (root.labelText && root.labelText.length) ? root.labelText : root.placeholderText
      color: root.error ? Palette.palette().error
                        : (input.activeFocus ? Palette.palette().primary : Palette.palette().onSurfaceVariant)
      x: 12
      y: root.floating ? -height / 2 - 1 : (background.height - height) / 2
      font.pixelSize: root.floating ? floatingFontSize : labelFontSize
      elide: Text.ElideRight
      z: 3
      Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
      Behavior on font.pixelSize { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }
  }

  // Visible floating label overlay (above input)
  Text {
    id: floatingLabelOverlay
    visible: useFloatingLabel && !filled
    text: (root.labelText && root.labelText.length) ? root.labelText : root.placeholderText
    color: root.error ? Palette.palette().error
                      : (input.activeFocus ? Palette.palette().primary : Palette.palette().onSurfaceVariant)
    x: 12
    y: root.floating ? -height / 2 - 1 : (background.height - height) / 2
    font.pixelSize: root.floating ? floatingFontSize : labelFontSize
    elide: Text.ElideRight
    z: 3
    Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    Behavior on font.pixelSize { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
  }

  // Left click focus layer (below input)
  MouseArea {
    anchors.fill: background
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true
    cursorShape: Qt.IBeamCursor
    propagateComposedEvents: true
    onPressed: function(mouse) { input.forceActiveFocus(); mouse.accepted = false }
  }
  // Right click catcher layer (above input)
  MouseArea {
    anchors.fill: background
    z: 100
    acceptedButtons: Qt.RightButton
    cursorShape: Qt.IBeamCursor
    onPressed: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        input.forceActiveFocus()
        try {
          var pt = mapToItem(input, mouse.x, mouse.y)
          if (input.selectionStart === input.selectionEnd) {
            input.cursorPosition = input.positionAt(pt.x, pt.y)
          }
        } catch (e) {}
        console.log("RectTF RMB: pressed at", mouse.x, mouse.y)
        _openContextFrom(background, mouse.x, mouse.y)
        mouse.accepted = true
      }
    }
  }

  // Helper text slot (error)
  property alias errorText: errorLabel.text
  Text {
    id: errorLabel
    anchors.top: background.bottom
    anchors.left: parent.left
    anchors.topMargin: 4
    color: Palette.palette().error
    font.pixelSize: 12
    visible: root.error && text.length > 0
    text: ""
  }
}


