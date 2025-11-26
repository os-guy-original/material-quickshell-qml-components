import QtQuick 2.15
import "../../colors.js" as Palette
import "../actions" as Actions
import "../icons" as Icons

Item {
  id: root
  property bool open: false
  property string heroIcon: "restart"  // Icon name
  property string heroLabel: "Restart System"
  property string text: "Would you like to reboot the system?"
  property string primaryText: "Restart"
  property string secondaryText: "Cancel"
  property bool dismissible: true
  property int padding: 24
  property int maxWidth: 560
  property bool _closing: false
  
  signal accepted()
  signal rejected()
  
  anchors.fill: parent
  visible: open || _closing
  z: 999
  
  Keys.onEscapePressed: if (dismissible) open = false
  
  onOpenChanged: {
    if (!open && !_closing) {
      _closing = true
      closeTimer.start()
    }
  }
  
  Timer {
    id: closeTimer
    interval: 250
    onTriggered: root._closing = false
  }
  
  // Scrim
  Rectangle {
    anchors.fill: parent
    color: Palette.palette().onSurface
    opacity: root.open ? 0.32 : 0.0
    
    Behavior on opacity { 
      NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } 
    }
    
    MouseArea {
      anchors.fill: parent
      enabled: root.open && root.dismissible
      onClicked: root.open = false
    }
  }
  
  // Dialog surface
  Rectangle {
    id: card
    width: Math.min(root.maxWidth, content.implicitWidth + root.padding * 2)
    height: content.implicitHeight + root.padding * 2
    radius: 28
    color: Palette.palette().surface
    anchors.centerIn: parent
    opacity: root.open ? 1.0 : 0.0
    scale: root.open ? 1.0 : 0.92
    
    Behavior on opacity { 
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic } 
    }
    Behavior on scale { 
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic } 
    }
    
    MouseArea {
      anchors.fill: parent
      onClicked: {} // Swallow clicks
    }
    
    Column {
      id: content
      anchors.centerIn: parent
      width: parent.width - root.padding * 2
      spacing: 16
      
      // Hero icon (Material Symbol)
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: getIconGlyph(root.heroIcon)
        font.family: "Material Symbols Outlined"
        font.pixelSize: 64
        color: Palette.palette().onSurface
        
        function getIconGlyph(iconName) {
          switch(iconName) {
            case "restart": return "\ue863"     // restart_alt
            case "power": return "\ue8ac"       // power_settings_new
            case "shutdown": return "\ue8ac"    // power_settings_new
            case "warning": return "\ue002"     // warning
            case "error": return "\ue000"       // error
            case "info": return "\ue88e"        // info
            case "check": return "\ue5ca"       // check_circle
            case "delete": return "\ue872"      // delete
            default: return "\ue88e"            // info as fallback
          }
        }
      }
      
      // Hero label
      Text {
        width: parent.width
        text: root.heroLabel
        font.pixelSize: 24
        font.weight: Font.Medium
        color: Palette.palette().onSurface
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
      }
      
      // Description text with indentation
      Text {
        width: parent.width
        text: "    " + root.text
        font.pixelSize: 14
        color: Palette.palette().onSurfaceVariant
        wrapMode: Text.Wrap
        lineHeight: 1.4
      }
      
      // Action buttons
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12
        topPadding: 8
        
        Actions.Button {
          text: root.secondaryText
          outlined: true
          visible: root.secondaryText !== ""
          onClicked: {
            root.rejected()
            root.open = false
          }
        }
        
        Actions.Button {
          text: root.primaryText
          onClicked: {
            root.accepted()
            root.open = false
          }
        }
      }
    }
  }
}
