import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../resources/components" as Components
import "../../resources/components/typography" as Typography
import "../../resources/components/inputs" as Inputs

Item {
  id: root
  property var sharedState
  width: parent ? parent.width : 800
  height: 480

  ColumnLayout {
    anchors.fill: parent
    spacing: 12

    Typography.Label { text: "Connectivity"; pixelSize: 16; color: Components.ColorPalette.onSurface }

    RowLayout {
      spacing: 8
      Typography.Label { text: "Wi‑Fi" }
      Inputs.Switch {
        checked: sharedState ? sharedState.wifiEnabled : false
        onToggled: function(state){ if (sharedState) sharedState.wifiEnabled = state }
      }
      Item { Layout.fillWidth: true }
      Typography.Label {
        text: (sharedState && sharedState.wifiEnabled) ? "On" : "Off"
        color: Components.ColorPalette.onSurfaceVariant
      }
    }

    RowLayout {
      spacing: 8
      Typography.Label { text: "Bluetooth" }
      Inputs.Switch {
        checked: sharedState ? sharedState.bluetoothEnabled : false
        onToggled: function(state){ if (sharedState) sharedState.bluetoothEnabled = state }
      }
      Item { Layout.fillWidth: true }
      Typography.Label {
        text: (sharedState && sharedState.bluetoothEnabled) ? "On" : "Off"
        color: Components.ColorPalette.onSurfaceVariant
      }
    }

    Typography.Label {
      text: "These toggles are shared across tabs."
      color: Components.ColorPalette.onSurfaceVariant
      wrapMode: Text.Wrap
      Layout.fillWidth: true
    }
  }
}



