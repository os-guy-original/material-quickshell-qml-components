import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../resources/components" as Components
import "../../resources/components/typography" as Typography
import "../../resources/components/actions" as Actions

Item {
  id: root
  property var sharedState
  width: parent ? parent.width : 800
  height: 480

  ColumnLayout {
    anchors.fill: parent
    spacing: 10

    Typography.Label { text: "Welcome Home"; pixelSize: 16; color: Components.ColorPalette.onSurface }
    Typography.Label { text: "Counter: " + (sharedState ? sharedState.counter : 0) }
    Actions.Button { text: "Increment"; onClicked: if (sharedState) sharedState.counter++ }

    Typography.Label {
      text: "Notifications: " + ((sharedState && sharedState.enableNotifications) ? "On" : "Off")
      color: Components.ColorPalette.onSurfaceVariant
    }
    Typography.Label {
      text: "Wi‑Fi: " + ((sharedState && sharedState.wifiEnabled) ? "On" : "Off")
      color: Components.ColorPalette.onSurfaceVariant
    }
    Typography.Label {
      text: "Bluetooth: " + ((sharedState && sharedState.bluetoothEnabled) ? "On" : "Off")
      color: Components.ColorPalette.onSurfaceVariant
    }
  }
}


