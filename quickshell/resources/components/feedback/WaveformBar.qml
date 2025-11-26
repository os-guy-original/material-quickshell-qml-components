import QtQuick 2.15
import ".." as Components

Item {
    id: root
    // Simple media-style waveform/progress visualization
    property var samples: [] // array of 0..1 values
    property real progress: 0.0 // 0..1 playback position
    property color barColor: Components.ColorPalette.isDarkMode ? Components.ColorPalette.surfaceVariant : Qt.darker(Components.ColorPalette.background, 1.08)
    property color playedColor: Components.ColorPalette.onPrimary
    property int barWidth: 3
    property int gap: 2
    property int minHeightPx: 2
    property int maxHeightPx: 24
    implicitHeight: maxHeightPx
    implicitWidth: (barWidth + gap) * Math.max(1, root.samples.length)
    clip: true
    Rectangle { anchors.fill: parent; color: "transparent" }

    Repeater {
        model: root.samples
        delegate: Rectangle {
            width: root.barWidth
            height: Math.max(root.minHeightPx, Math.round(root.minHeightPx + (root.maxHeightPx - root.minHeightPx) * modelData))
            radius: width / 2
            color: (index / Math.max(1, root.samples.length - 1)) <= root.progress ? root.playedColor : root.barColor
            anchors.bottom: parent.bottom
            x: index * (root.barWidth + root.gap)
        }
    }
}


