import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../colors.js" as Palette
import "../actions" as Actions

Rectangle {
  id: root
  
  // Content properties
  property string imageSource: ""
  property string title: ""
  property string subtitle: ""
  property string buttonText: ""
  
  // Styling properties
  property real cornerRadius: 16
  property color backgroundColor: Palette.palette().surfaceContainer
  property color titleColor: Palette.palette().onSurface
  property color subtitleColor: Palette.palette().onSurfaceVariant
  
  // Layout properties
  property real imageHeight: 200
  property real contentPadding: 20
  property real spacing: 12
  
  // Signals
  signal buttonClicked()
  signal cardClicked()
  
  color: backgroundColor
  radius: cornerRadius
  
  width: 320
  implicitWidth: 320
  implicitHeight: column.implicitHeight
  
  clip: true
  
  ColumnLayout {
    id: column
    anchors.fill: parent
    spacing: 0
    
    // Image section
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: root.imageSource !== "" ? root.imageHeight : 0
      visible: root.imageSource !== ""
      color: "transparent"
      
      Image {
        id: cardImage
        anchors.fill: parent
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }
    }
    
    // Content section
    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: contentColumn.implicitHeight + root.contentPadding * 2
      
      ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: root.contentPadding
        spacing: root.spacing
        
        // Title
        Text {
          Layout.fillWidth: true
          text: root.title
          font.pixelSize: 24
          font.weight: Font.Medium
          color: root.titleColor
          wrapMode: Text.Wrap
          visible: root.title !== ""
        }
        
        // Subtitle
        Text {
          Layout.fillWidth: true
          text: root.subtitle
          font.pixelSize: 14
          color: root.subtitleColor
          wrapMode: Text.Wrap
          visible: root.subtitle !== ""
        }
        
        // Button
        Actions.Button {
          Layout.alignment: Qt.AlignLeft
          text: root.buttonText
          visible: root.buttonText !== ""
          onClicked: root.buttonClicked()
        }
      }
    }
  }
  
  // Card click area (behind content)
  MouseArea {
    anchors.fill: parent
    z: -1
    onClicked: root.cardClicked()
  }
}
