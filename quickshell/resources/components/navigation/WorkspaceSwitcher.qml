import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Components

Item {
    id: root
    // Public API
    property int count: 5
    property int currentIndex: 0
    property int itemWidth: 34
    property int itemHeight: 26
    property int spacing: 8
    // When text color should switch to the destination index (ms)
    property int colorSwitchDelay: 80
    signal activated(int index)

    implicitWidth: Math.max(itemWidth, count * itemWidth + (count - 1) * spacing)
    implicitHeight: itemHeight

    // Diameter of circular background
    property real bgSize: Math.min(itemWidth, itemHeight)
    function itemX(i) { return i * (itemWidth + spacing) }
    function itemCenterX(i) { return itemX(i) + (itemWidth - bgSize) / 2 }

    // Index used for text coloring; switches mid-animation for better sync
    property int colorIndex: currentIndex

    // Active background circle that stretches while moving
    Rectangle {
        id: activeBg
        width: root.bgSize
        height: root.bgSize
        radius: height / 2
        color: Components.ColorPalette.primary
        y: (root.height - height) / 2
        x: root.itemCenterX(root.currentIndex)
        transformOrigin: Item.Center
        transform: Scale { id: bgScale; xScale: 1.0; yScale: 1.0 }
        z: 0
        visible: root.count > 0
    }

    // Foreground clickable labels (no background when inactive)
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
                    color: active ? Components.ColorPalette.onPrimary : Components.ColorPalette.onSurface
                    font.pixelSize: 14
                    font.bold: true
                    Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
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

    // Switch animation: immediate stretch + move, then relax
    ParallelAnimation {
        id: switchAnim
        property real destX: 0
        property int destIndex: 0
        running: false
        // Move only; pulse handled separately to prevent cumulative squish
        NumberAnimation { target: activeBg; property: "x"; duration: 160; easing.type: Easing.InOutCubic; to: switchAnim.destX }
        onStopped: root.currentIndex = switchAnim.destIndex
    }

    // Independent pulse animations
    SequentialAnimation { id: pulseX; running: false; PropertyAnimation { target: bgScale; property: "xScale"; to: 1.6; duration: 70; easing.type: Easing.OutCubic } PropertyAnimation { target: bgScale; property: "xScale"; to: 1.0; duration: 110; easing.type: Easing.OutBack } }
    SequentialAnimation { id: pulseY; running: false; PropertyAnimation { target: bgScale; property: "yScale"; to: 0.9; duration: 70; easing.type: Easing.OutCubic } PropertyAnimation { target: bgScale; property: "yScale"; to: 1.0; duration: 110; easing.type: Easing.OutBack } }

    // Mid-animation text color switcher
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


