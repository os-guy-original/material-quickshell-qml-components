import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/typography" as Type
import "../resources/components/layout" as UILayout
import "../resources/components/inputs" as Inputs
import "../resources/components/actions" as Actions

FloatingWindow {
  id: w
  title: "Settings Test"
  visible: true
  implicitWidth: 600
  implicitHeight: 420

  Rectangle { anchors.fill: parent; color: Components.ColorPalette.background }

  UILayout.Container {
    anchors.fill: parent
    padding: 8
    ColumnLayout {
      spacing: 0

      Type.Label { text: "Settings"; pixelSize: 18; color: Components.ColorPalette.onSurface }

      UILayout.SettingsTile {
        title: "Notifications"
        subtitle: "Enable alerts"
        groupRole: "top"
        clickable: false
        padding: 12
        Inputs.Switch {}
      }
      UILayout.SettingsTile {
        title: "Dark mode"
        subtitle: "Toggle theme"
        groupRole: "middle"
        clickable: false
        padding: 12
        Inputs.Switch { onToggled: function(){ Components.ColorPalette.toggleDarkMode() } }
      }
      UILayout.SettingsTile {
        title: "Account"
        subtitle: "Change password"
        groupRole: "bottom"
        clickable: true
        padding: 12
        onClicked: console.log("Change password")
      }

      RowLayout { spacing: 8
        Actions.Button { text: "Close"; onClicked: w.visible = false }
      }
    }
  }
}


