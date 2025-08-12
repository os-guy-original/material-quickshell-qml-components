import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../resources/colors.js" as Palette
import "../../resources/components/inputs" as Inputs
import "../../resources/components/typography" as Typography

Item {
  id: root
  property var sharedState
  width: parent ? parent.width : 800
  height: 480

  ColumnLayout {
    anchors.fill: parent
    spacing: 10

    Typography.Label { text: "Search"; pixelSize: 16; color: Palette.palette().onSurface }
    Inputs.UnderlineTextField {
      placeholderText: "Type to search"
      text: sharedState ? sharedState.searchQuery : ""
      onAccepted: function(t) { if (sharedState) sharedState.searchQuery = t }
      Layout.fillWidth: true
    }
    Typography.Label {
      text: "Current query: " + (sharedState ? sharedState.searchQuery : "")
      color: Palette.palette().onSurfaceVariant
      wrapMode: Text.Wrap
      Layout.fillWidth: true
    }
  }
}


