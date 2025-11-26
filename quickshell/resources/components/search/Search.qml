import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Components
import "../icons" as Icon
import "../Menu/ContextMenuHelper.js" as Ctx

Item {
  id: root
  clip: true
  // Public API
  property string placeholderText: "Search"
  property alias text: input.text
  property bool active: false
  // Preferred fixed width for the pill; if not set, first implicitWidth is used to keep size stable
  // overlay | filter (consumer can choose)
  property string behavior: "overlay"
  // Optional avatar image on the far right
  property url avatarSource: ""
  // Right actions model: array of { iconName?, iconSource?, onTriggered?() }
  property var rightActions: []
  signal submitted(string text)
  signal activated()
  signal cleared()
  // Context menu API for search input
  property bool contextMenuEnabled: true
  // Internal instance holder for overlay
  property Item _contextMenu: null
  function _buildContextItems() {
    var hasSel = input.selectionStart !== input.selectionEnd
    return [
      { label: "Cut",  enabled: hasSel, onTriggered: function(){ try { input.cut() } catch(e){} } },
      { label: "Copy", enabled: hasSel, onTriggered: function(){ try { input.copy() } catch(e){} } },
      { label: "Paste", onTriggered: function(){ try { input.paste() } catch(e){} } },
      { label: "Select all", onTriggered: function(){ try { input.selectAll() } catch(e){} } }
    ]
  }
  function _openContextFrom(anchorItem, mouseX, mouseY) {
    if (!contextMenuEnabled) return
    Ctx.openMenu(root, anchorItem, mouseX, mouseY, _buildContextItems())
  }

  // Derived: whether user is actively searching (focus or non-empty)
  readonly property bool _searching: (root.active || input.activeFocus || input.length > 0)
  // Capture initial width to prevent shrinking when the leading icon hides
  // Let implicitWidth follow content; no fixed width to avoid binding loops

  implicitHeight: 46
  implicitWidth: Math.max(240, contentRow.implicitWidth + 24)

  // Background that darkens slightly when active/focused
  readonly property color _baseBg: Components.ColorPalette.isDarkMode ? Qt.lighter(Components.ColorPalette.surfaceVariant, 1.03)
                                                       : Qt.darker(Components.ColorPalette.surfaceVariant, 1.02)
  readonly property color _activeBg: Components.ColorPalette.isDarkMode ? Qt.darker(Components.ColorPalette.surfaceVariant, 1.20)
                                                         : Qt.darker(Components.ColorPalette.primaryContainer, 1.18)
  Rectangle {
    id: background
    anchors.fill: parent
    radius: height / 2
    color: root._searching ? root._activeBg : root._baseBg
    // Show a subtle border only when not searching (placeholder state)
    border.width: root._searching ? 0 : 1
    border.color: Components.ColorPalette.outline
    Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
  }

  RowLayout {
    id: contentRow
    anchors.fill: parent
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.topMargin: 8
    anchors.bottomMargin: 8
    spacing: 8

    // Leading search icon with animated hide/show when searching starts/ends
    Item {
      id: lead
      height: 20
      Layout.alignment: Qt.AlignVCenter
      width: root._searching ? 0 : 20
      Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
      Icon.Icon {
        anchors.fill: parent
        name: "search"
        size: 20
        color: Components.ColorPalette.onSurfaceVariant
        opacity: root._searching ? 0 : 1
        scale: root._searching ? 0.8 : 1
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
      }
    }

    // Text input – contributes intrinsic width to the RowLayout
    Item {
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: implicitWidth
      height: 26
      // Let the RowLayout grow the pill to fit content: placeholder or typed width
      TextMetrics { id: _phMetrics; text: root.placeholderText; font.pixelSize: 14 }
      implicitWidth: Math.max(80, Math.max(_phMetrics.width, input.contentWidth))
      // Use shared base text input for consistent selection behavior
      TextInput {
        id: input
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: Math.max(20, font.pixelSize + 4)
        font.pixelSize: 14
        color: Components.ColorPalette.onSurface
        selectionColor: Qt.darker(Components.ColorPalette.primary, 1.8)
        selectByMouse: true
        mouseSelectionMode: TextInput.SelectCharacters
        clip: true
        focus: false
        onAccepted: root.submitted(text)
        onActiveFocusChanged: if (activeFocus) { root.active = true; root.activated() }
        Keys.onEscapePressed: {
          if (text.length > 0) { text = ""; root.cleared() }
          else { root.active = false; focus = false }
        }
      }
      // Right click menu over input area
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true
        onPressed: function(e){ if (e.button === Qt.RightButton) { _openContextFrom(parent, e.x, e.y); e.accepted = true } }
      }
      // Placeholder (centered inside this input item; item width already sized to content)
      Text {
        text: root.placeholderText
        color: Components.ColorPalette.onSurfaceVariant
        visible: input.length === 0 && !input.activeFocus
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 4
        elide: Text.ElideRight
        font.pixelSize: 14
      }
    }

    // Spacer keeps right actions at the end when the icon collapses, but does not consume space needed by input
    Item { Layout.fillWidth: true; Layout.preferredWidth: 0; height: 1 }

    // Dynamic right actions
    Repeater {
      id: actionRep
      model: Array.isArray(root.rightActions) ? root.rightActions : []
      delegate: Item { width: 24; height: 24; Layout.alignment: Qt.AlignVCenter
        Icon.Icon {
          anchors.fill: parent
          visible: !!(modelData && typeof modelData.iconName === 'string' && modelData.iconName.length > 0)
          name: (modelData && typeof modelData.iconName === 'string') ? modelData.iconName : ""
          size: 20
          color: Components.ColorPalette.onSurface
        }
        Image {
          anchors.fill: parent
          visible: !!(modelData && typeof modelData.iconSource === 'string' && (!modelData.iconName || modelData.iconName.length === 0) && modelData.iconSource.length > 0)
          source: (modelData && typeof modelData.iconSource === 'string') ? modelData.iconSource : ""
          fillMode: Image.PreserveAspectFit
          smooth: true
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { try { if (modelData && modelData.onTriggered) modelData.onTriggered(root.text) } catch(e) {} } }
      }
    }

    // Optional avatar at far right
    Item { width: 28; height: 28; Layout.alignment: Qt.AlignVCenter; visible: (typeof root.avatarSource === 'string') && root.avatarSource.length > 0
      Rectangle { anchors.fill: parent; radius: width/2; color: "transparent"; border.width: 0 }
      Image { anchors.fill: parent; source: root.avatarSource; fillMode: Image.PreserveAspectCrop; smooth: true; cache: true; clip: true }
    }
  }

  // Clear with Escape
  Keys.onEscapePressed: {
    if (input.length > 0) { input.clear(); root.cleared() }
    else root.active = false
  }

  function focusInput() { input.forceActiveFocus() }

  // Make the whole pill focus the input without swallowing the click for children
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.IBeamCursor
    acceptedButtons: Qt.LeftButton
    propagateComposedEvents: true
    onPressed: function(mouse){ root.active = true; input.forceActiveFocus(); mouse.accepted = false }
  }

}


