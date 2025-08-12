import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../colors.js" as Palette

// Generic switcher for a small set of indices (e.g., workspaces)
// Active index is shown with a circular primary background that stretches during transitions
Item {
    id: root
    property int count: 5
    property int currentIndex: 0
    property int itemWidth: 34
    property int itemHeight: 26
    property int spacing: 8
    property int colorSwitchDelay: 80
    signal activated(int index)

    implicitWidth: Math.max(itemWidth, count * itemWidth + (count - 1) * spacing)
    implicitHeight: itemHeight

    property real bgSize: Math.min(itemWidth, itemHeight)
    function itemX(i) { return i * (itemWidth + spacing) }
    function itemCenterX(i) { return itemX(i) + (itemWidth - bgSize) / 2 }
    property int colorIndex: currentIndex

    Rectangle {
        id: activeBg
        width: root.bgSize
        height: root.bgSize
        radius: height / 2
        color: Palette.palette().primary
        y: (root.height - height) / 2
        x: root.itemCenterX(root.currentIndex)
        transformOrigin: Item.Center
        transform: Scale { id: bgScale; xScale: 1.0; yScale: 1.0 }
        z: 0
        visible: root.count > 0
    }

    Row {
        id: row
        spacing: root.spacing
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        z: 1
        Repeater {
            model: root.count
            delegate: Item {
                width: root.itemWidth
                height: root.itemHeight
                readonly property bool active: index === root.colorIndex
                Text {
                    anchors.centerIn: parent
                    text: (index + 1)
                    color: active ? Palette.palette().onPrimary : Palette.palette().onSurface
                    font.pixelSize: 14
                    font.bold: true
                    Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutCubic } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.goTo(index)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    ParallelAnimation {
        id: switchAnim
        property real destX: 0
        property int destIndex: 0
        running: false
        NumberAnimation { target: activeBg; property: "x"; duration: 160; easing.type: Easing.InOutCubic; to: switchAnim.destX }
        onStopped: root.currentIndex = switchAnim.destIndex
    }

    // Independent pulse animations so repeated clicks never accumulate stretch
    SequentialAnimation { id: pulseX; running: false; PropertyAnimation { target: bgScale; property: "xScale"; to: 1.6; duration: 70; easing.type: Easing.OutCubic } PropertyAnimation { target: bgScale; property: "xScale"; to: 1.0; duration: 110; easing.type: Easing.OutBack } }
    SequentialAnimation { id: pulseY; running: false; PropertyAnimation { target: bgScale; property: "yScale"; to: 0.9; duration: 70; easing.type: Easing.OutCubic } PropertyAnimation { target: bgScale; property: "yScale"; to: 1.0; duration: 110; easing.type: Easing.OutBack } }

    Timer {
        id: colorSwitchTimer
        interval: root.colorSwitchDelay
        repeat: false
        property int dest: 0
        onTriggered: root.colorIndex = dest
    }

    function goTo(index) {
        if (index < 0 || index >= root.count) return
        if (index === root.currentIndex && !switchAnim.running) return
        // Reset ongoing animations to avoid cumulative squish
        if (switchAnim.running) switchAnim.stop()
        if (pulseX.running) pulseX.stop()
        if (pulseY.running) pulseY.stop()
        bgScale.xScale = 1.0
        bgScale.yScale = 1.0
        switchAnim.destX = root.itemCenterX(index)
        switchAnim.destIndex = index
        switchAnim.start()
        colorSwitchTimer.stop(); colorSwitchTimer.dest = index; colorSwitchTimer.start()
        pulseX.start(); pulseY.start()
        root.activated(index)
    }
}


