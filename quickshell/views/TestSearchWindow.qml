import QtQuick 2.15
import Quickshell
import "../resources/colors.js" as Palette
import "../resources/components/search" as SearchComp
import "../resources/components/layout" as Layout
import "../resources/components/typography" as Type

FloatingWindow {
  id: win
  title: "Search Test"
  visible: true
  implicitWidth: 640
  implicitHeight: 420

  // Behavior: overlay | filter
  property string searchBehavior: "filter"

  Rectangle { anchors.fill: parent; color: Palette.palette().background }

  // Settings tiles demo content
  property var allItems: [
    { title: "Network & Internet", subtitle: "Wi‑Fi, VPN, Data usage", iconSource: "../resources/icons/wifi.svg" },
    { title: "Bluetooth & Devices", subtitle: "Pair new devices, inputs", iconSource: "../resources/icons/bluetooth.svg" },
    { title: "Display", subtitle: "Brightness, Night light, Scale", iconSource: "../resources/icons/home.svg" },
    { title: "Sound", subtitle: "Volume, Output, Input", iconSource: "../resources/icons/home.svg" },
    { title: "Notifications", subtitle: "Do Not Disturb, App notifications", iconSource: "../resources/icons/person.svg" },
    { title: "Personalization", subtitle: "Wallpaper, Colors, Themes", iconSource: "../resources/icons/search.svg" },
    { title: "Privacy & Security", subtitle: "Permissions, Location", iconSource: "../resources/icons/person.svg" },
    { title: "System", subtitle: "About, Updates, Power", iconSource: "../resources/icons/home.svg" }
  ]
  // Live filter text; when empty, all items are shown
  property string filterText: ""

  function _matches(item, q) {
    if (!q || q.length === 0) return true
    var s = String(q).toLowerCase()
    return String(item.title).toLowerCase().indexOf(s) !== -1 || String(item.subtitle).toLowerCase().indexOf(s) !== -1
  }
  function computeGroupRole(i) {
    var vis = []
    for (var k = 0; k < allItems.length; k++) {
      if (_matches(allItems[k], filterText)) vis.push(k)
    }
    var pos = vis.indexOf(i)
    if (pos === -1) return "middle"
    if (vis.length === 1) return "single"
    if (pos === 0) return "top"
    if (pos === vis.length - 1) return "bottom"
    return "middle"
  }

  Column {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 10

    // Pill search field
    SearchComp.Search {
      id: search
      placeholderText: "Search settings"
      rightActions: [ { iconName: "microphone", onTriggered: function() { console.log("voice")} } ]
      anchors.horizontalCenter: parent.horizontalCenter
      onActivated: {
        if (win.searchBehavior === "overlay") {
          // Open overlay without manipulating focus to avoid recursion
          overlay.open = true
        }
      }
      onTextChanged: if (win.searchBehavior === "filter") win.filterText = String(search.text || "")
      onSubmitted: function(txt) { if (win.searchBehavior === "overlay") overlay.open = true }
      onCleared: function(){ if (win.searchBehavior === "filter") win.filteredItems = win.allItems }
    }

    // Results container under the search box
    // Use the same container style as previews (Layout.Container with border off)
    Layout.Container {
      id: resultsBox
      fillParent: false
      padding: 8
      borderWidth: 0
      cornerRadius: 12
      anchors.left: parent.left
      anchors.right: parent.right
      height: Math.min(parent.height - search.height - 40, resultsTitle.implicitHeight + 16 + resultsBox.padding * 2 + resultsList.contentHeight)
      visible: win.searchBehavior === "filter"
      Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
      // Content
      Type.Label { id: resultsTitle; text: "Results"; color: Palette.palette().onSurfaceVariant; pixelSize: 12; anchors.top: parent.top; anchors.left: parent.left; topMargin: 0; bottomMargin: 4 }
      ListView {
        id: resultsList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: resultsTitle.bottom
        height: Math.max(64, contentHeight)
        spacing: 1
        clip: true
        interactive: false
        model: win.allItems
        delegate: Item {
          width: resultsList.width
          // Smooth show/hide via height collapse and fade
          property bool shown: win._matches(modelData, win.filterText)
          height: shown ? tile.implicitHeight : 0
          Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
          clip: true
          Layout.SettingsTile {
            id: tile
            anchors.left: parent.left
            anchors.right: parent.right
            opacity: parent.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
            title: modelData.title
            subtitle: modelData.subtitle
            iconSource: modelData.iconSource || ""
            groupRole: win.computeGroupRole(index)
            onClicked: console.log("Open settings:", title)
          }
        }
      }
    }
  }

  // Overlay mode (optional): keep for completeness but hidden by default
  Item { id: overlay; visible: false; property bool open: false }
}


