import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Hyprland as Hypr
import "../../resources/colors.js" as Palette
import "../../resources/components/typography" as Type
import "../../resources/components/navigation" as Nav
import "../../resources/components/system" as SystemComp
import "../../resources/components/layout" as UILayout

// Top-anchored Wayland layer-shell panel compatible with Hyprland
PanelWindow {
  id: barWin
  color: "transparent"
  visible: true
  // Size the panel to its content height
  implicitHeight: rootRect.implicitHeight
  focusable: false
  anchors { left: true; right: true; top: true; bottom: false }
  margins { left: 0; right: 0; top: 0; bottom: 0 }
  // Reserve space equal to content implicit height
  exclusiveZone: implicitHeight // reserve space so windows don't overlap the bar
  WlrLayershell.layer: WlrLayer.Top

  // Ensure Hyprland workspace data is available on startup
  Component.onCompleted: {
    if (Hypr && Hypr.Hyprland && Hypr.Hyprland.refreshWorkspaces) {
      Hypr.Hyprland.refreshWorkspaces()
    }
  }

  Rectangle {
    id: rootRect
    anchors.fill: parent
    color: Palette.palette().surface
    // Vertical padding around content
    property int verticalPadding: 4
    // Size to content
    implicitHeight: Math.max(22, Math.max(leftArea.height, centerBox.implicitHeight, trayPill.implicitHeight) + verticalPadding * 2)
    // bottom divider line
    Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Palette.palette().outline; opacity: 0.24 }

    // No Column/anchors conflict; we position direct children via anchors

    // Left: Active app icon + title for current workspace
    Row {
      id: leftArea
      anchors.left: parent.left
      anchors.leftMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      height: Math.max(appIcon.height, appTitle.implicitHeight)
      spacing: 8

      // Simple letter avatar as an icon placeholder
      Item {
        id: appIcon
        width: 18; height: 18
        Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: Palette.palette().surfaceVariant
        }
        Text {
          anchors.centerIn: parent
          color: Palette.palette().onSurface
          font.pixelSize: 11
          text: (Hypr.Hyprland.activeToplevel && Hypr.Hyprland.activeToplevel.title && Hypr.Hyprland.activeToplevel.title.length > 0)
                  ? Hypr.Hyprland.activeToplevel.title.charAt(0).toUpperCase()
                  : "·"
        }
      }
      Type.Label {
        id: appTitle
        text: Hypr.Hyprland.activeToplevel && Hypr.Hyprland.activeToplevel.title
                ? Hypr.Hyprland.activeToplevel.title
                : "Desktop"
        color: Palette.palette().onSurface
        pixelSize: 13
        elide: Text.ElideRight
        maxLines: 1
        verticalAlignment: Text.AlignVCenter
      }
    }

    // Center: Pill with real Hyprland workspaces and a simple clock next to it
    Item {
      id: centerBox
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: leftArea.right
      anchors.right: trayPill.left
      anchors.leftMargin: 8
      anchors.rightMargin: 8
      implicitHeight: pill.implicitHeight
      implicitWidth: pill.implicitWidth

          UILayout.PillContainer {
        id: pill
            anchors.centerIn: parent
            // Adopt implicit size when not managed by a Layout
            width: implicitWidth
            height: implicitHeight
            padding: 4

        Row {
          id: pillRow
          spacing: 10

          // Workspaces using our IndexSwitcher, synced with Hyprland
          Nav.IndexSwitcher {
            id: wsSwitch
            // Ensure the switcher takes up its implicit size inside a Row
            width: implicitWidth
            height: implicitHeight
            itemHeight: 18
            itemWidth: 24
            spacing: 6
            // Show at least 1 item so the control is visible even before Hyprland reports workspaces
            count: Math.max(1, Hypr.Hyprland.workspaces ? (Hypr.Hyprland.workspaces.count || 0) : 0)
            currentIndex: rootRect.focusedWorkspaceIndex()
            onActivated: function(index){
              // Prefer dispatcher for reliable switching; assumes numeric workspaces
              if (Hypr && Hypr.Hyprland && typeof index === 'number') {
                Hypr.Hyprland.dispatch('workspace ' + (index + 1))
              }
            }
          }

          // Simple time label next to workspaces
          Type.Label {
            id: timeLabel
            text: Qt.formatTime(new Date(), "HH:mm")
            pixelSize: 12
            color: Palette.palette().onSurfaceVariant
            verticalAlignment: Text.AlignVCenter
          }
          Timer { id: timeTimer; interval: 1000 * 15; running: true; repeat: true; onTriggered: timeLabel.text = Qt.formatTime(new Date(), "HH:mm") }
        }
      }
    }

    // Right: system tray in a pill container
    UILayout.PillContainer {
      id: trayPill
      anchors.right: parent.right
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      padding: 4

      SystemComp.SystemTrayView {
        id: tray
        anchors.centerIn: parent
        parentWindow: barWin
        iconSize: 18
        height: iconSize + 2
      }
    }

    // Helper to compute current focused workspace index
    function focusedWorkspaceIndex() {
      var m = Hypr.Hyprland.workspaces
      if (!m || typeof m.count !== 'number' || m.count <= 0) return 0
      var fw = Hypr.Hyprland.focusedWorkspace
      for (var i = 0; i < m.count; ++i) {
        var ws = m.get ? m.get(i) : null
        if (!ws) continue
        if (ws === fw || ws.focused === true || ws.active === true) return i
      }
      return 0
    }
  }
}


