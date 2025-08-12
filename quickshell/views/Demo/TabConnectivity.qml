import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../resources/colors.js" as Palette
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

    Typography.Label { text: "Connectivity"; pixelSize: 16; color: Palette.palette().onSurface }

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
        color: Palette.palette().onSurfaceVariant
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
        color: Palette.palette().onSurfaceVariant
      }
    }

    Typography.Label {
      text: "These toggles are shared across tabs."
      color: Palette.palette().onSurfaceVariant
      wrapMode: Text.Wrap
      Layout.fillWidth: true
    }
  }
}



