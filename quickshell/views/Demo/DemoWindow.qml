import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Quickshell
import "."
import "../../resources/colors.js" as Palette
import "../../resources/components/layout" as UILayout
import "../../resources/components/typography" as Typography
import "../../resources/components/navigation" as Nav

// Demo window using project Container and tabbed content
FloatingWindow {
  id: win
  title: "Demo"
  visible: true
  implicitWidth: 900
  implicitHeight: 640

  Rectangle { anchors.fill: parent; color: Palette.palette().background }

  // Shared state across tabs (QtObject so bindings react to property changes)
  property QtObject sharedState: shared
  QtObject {
    id: shared
    property string searchQuery: ""
    property bool enableNotifications: false
    property int counter: 0
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
  }
  // Track current tab index for active state
  property int currentTabIndex: 0

  // Top-level container from our library
  UILayout.Container {
    id: container
    anchors.fill: parent
    fillParent: true
    outerMargin: 16
    padding: 16
    // reserve space for the bottom navigation when present
    contentBottomInset: bottomNav.height

    ColumnLayout {
      id: rootCol
      width: parent.width
      spacing: 12

      // Top bar with title
      RowLayout {
        Layout.fillWidth: true
        spacing: 12
        Typography.Label { text: "Demo"; pixelSize: 18; color: Palette.palette().onSurface }
        Item { Layout.fillWidth: true }
      }

      // Content area (fills remaining height)
      Loader {
        id: contentLoader
        Layout.fillWidth: true
        Layout.fillHeight: true
        onLoaded: {
          if (item && item.sharedState !== undefined) item.sharedState = win.sharedState
        }
      }

      // Initialize default tab after component is ready
      Component.onCompleted: win._setTab(0)
    }
  }

  // Bottom navigation bar like Android, full width of the window
  Rectangle {
    id: bottomNav
    color: Palette.palette().surface
    height: 64
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    border.width: 0
    // top divider
    Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; height: 1; color: Palette.palette().outline; opacity: 0.24 }

    RowLayout {
      anchors.fill: parent
      anchors.margins: 8
      spacing: 8
      Item { Layout.fillWidth: true }
      Nav.TabButton { label: "Home"; iconName: "home"; active: win.currentTabIndex === 0; onClicked: win._setTab(0) }
      Nav.TabButton { label: "Search"; iconName: "search"; active: win.currentTabIndex === 1; onClicked: win._setTab(1) }
      Nav.TabButton { label: "Profile"; iconName: "person"; active: win.currentTabIndex === 2; onClicked: win._setTab(2) }
      Nav.TabButton { label: "Connectivity"; iconName: "wifi"; active: win.currentTabIndex === 3; onClicked: win._setTab(3) }
      Item { Layout.fillWidth: true }
    }
  }

  function _setTab(idx) {
    var urls = ["TabHome.qml", "TabSearch.qml", "TabProfile.qml", "TabConnectivity.qml"]
    var url = urls[Math.max(0, Math.min(idx, urls.length - 1))]
    try {
      if (contentLoader.setSource) {
        contentLoader.setSource(url, { sharedState: win.sharedState })
      } else {
        contentLoader.source = url
      }
      win.currentTabIndex = idx
    } catch (e) {
      console.log("DemoWindow: failed to set tab", idx, e)
      contentLoader.source = url
    }
  }
}


