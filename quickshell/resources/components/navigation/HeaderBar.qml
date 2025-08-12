import QtQuick 2.15
import "../../colors.js" as Palette

// Minimal transparent header with a title and an optional close button
Item {
    id: root
    property string title: "Title"
    // "left" or "center"
    property string titleAlignment: "center"
    property bool closeVisible: true
    property int padding: 12
    property int heightPx: 44
    signal closeRequested()

    implicitHeight: heightPx
    implicitWidth: Math.max(titleText.implicitWidth + padding * 2 + (closeVisible ? closeBtn.width + padding : 0), 160)

    // Title text (no background; header is transparent)
    Text {
        id: titleText
        text: root.title
        color: Palette.palette().onSurface
        font.pixelSize: 16
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: closeBtn.left
        anchors.leftMargin: padding
        anchors.rightMargin: padding
        horizontalAlignment: root.titleAlignment === "center" ? Text.AlignHCenter : Text.AlignLeft
    }

    // Close button at right
    Item {
        id: closeBtn
        width: 28; height: 28
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: padding
        visible: root.closeVisible

        Rectangle {
            id: hoverBg
            anchors.fill: parent
            radius: height / 2
            color: Palette.palette().onSurface
            opacity: mouse.containsMouse ? 0.08 : 0.0
            Behavior on opacity { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
        }
        Canvas {
            anchors.centerIn: parent
            width: 14; height: 14
            onPaint: {
                var ctx = getContext('2d'); ctx.reset();
                ctx.strokeStyle = Palette.palette().onSurface; ctx.lineWidth = 2;
                ctx.beginPath(); ctx.moveTo(2,2); ctx.lineTo(12,12); ctx.moveTo(12,2); ctx.lineTo(2,12); ctx.stroke();
            }
        }
        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.closeRequested() }
    }
}


