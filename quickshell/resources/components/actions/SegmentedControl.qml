import QtQuick 2.15
import ".." as Components

Row {
    id: root
    property var options: ["One", "Two", "Three"]
    property int currentIndex: 0
    property bool enabled: true
    signal changed(int index)
    spacing: 3

    Repeater {
        model: options.length
        delegate: Item {
            property bool selected: index === root.currentIndex
            property real t: selected ? 1 : 0
            property bool itemPressed: false
            property bool isFirst: index === 0
            property bool isLast: index === (root.options.length - 1)
            property real innerRadius: 6
            width: Math.max(60, textItem.implicitWidth + 20)
            height: 32
            Behavior on t { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            onTChanged: bg.requestPaint()
            onItemPressedChanged: bg.requestPaint()
            onSelectedChanged: { t = selected ? 1 : 0; bg.requestPaint() }

            Canvas {
                id: bg
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext('2d')
                    ctx.reset()
                    var w = width
                    var h = height
                    var pillRadius = h / 2
                    
                    // Selected button is always pill-shaped
                    // Unselected buttons: position-based corners, but morph outer corners when pressed
                    var sharpRadius = 4
                    var outerRadius = itemPressed ? sharpRadius : pillRadius
                    
                    var rTL = selected ? pillRadius : (isFirst ? outerRadius : innerRadius)
                    var rTR = selected ? pillRadius : (isLast ? outerRadius : innerRadius)
                    var rBR = selected ? pillRadius : (isLast ? outerRadius : innerRadius)
                    var rBL = selected ? pillRadius : (isFirst ? outerRadius : innerRadius)
                    
                    function drawRoundRect(radTL, radTR, radBR, radBL) {
                        ctx.beginPath()
                        ctx.moveTo(radTL, 0)
                        ctx.lineTo(w - radTR, 0)
                        ctx.arcTo(w, 0, w, radTR, radTR)
                        ctx.lineTo(w, h - radBR)
                        ctx.arcTo(w, h, w - radBR, h, radBR)
                        ctx.lineTo(radBL, h)
                        ctx.arcTo(0, h, 0, h - radBL, radBL)
                        ctx.lineTo(0, radTL)
                        ctx.arcTo(0, 0, radTL, 0, radTL)
                        ctx.closePath()
                    }
                    
                    // unselected base
                    ctx.fillStyle = Components.ColorPalette.surfaceVariant
                    drawRoundRect(rTL, rTR, rBR, rBL)
                    ctx.fill()
                    
                    // overlay primary with animated alpha for selection
                    if (t > 0) {
                        ctx.globalAlpha = t
                        ctx.fillStyle = Components.ColorPalette.primary
                        drawRoundRect(rTL, rTR, rBR, rBL)
                        ctx.fill()
                        ctx.globalAlpha = 1.0
                    }
                }
            }

            Text {
                id: textItem
                anchors.centerIn: parent
                text: root.options[index]
                color: selected ? Components.ColorPalette.onPrimary : Components.ColorPalette.onSurface
                font.pixelSize: 14
                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                onPressedChanged: parent.itemPressed = pressed
                onExited: parent.itemPressed = false
                onClicked: {
                    if (root.currentIndex === index) return
                    root.currentIndex = index
                    root.changed(index)
                }
            }

            Connections { target: root; function onCurrentIndexChanged() { t = selected ? 1 : 0; bg.requestPaint() } }
        }
    }
}


