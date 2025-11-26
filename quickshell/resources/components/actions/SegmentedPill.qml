import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Components

Item {
  id: root
  property var options: ["Songs", "Albums", "Podcasts"]
  property int currentIndex: 0
  property bool enabled: true
  property bool showCheckmark: true
  property int segmentHeight: 32
  property int segmentHPadding: 14
  property int cornerRadius: Math.round(height / 2)
  signal changed(int index)

  implicitHeight: Math.max(segmentHeight, contentRow.implicitHeight + 4)
  implicitWidth: contentRow.implicitWidth + 8

  // Outer pill background
  Rectangle {
    anchors.fill: parent
    radius: root.cornerRadius
    color: Components.ColorPalette.surfaceVariant
    border.width: 1
    border.color: Components.ColorPalette.outline
  }

  RowLayout {
    id: contentRow
    anchors.fill: parent
    anchors.margins: 2
    spacing: 0

    Repeater {
      id: rep
      model: Array.isArray(root.options) ? root.options.length : 0
      delegate: Item {
        id: seg
        Layout.fillWidth: true
        Layout.preferredWidth: Math.max(60, textItem.implicitWidth + (root.showCheckmark ? 28 : 0) + root.segmentHPadding * 2)
        height: root.segmentHeight
        property bool selected: index === root.currentIndex

        // Unselected background (reversed visual): subtle fill when NOT selected
        Canvas {
          id: unselBg
          anchors.fill: parent
          opacity: seg.selected ? 0 : 1
          onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var w = width, h = height
            var rAll = Math.round(root.height / 2) - 2
            var rInner = 3
            var tl = (index === 0) ? rAll : rInner
            var bl = (index === 0) ? rAll : rInner
            var tr = (index === rep.count - 1) ? rAll : rInner
            var br = (index === rep.count - 1) ? rAll : rInner
            function rr(tl, tr, br, bl){
              ctx.beginPath()
              ctx.moveTo(tl, 0)
              ctx.lineTo(w - tr, 0)
              ctx.arcTo(w, 0, w, tr, tr)
              ctx.lineTo(w, h - br)
              ctx.arcTo(w, h, w - br, h, br)
              ctx.lineTo(bl, h)
              ctx.arcTo(0, h, 0, h - bl, bl)
              ctx.lineTo(0, tl)
              ctx.arcTo(0, 0, tl, 0, tl)
              ctx.closePath()
            }
            // Use the previous selected fill as the UNSELECTED base per request
            var base = Components.ColorPalette.surface
            var fill = Qt.lighter(base, 1.1)
            ctx.fillStyle = fill
            rr(tl, tr, br, bl)
            ctx.fill()
          }
          Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }

        // Selected background (transparent to show outer pill), keep minimal rounding inside
        Canvas {
          id: selBg
          anchors.fill: parent
          opacity: seg.selected ? 1 : 0
          onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var w = width, h = height
            var rAll = Math.round(root.height / 2) - 2
            var rInner = 3
            var tl = (index === 0) ? rAll : rInner
            var bl = (index === 0) ? rAll : rInner
            var tr = (index === rep.count - 1) ? rAll : rInner
            var br = (index === rep.count - 1) ? rAll : rInner
            function rr(tl, tr, br, bl){
              ctx.beginPath()
              ctx.moveTo(tl, 0)
              ctx.lineTo(w - tr, 0)
              ctx.arcTo(w, 0, w, tr, tr)
              ctx.lineTo(w, h - br)
              ctx.arcTo(w, h, w - br, h, br)
              ctx.lineTo(bl, h)
              ctx.arcTo(0, h, 0, h - bl, bl)
              ctx.lineTo(0, tl)
              ctx.arcTo(0, 0, tl, 0, tl)
              ctx.closePath()
            }
            // Selected fill: matches active chip color
            ctx.fillStyle = Components.ColorPalette.primaryContainer
            rr(tl, tr, br, bl)
            ctx.fill()
            // Transparent fill: no fill, only subtle inner stroke for definition
            ctx.globalAlpha = 0.12
            ctx.strokeStyle = Components.ColorPalette.outline
            ctx.lineWidth = 1
            ctx.stroke()
            ctx.globalAlpha = 1.0
          }
          Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }

        // Separator between segments
        Rectangle {
          visible: index > 0
          width: 1
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          color: Components.ColorPalette.outline
          opacity: 0.5
        }

        // Content: center text when not selected; show leading tick when selected
        Item {
          id: content
          anchors.fill: parent
          anchors.leftMargin: root.segmentHPadding
          anchors.rightMargin: root.segmentHPadding

          // Checkmark
          Canvas {
            id: tick
            visible: root.showCheckmark && seg.selected
            width: 14; height: 14
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onPaint: {
              var ctx = getContext('2d'); ctx.reset();
              ctx.strokeStyle = Components.ColorPalette.onSurface;
              ctx.lineWidth = 2; ctx.lineCap = 'round';
              ctx.beginPath();
              ctx.moveTo(2, 7);
              ctx.lineTo(5.5, 11);
              ctx.lineTo(12, 3.5);
              ctx.stroke();
            }
            Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
          }

          Text {
            id: textItem
            text: Array.isArray(root.options) ? String(root.options[index]) : ""
            color: Components.ColorPalette.onSurface
            font.pixelSize: 14
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
          }

          // States to toggle anchoring for perfect centering when unselected
          states: [
            State {
              name: "selected"
              when: seg.selected
              PropertyChanges { target: textItem; anchors.left: tick.right; anchors.leftMargin: 8; anchors.horizontalCenter: undefined; anchors.verticalCenter: content.verticalCenter }
            },
            State {
              name: "unselected"
              when: !seg.selected
              PropertyChanges { target: textItem; anchors.left: undefined; anchors.leftMargin: 0; anchors.horizontalCenter: content.horizontalCenter; anchors.verticalCenter: content.verticalCenter }
            }
          ]
        }

        MouseArea {
          anchors.fill: parent
          enabled: root.enabled
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.currentIndex === index) return
            root.currentIndex = index
            root.changed(index)
          }
        }

        onSelectedChanged: selBg.requestPaint()
        Connections { target: root; function onCurrentIndexChanged() { selBg.requestPaint() } }
      }
    }
  }
}


