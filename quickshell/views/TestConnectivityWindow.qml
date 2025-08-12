import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import "../resources/colors.js" as Palette
import "../resources/components/typography" as Type
import "../resources/components/inputs" as Inputs
import "../resources/components/layout" as UILayout

FloatingWindow {
  id: w
  title: "Connectivity Test"
  visible: true
  implicitWidth: 520
  implicitHeight: 320

  Rectangle { anchors.fill: parent; color: Palette.palette().background }

  UILayout.Container {
    anchors.fill: parent
    padding: 16

    ColumnLayout {
      spacing: 12
      Type.Label { text: "Connectivity"; pixelSize: 16; color: Palette.palette().onSurface }

      RowLayout {
        spacing: 8
        Type.Label { text: "Wi‑Fi" }
        Inputs.Switch { id: wifi }
        Item { Layout.fillWidth: true }
        Type.Label { text: wifi.checked ? "On" : "Off"; color: Palette.palette().onSurfaceVariant }
      }
      RowLayout {
        spacing: 8
        Type.Label { text: "Bluetooth" }
        Inputs.Switch { id: bt }
        Item { Layout.fillWidth: true }
        Type.Label { text: bt.checked ? "On" : "Off"; color: Palette.palette().onSurfaceVariant }
      }
    }
  }
}


