import QtQuick 2.15
import "../../colors.js" as Palette

Item {
  id: root
  property string text: ""
  property color color: Palette.palette().onSurface
  property int pixelSize: 14
  // Set a sensible default UI font; 'Sans Serif' maps to the platform's default sans font
  property string fontFamily: "Sans Serif"
  property int fontWeight: Font.Normal
  property bool bold: false
  property bool italic: false
  property bool underline: false
  property bool strikeout: false
  property int capitalization: Font.MixedCase
  property real letterSpacing: 0
  property int maxLines: 0 // 0 = unlimited
  property int wrapMode: Text.NoWrap
  property int elide: Text.ElideRight
  // Baseline support so this label can be baseline-anchored in layouts
  property real baselineOffset: topMargin + textItem.baselineOffset
  // Outer margins that this label reserves around itself
  property int leftMargin: 0
  property int rightMargin: 0
  property int topMargin: 0
  property int bottomMargin: 0
  // Horizontal alignment when given extra width by parent
  property int horizontalAlignment: Text.AlignLeft
  // Vertical alignment within its own height
  property int verticalAlignment: Text.AlignVCenter
  // When true, centers the content box and uses implicit sizes for natural centering in Rows/Columns
  property bool centerContent: false

  implicitWidth: textItem.implicitWidth + leftMargin + rightMargin
  implicitHeight: textItem.implicitHeight + topMargin + bottomMargin

  // Content area
    Item {
    id: content
    anchors.fill: parent
    anchors.leftMargin: leftMargin
    anchors.rightMargin: rightMargin
    anchors.topMargin: topMargin
    anchors.bottomMargin: bottomMargin
    clip: false

    Text {
      id: textItem
      anchors.fill: parent
      anchors.horizontalCenter: centerContent ? parent.horizontalCenter : undefined
      anchors.verticalCenter: centerContent ? parent.verticalCenter : undefined
      text: root.text
      color: root.color
      font.pixelSize: root.pixelSize
      font.family: root.fontFamily
      font.weight: root.bold ? Font.DemiBold : root.fontWeight
      font.italic: root.italic
      font.underline: root.underline
      font.strikeout: root.strikeout
      font.capitalization: root.capitalization
      font.letterSpacing: root.letterSpacing
      wrapMode: root.wrapMode
      elide: root.elide
      horizontalAlignment: root.horizontalAlignment
      verticalAlignment: root.verticalAlignment
      maximumLineCount: root.maxLines > 0 ? root.maxLines : 1000000
      // Respect parent width but keep intrinsic height for measurement
    }
  }
}


