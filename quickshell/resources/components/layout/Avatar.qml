import QtQuick 2.15
import ".." as Components

Item {
  id: root
  // Size of the circular avatar in pixels
  property int size: 36
  // Optional image URL (local path or data URL). If empty, fallback to initials
  property url source: ""
  // Initials to show when no image provided
  property string initials: ""
  // Background color for initials avatar
  property color backgroundColor: Components.ColorPalette.surfaceVariant
  // Foreground color for initials text
  property color foregroundColor: Components.ColorPalette.onSurface

  implicitWidth: size
  implicitHeight: size

  // Circular container that clips children (no extra modules required)
  Rectangle {
    id: circle
    anchors.fill: parent
    radius: width / 2
    color: backgroundColor
    antialiasing: true
    clip: true
    layer.enabled: true
    layer.smooth: true

    // Image fills and is clipped to the circle
    Image {
      anchors.fill: parent
      visible: root.source !== "" && status === Image.Ready
      source: root.source
      fillMode: Image.PreserveAspectCrop
      smooth: true
      asynchronous: false
      onStatusChanged: {
        if (status === Image.Error) {
          visible = false
        }
      }
    }

    // Initials fallback when no image
    Text {
      anchors.centerIn: parent
      visible: root.source === ""
      color: foregroundColor
      text: root.initials
      font.pixelSize: Math.max(12, Math.round(root.size * 0.42))
      font.bold: true
    }
  }
  
}


