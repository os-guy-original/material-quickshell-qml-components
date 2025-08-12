import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root
    property bool checked: false
    property bool enabled: true
    // Disabled visual sub-states
    // activeDisabled: was checked but disabled
    // inactiveDisabled: unchecked and disabled
    readonly property bool activeDisabled: !enabled && checked
    readonly property bool inactiveDisabled: !enabled && !checked
    property string text: ""
    signal toggled(bool checked)

    implicitHeight: 28
    implicitWidth: Math.max(28, label.implicitWidth + 28)

    Row {
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        // box
        Rectangle {
            id: box
            width: 18; height: 18; radius: 4
            border.width: (root.enabled && !checked) ? 2 : 0
            border.color: root.enabled ? Palette.palette().onSurfaceVariant : Qt.rgba(0.5,0.5,0.5,1)
            // Disabled variants should be neutral gray
            color: !root.enabled ? Qt.rgba(0.35,0.35,0.35,1)
                              : (checked ? Palette.palette().primary : "transparent")
            opacity: 1.0
            Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
            Behavior on border.width { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }

            Canvas {
                anchors.fill: parent
                visible: root.checked
                onPaint: {
                    var ctx = getContext('2d')
                    ctx.reset()
                    ctx.strokeStyle = root.enabled ? Palette.palette().onPrimary : Qt.rgba(0.82,0.82,0.82,1)
                    ctx.lineWidth = 2
                    ctx.lineCap = 'round'
                    ctx.beginPath()
                    // simple check glyph
                    ctx.moveTo(width*0.25, height*0.55)
                    ctx.lineTo(width*0.45, height*0.75)
                    ctx.lineTo(width*0.78, height*0.30)
                    ctx.stroke()
                }
            }
        }

        Text {
            id: label
            text: root.text
            color: root.enabled ? Palette.palette().onSurface : Qt.rgba(0.75,0.75,0.75,1)
            anchors.verticalCenter: box.verticalCenter
            font.pixelSize: 14
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        onClicked: { root.checked = !root.checked; root.toggled(root.checked) }
    }
}


