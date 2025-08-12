import QtQuick 2.15
import "../../colors.js" as Palette

Item {
  id: root
  // Orientation of the divider line
  // "horizontal" draws a horizontal rule; "vertical" draws a vertical rule
  property string orientation: "horizontal"
  // Color of the divider line
  property color lineColor: Palette.palette().outline
  // Thickness in pixels (device pixels)
  property real thickness: 1
  // Insets from the start/end edges (start=end left/right for horizontal; top/bottom for vertical)
  property int insetStart: 0
  property int insetEnd: 0
  // Overall opacity applied to the line
  property real lineOpacity: 0.9

  implicitWidth: orientation === "vertical" ? thickness : 0
  implicitHeight: orientation === "horizontal" ? thickness : 0

  Rectangle {
    anchors {
      left: orientation === "horizontal" ? parent.left : undefined
      right: orientation === "horizontal" ? parent.right : undefined
      top: orientation === "vertical" ? parent.top : undefined
      bottom: orientation === "vertical" ? parent.bottom : undefined
      leftMargin: orientation === "horizontal" ? insetStart : 0
      rightMargin: orientation === "horizontal" ? insetEnd : 0
      topMargin: orientation === "vertical" ? insetStart : 0
      bottomMargin: orientation === "vertical" ? insetEnd : 0
    }
    width: orientation === "vertical" ? thickness : undefined
    height: orientation === "horizontal" ? thickness : undefined
    color: lineColor
    opacity: lineOpacity
    radius: thickness >= 2 ? thickness / 2 : 0
  }
}


