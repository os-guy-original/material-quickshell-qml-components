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
    spacing: 10

    Typography.Label { text: "Profile"; pixelSize: 16; color: Palette.palette().onSurface }

    RowLayout {
      spacing: 8
      Typography.Label { text: "Notifications" }
      Inputs.Switch {
        checked: sharedState ? sharedState.enableNotifications : false
        onToggled: function(state){ if (sharedState) sharedState.enableNotifications = state }
      }
    }

    Typography.Label {
      text: "Wi‑Fi: " + ((sharedState && sharedState.wifiEnabled) ? "On" : "Off")
      color: Palette.palette().onSurfaceVariant
    }
    Typography.Label {
      text: "Bluetooth: " + ((sharedState && sharedState.bluetoothEnabled) ? "On" : "Off")
      color: Palette.palette().onSurfaceVariant
    }
  }
}


