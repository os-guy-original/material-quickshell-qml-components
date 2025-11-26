import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Components
import "../feedback" as Feedback
import "../layout" as UILayout

Item {
    id: root
    property int count: 5
    property int currentIndex: 0
    property int itemWidth: 34
    property int itemHeight: 26
    property int spacing: 8
    property int colorSwitchDelay: 0
    property var labels: []
    property var icons: []
    property int fadeOutCount: count
    property var occupiedIndices: []
    signal activated(int index)

    property bool showOverflow: currentIndex >= count
    property real targetWidth: Math.max(itemWidth, count * itemWidth + (count - 1) * spacing) + overflowItem.width + (showOverflow ? spacing : 0)
    implicitWidth: targetWidth
    implicitHeight: itemHeight
    
    Behavior on targetWidth {
        NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
    }

    property real bgSize: Math.min(itemWidth, itemHeight) - 6
    property int visualActiveIndex: currentIndex < count ? currentIndex : -1
    property bool wasInOverflow: false
    
    function itemX(i) { return i * (itemWidth + spacing) }
    function itemCenterX(i) { return itemX(i) + (itemWidth - bgSize) / 2 }
    
    function findOccupiedRanges() {
        var ranges = []
        var start = -1
        for (var i = 0; i < count; i++) {
            if (occupiedIndices.indexOf(i) !== -1) {
                if (start === -1) start = i
            } else {
                if (start !== -1) {
                    ranges.push({start: start, end: i - 1})
                    start = -1
                }
            }
        }
        if (start !== -1) ranges.push({start: start, end: count - 1})
        return ranges
    }
    
    Repeater {
        model: findOccupiedRanges()
        delegate: Rectangle {
            property var range: modelData
            
            x: itemX(range.start)
            y: (root.height - height) / 2
            width: (range.end - range.start + 1) * itemWidth + (range.end - range.start) * spacing
            height: root.itemHeight
            radius: height / 2
            color: Qt.rgba(Components.ColorPalette.primary.r, 
                          Components.ColorPalette.primary.g, 
                          Components.ColorPalette.primary.b, 0.15)
            z: -1
            
            Behavior on x { 
                NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } 
            }
            Behavior on width { 
                NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } 
            }
        }
    }
    
    Rectangle {
        id: activeBg
        width: root.bgSize
        height: root.bgSize
        radius: height / 2
        color: Components.ColorPalette.primary
        y: (root.height - height) / 2
        x: root.showOverflow ? root.itemCenterX(root.count) : root.itemCenterX(root.currentIndex)
        z: 0
        visible: root.count > 0
        scale: 0.0
        
        Component.onCompleted: scale = 1.0
        
        Behavior on scale {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack }
        }
        
        Behavior on x {
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
                    SequentialAnimation {
                        PauseAnimation { duration: 60 }
                        ScriptAction {
                            script: root.visualActiveIndex = root.currentIndex < root.count ? root.currentIndex : -1
                        }
                    }
                }
            }
        }
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
                readonly property bool active: index === root.visualActiveIndex
                opacity: index < root.fadeOutCount ? 1.0 : 0.0
                scale: index < root.fadeOutCount ? 1.0 : 0.8
                
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }
                
                property string iconSource: (root.icons && root.icons.length > index && root.icons[index]) ? root.icons[index] : ""
                property bool hasIcon: iconSource !== ""
                
                UILayout.RoundedFrame {
                    id: iconFrame
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) - 6
                    height: width
                    circular: true
                    source: parent.iconSource
                    visible: parent.hasIcon
                }
                
                Text {
                    anchors.centerIn: parent
                    text: (root.labels && root.labels.length > index && root.labels[index] && root.labels[index].length > 0)
                          ? root.labels[index]
                          : (index + 1)
                    color: active ? Components.ColorPalette.onPrimary : Components.ColorPalette.onSurface
                    font.pixelSize: 14
                    font.bold: true
                    visible: !parent.hasIcon
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

    Item {
        id: overflowItem
        width: root.showOverflow ? root.itemWidth : 0
        height: root.itemHeight
        x: root.itemX(root.count)
        anchors.verticalCenter: parent.verticalCenter
        z: 1
        clip: true
        
        property int displayedIndex: root.currentIndex
        
        Behavior on width { 
            NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
        }
        
        Text {
            id: overflowText
            anchors.centerIn: parent
            text: overflowItem.displayedIndex + 1
            color: Components.ColorPalette.onPrimary
            font.pixelSize: 14
            font.bold: true
            opacity: overflowItem.width > 0 ? 1 : 0
            scale: 1.0
            
            Behavior on opacity {
                NumberAnimation { duration: 100; easing.type: Easing.InOutCubic }
            }
        }
        
        MouseArea {
            id: overflowArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
    
    onCurrentIndexChanged: {
        if (showOverflow) {
            overflowTextChangeAnim.restart()
        } else {
            overflowItem.displayedIndex = currentIndex
        }
    }
    
    SequentialAnimation {
        id: overflowTextChangeAnim
        NumberAnimation { target: overflowText; property: "scale"; to: 0.7; duration: 60; easing.type: Easing.InOutCubic }
        ScriptAction { script: overflowItem.displayedIndex = root.currentIndex }
        NumberAnimation { target: overflowText; property: "scale"; to: 1.0; duration: 60; easing.type: Easing.InOutCubic }
    }

    function goTo(index) {
        if (index < 0 || index >= root.count) return
        if (index === root.currentIndex) return
        root.activated(index)
    }
    
    onShowOverflowChanged: {
        wasInOverflow = showOverflow
        if (!showOverflow) overflowItem.displayedIndex = currentIndex
    }
}
