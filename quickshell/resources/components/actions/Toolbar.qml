import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import ".." as Components
import "../icons" as Icon
import "../feedback" as Feedback

/*
  Toolbar Button
  - FAB-style button that expands to show action buttons
  - Main button shrinks when toolbar is open
  - Actions area appears as separate pill to the left
  - Action buttons have no background (icon-only)
*/

Item {
  id: root
  property var actions: []
  property bool open: false
  property string orientation: "left" // "left", "right", "up", "down"
  property color backgroundColor: Components.ColorPalette.surfaceVariant
  property color iconColor: Components.ColorPalette.onSurfaceVariant
  property int buttonSize: 56
  property int buttonSizeOpen: 44
  property int actionsPillSize: 52
  property int cornerRadiusSquare: Math.max(8, Math.round(buttonSize * 0.22))
  
  readonly property bool isHorizontal: orientation === "left" || orientation === "right"
  readonly property int actionsCount: actions.length
  readonly property real fullActionsSize: isHorizontal ? ((actionsCount * 40) + ((actionsCount - 1) * 4) + 16) : ((actionsCount * 40) + ((actionsCount - 1) * 4) + 16)
  
  width: isHorizontal ? (open ? (fullActionsSize + buttonSizeOpen + 8) : buttonSize) : buttonSize
  height: isHorizontal ? buttonSize : (open ? (fullActionsSize + buttonSizeOpen + 8) : buttonSize)
  
  Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  
  // Actions pill (squashes/stretches based on orientation)
  Rectangle {
    id: actionsContainer
    
    // Positioning based on orientation
    anchors.right: orientation === "left" ? mainButton.left : undefined
    anchors.left: orientation === "right" ? mainButton.right : undefined
    anchors.bottom: orientation === "up" ? mainButton.top : undefined
    anchors.top: orientation === "down" ? mainButton.bottom : undefined
    anchors.horizontalCenter: !isHorizontal ? parent.horizontalCenter : undefined
    anchors.verticalCenter: isHorizontal ? parent.verticalCenter : undefined
    
    anchors.rightMargin: orientation === "left" ? 8 : 0
    anchors.leftMargin: orientation === "right" ? 8 : 0
    anchors.bottomMargin: orientation === "up" ? 8 : 0
    anchors.topMargin: orientation === "down" ? 8 : 0
    
    width: isHorizontal ? fullActionsSize : actionsPillSize
    height: isHorizontal ? actionsPillSize : fullActionsSize
    radius: Math.min(width, height) / 2
    color: Components.ColorPalette.onPrimary
    
    transformOrigin: orientation === "left" ? Item.Right : (orientation === "right" ? Item.Left : (orientation === "up" ? Item.Bottom : Item.Top))
    scale: root.open ? 1.0 : 0.0
    opacity: root.open ? 1.0 : 0.0
    
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    
    Row {
      id: actionsLayout
      visible: isHorizontal
      anchors.right: orientation === "left" ? parent.right : undefined
      anchors.left: orientation === "right" ? parent.left : undefined
      anchors.rightMargin: orientation === "left" ? 8 : 0
      anchors.leftMargin: orientation === "right" ? 8 : 0
      anchors.verticalCenter: parent.verticalCenter
      spacing: 4
      
      Repeater {
        model: root.actions
        delegate: Item {
          width: 40
          height: 40
          
          Icon.Icon {
            anchors.centerIn: parent
            name: modelData.icon || ""
            color: Qt.rgba(0.95, 0.95, 0.95, 1)
            size: 20
          }
          
          Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: Qt.rgba(0.95, 0.95, 0.95, 1)
            opacity: actionMouseArea.pressed ? 0.12 : (actionMouseArea.containsMouse ? 0.08 : 0.0)
            Behavior on opacity { NumberAnimation { duration: 100 } }
          }
          
          MouseArea {
            id: actionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (modelData.onTriggered) {
                modelData.onTriggered()
              }
              root.open = false
            }
          }
        }
      }
    }
    
    Column {
      visible: !isHorizontal
      anchors.bottom: orientation === "up" ? parent.bottom : undefined
      anchors.top: orientation === "down" ? parent.top : undefined
      anchors.bottomMargin: orientation === "up" ? 8 : 0
      anchors.topMargin: orientation === "down" ? 8 : 0
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4
      
      Repeater {
        model: root.actions
        delegate: Item {
          width: 40
          height: 40
          
          Icon.Icon {
            anchors.centerIn: parent
            name: modelData.icon || ""
            color: Qt.rgba(0.95, 0.95, 0.95, 1)
            size: 20
          }
          
          Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: Qt.rgba(0.95, 0.95, 0.95, 1)
            opacity: actionMouseArea.pressed ? 0.12 : (actionMouseArea.containsMouse ? 0.08 : 0.0)
            Behavior on opacity { NumberAnimation { duration: 100 } }
          }
          
          MouseArea {
            id: actionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (modelData.onTriggered) {
                modelData.onTriggered()
              }
              root.open = false
            }
          }
        }
      }
    }
  }
  
  // Main FAB-style button
  Item {
    id: mainButton
    anchors.right: orientation === "left" ? parent.right : undefined
    anchors.left: orientation === "right" ? parent.left : undefined
    anchors.bottom: orientation === "up" ? parent.bottom : undefined
    anchors.top: orientation === "down" ? parent.top : undefined
    anchors.verticalCenter: isHorizontal ? parent.verticalCenter : undefined
    anchors.horizontalCenter: !isHorizontal ? parent.horizontalCenter : undefined
    width: root.open ? root.buttonSizeOpen : root.buttonSize
    height: root.open ? root.buttonSizeOpen : root.buttonSize
    
    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    
    Item {
      id: buttonBackground
      anchors.fill: parent
      layer.enabled: true
      layer.smooth: true
      layer.effect: OpacityMask {
        maskSource: Item {
          width: buttonBackground.width
          height: buttonBackground.height
          Rectangle {
            anchors.fill: parent
            radius: cornerRadiusSquare
            smooth: true
          }
        }
      }
      
      Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
      }
      
      Feedback.RippleEffect {
        id: mainRipple
        rippleColor: Components.ColorPalette.onSurfaceVariant
      }
    }
    
    // Plus icon that rotates to X
    Item {
      anchors.centerIn: parent
      width: 24
      height: 24
      
      Rectangle {
        id: plusBar1
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: 2
        radius: 1
        color: root.iconColor
        rotation: root.open ? 45 : 0
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      }
      
      Rectangle {
        id: plusBar2
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: 2
        radius: 1
        color: root.iconColor
        rotation: root.open ? -45 : 90
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      }
    }
    
    MouseArea {
      id: mainMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onPressed: mainRipple.startHold(mouseX, mouseY)
      onReleased: mainRipple.endHold()
      onCanceled: mainRipple.endHold()
      onClicked: root.open = !root.open
    }
  }
}
