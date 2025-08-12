import QtQuick 2.15
import "../../colors.js" as Palette

Row {
    id: root
    property var options: ["One", "Two", "Three"]
    property int currentIndex: 0
    property bool enabled: true
    signal changed(int index)
    spacing: 0

    Repeater {
        model: options.length
        delegate: Item {
            property bool selected: index === root.currentIndex
            property real t: selected ? 1 : 0
            width: Math.max(60, textItem.implicitWidth + 20)
            height: 32
            Behavior on t { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
            onTChanged: bg.requestPaint()

            Canvas {
                id: bg
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext('2d')
                    ctx.reset()
                    var w = width
                    var h = height
                    var full = h / 2
                    var softBaseLeft = (index === 0 ? full : 2)
                    var softBaseRight = (index === (root.options.length - 1) ? full : 2)
                    var rTL = softBaseLeft + (full - softBaseLeft) * t
                    var rBL = rTL
                    var rTR = softBaseRight + (full - softBaseRight) * t
                    var rBR = rTR
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
                    ctx.fillStyle = Palette.palette().surfaceVariant
                    drawRoundRect(rTL, rTR, rBR, rBL)
                    ctx.fill()
                    // overlay primary with animated alpha for selection
                    if (t > 0) {
                        ctx.globalAlpha = t
                        ctx.fillStyle = Palette.palette().primary
                        drawRoundRect(full, full, full, full)
                        ctx.fill()
                        ctx.globalAlpha = 1.0
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
            }

            Text {
                id: textItem
                anchors.centerIn: parent
                text: root.options[index]
                color: selected ? Palette.palette().onPrimary : Palette.palette().onSurface
                font.pixelSize: 14
                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                onClicked: {
                    if (root.currentIndex === index) return
                    var target = index
                    var steps = 6
                    var s = 0
                    var timer = Qt.createQmlObject('import QtQuick 2.15; Timer { interval: 16; repeat: true }', root)
                    timer.triggered.connect(function() {
                        s++
                        bg.requestPaint()
                        if (s >= steps) {
                            timer.stop(); timer.destroy();
                            root.currentIndex = target
                            root.changed(target)
                            bg.requestPaint()
                        }
                    })
                    timer.start()
                }
            }

            onSelectedChanged: { t = selected ? 1 : 0; bg.requestPaint() }
            Connections { target: root; function onCurrentIndexChanged() { t = selected ? 1 : 0; bg.requestPaint() } }
        }
    }
}


