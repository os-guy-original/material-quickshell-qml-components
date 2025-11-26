import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/layout" as LayoutComponents

FloatingWindow {
  id: window
  title: "Media Card Test"
  visible: true
  width: 400
  height: 600
  
  Rectangle {
    anchors.fill: parent
    color: Components.ColorPalette.background
    
    Flickable {
      anchors.fill: parent
      anchors.margins: 20
      contentHeight: column.height
      clip: true
      
      Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(400, parent.width)
        spacing: 20
        
        // Example 1: Card with image, title, subtitle, and button
        LayoutComponents.MediaCard {
          anchors.horizontalCenter: parent.horizontalCenter
          imageSource: "file:///usr/share/pixmaps/archlinux-logo.png"
          title: "Glass Souls' World Tour"
          subtitle: "From your recent favorites"
          buttonText: "Buy tickets"
          
          onButtonClicked: console.log("Button clicked!")
          onCardClicked: console.log("Card clicked!")
        }
        
        // Example 2: Card without image
        LayoutComponents.MediaCard {
          anchors.horizontalCenter: parent.horizontalCenter
          title: "Simple Card"
          subtitle: "This card has no image"
          buttonText: "Action"
          imageHeight: 0
        }
        
        // Example 3: Card with custom styling
        LayoutComponents.MediaCard {
          anchors.horizontalCenter: parent.horizontalCenter
          imageSource: "file:///usr/share/pixmaps/archlinux-logo.png"
          title: "Custom Styled Card"
          subtitle: "With different colors"
          buttonText: "Learn more"
          cornerRadius: 24
          imageHeight: 150
        }
      }
    }
  }
}
