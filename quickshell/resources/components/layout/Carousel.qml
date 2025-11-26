import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

/**
 * Material Design Carousel
 * Supports Hero, Multi-browse, and Uncontained layouts
 */
Item {
    id: root

    property var model
    property Component delegate
    property var flexWeights: []
    property real itemSpacing: 8
    property real itemExtent: -1  // For uncontained layout
    property real itemRadius: 16  // Corner radius for items
    property bool itemSnapping: true  // Enable smooth snapping

    signal itemClicked(int index)

    implicitWidth: 400
    implicitHeight: 200
    clip: true

    readonly property bool isWeighted: flexWeights.length > 0
    readonly property int itemCount: model ? (model.count !== undefined ? model.count : model) : 0

    // Weighted layout calculations
    readonly property real totalWeight: {
        if (!isWeighted) return 1
        let sum = 0
        for (let i = 0; i < flexWeights.length; i++) sum += flexWeights[i]
        return sum
    }
    readonly property real unitSize: width / totalWeight

    // Find the hero (largest weight) position and value
    readonly property int heroPosition: {
        if (!isWeighted) return 0
        let maxIdx = 0
        for (let i = 1; i < flexWeights.length; i++) {
            if (flexWeights[i] > flexWeights[maxIdx]) maxIdx = i
        }
        return maxIdx
    }
    readonly property real heroWeight: isWeighted ? flexWeights[heroPosition] : 1
    readonly property real heroSize: heroWeight * unitSize

    // Small weight (for items outside the pattern)
    readonly property real smallWeight: {
        if (!isWeighted) return 1
        let minW = flexWeights[0]
        for (let i = 1; i < flexWeights.length; i++) {
            if (flexWeights[i] < minW) minW = flexWeights[i]
        }
        return minW
    }
    readonly property real smallSize: smallWeight * unitSize

    // Scroll unit = small item size
    readonly property real scrollUnit: smallSize


    // Weighted carousel - uses absolute positioning for proper center hero behavior
    Item {
        id: weightedContainer
        visible: root.isWeighted
        anchors.fill: parent

        // Current focus state (which item is the hero)
        property real focusIndex: 0

        // Clamp focus to valid range
        function clampFocus(f) {
            return Math.max(0, Math.min(f, root.itemCount - 1))
        }

        // Mouse/touch handling for scrolling
        MouseArea {
            id: dragArea
            anchors.fill: parent

            property real startX: 0
            property real startFocus: 0

            onPressed: (mouse) => {
                startX = mouse.x
                startFocus = weightedContainer.focusIndex
                focusAnimation.stop()
            }

            onPositionChanged: (mouse) => {
                const dx = mouse.x - startX
                const focusDelta = -dx / root.heroSize
                weightedContainer.focusIndex = weightedContainer.clampFocus(startFocus + focusDelta)
            }

            onReleased: {
                if (root.itemSnapping) {
                    focusAnimation.to = Math.round(weightedContainer.focusIndex)
                    focusAnimation.start()
                }
            }

            onWheel: (wheel) => {
                const delta = wheel.angleDelta.x !== 0 ? wheel.angleDelta.x : -wheel.angleDelta.y
                const focusDelta = -delta / 120
                weightedContainer.focusIndex = weightedContainer.clampFocus(weightedContainer.focusIndex + focusDelta * 0.5)

                if (root.itemSnapping) {
                    snapTimer.restart()
                }
            }
        }

        Timer {
            id: snapTimer
            interval: 150
            onTriggered: {
                focusAnimation.to = Math.round(weightedContainer.focusIndex)
                focusAnimation.start()
            }
        }

        NumberAnimation {
            id: focusAnimation
            target: weightedContainer
            property: "focusIndex"
            duration: 200
            easing.type: Easing.OutCubic
        }

        // Items positioned absolutely
        Repeater {
            model: root.itemCount

            Item {
                id: carouselItem
                required property int index

                readonly property var itemModel: root.model && root.model.get ? root.model.get(index) : { index: index }

                // Calculate size based on distance from focus
                readonly property real itemSize: {
                    const weights = root.flexWeights
                    const numWeights = weights.length
                    const heroPos = root.heroPosition
                    const focus = weightedContainer.focusIndex

                    const floorFocus = Math.floor(focus)
                    const ceilFocus = Math.ceil(focus)
                    const t = focus - floorFocus

                    function getSizeForFocus(focusIdx) {
                        if (index === focusIdx) return root.heroSize

                        const d = index - focusIdx
                        const slot = heroPos + d

                        if (slot < 0 || slot >= numWeights) {
                            return root.smallSize
                        }
                        return weights[slot] * root.unitSize
                    }

                    const sizeAtFloor = getSizeForFocus(floorFocus)
                    const sizeAtCeil = getSizeForFocus(ceilFocus)

                    return sizeAtFloor + (sizeAtCeil - sizeAtFloor) * t
                }


                // Calculate x position with smooth interpolation
                readonly property real itemX: {
                    const focus = weightedContainer.focusIndex
                    const heroPos = root.heroPosition
                    const numWeights = root.flexWeights.length
                    const weights = root.flexWeights

                    function getPositionAtFocus(focusIdx) {
                        // Calculate where the hero should be positioned
                        let heroX = 0
                        for (let i = 0; i < heroPos; i++) {
                            heroX += weights[i] * root.unitSize + root.itemSpacing
                        }

                        // At edges, hero shifts position
                        if (focusIdx < heroPos) {
                            heroX = 0
                            for (let i = 0; i < focusIdx; i++) {
                                heroX += root.smallSize + root.itemSpacing
                            }
                        } else if (focusIdx > root.itemCount - 1 - (numWeights - 1 - heroPos)) {
                            const fromEnd = root.itemCount - 1 - focusIdx
                            heroX = root.width - root.heroSize
                            for (let i = 0; i < fromEnd; i++) {
                                heroX -= root.smallSize + root.itemSpacing
                            }
                        }

                        if (index === focusIdx) {
                            return heroX
                        }

                        let x = heroX
                        if (index < focusIdx) {
                            for (let i = focusIdx - 1; i >= index; i--) {
                                const d = i - focusIdx
                                const slot = heroPos + d
                                const w = (slot >= 0 && slot < numWeights) ? weights[slot] : root.smallWeight
                                x -= w * root.unitSize + root.itemSpacing
                            }
                        } else {
                            x += root.heroSize + root.itemSpacing
                            for (let i = focusIdx + 1; i < index; i++) {
                                const d = i - focusIdx
                                const slot = heroPos + d
                                const w = (slot >= 0 && slot < numWeights) ? weights[slot] : root.smallWeight
                                x += w * root.unitSize + root.itemSpacing
                            }
                        }

                        return x
                    }

                    const floorFocus = Math.floor(focus)
                    const ceilFocus = Math.ceil(focus)
                    const t = focus - floorFocus

                    if (floorFocus === ceilFocus) {
                        return getPositionAtFocus(floorFocus)
                    }

                    const posAtFloor = getPositionAtFocus(floorFocus)
                    const posAtCeil = getPositionAtFocus(ceilFocus)

                    return posAtFloor + (posAtCeil - posAtFloor) * t
                }

                // Raw calculated values
                readonly property real rawWidth: Math.max(itemSize - root.itemSpacing, 0)
                readonly property real rawX: itemX

                // Material Design behavior: items grow from edges
                readonly property real clampedX: {
                    if (rawX < 0) return 0
                    if (rawX + rawWidth > root.width) return root.width - Math.max(0, root.width - rawX)
                    return rawX
                }

                readonly property real clampedWidth: {
                    if (rawX < 0) return Math.max(0, rawWidth + rawX)
                    if (rawX + rawWidth > root.width) return Math.max(0, root.width - rawX)
                    return rawWidth
                }

                x: clampedX
                width: Math.max(clampedWidth, 0)
                height: weightedContainer.height
                visible: clampedWidth > 1


                // Rounded container with proper clipping
                Rectangle {
                    id: itemContainer
                    anchors.fill: parent
                    radius: root.itemRadius
                    color: "transparent"

                    layer.enabled: root.itemRadius > 0
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: itemContainer.width
                            height: itemContainer.height
                            radius: itemContainer.radius
                        }
                    }

                    Loader {
                        anchors.fill: parent
                        sourceComponent: root.delegate

                        onLoaded: {
                            if (item) {
                                item.modelData = Qt.binding(() => carouselItem.itemModel)
                                item.index = Qt.binding(() => carouselItem.index)
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.itemClicked(carouselItem.index)
                    propagateComposedEvents: true
                    onPressed: (mouse) => mouse.accepted = false
                }
            }
        }
    }

    // Uncontained layout (simple ListView)
    ListView {
        id: listView
        visible: !root.isWeighted
        anchors.fill: parent

        orientation: ListView.Horizontal
        spacing: root.itemSpacing

        model: root.model

        delegate: Item {
            id: listItem
            required property int index
            required property var modelData

            width: root.itemExtent > 0 ? root.itemExtent : 200
            height: listView.height

            Rectangle {
                id: listItemContainer
                anchors.fill: parent
                radius: root.itemRadius
                color: "transparent"

                layer.enabled: root.itemRadius > 0
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: listItemContainer.width
                        height: listItemContainer.height
                        radius: listItemContainer.radius
                    }
                }

                Loader {
                    anchors.fill: parent
                    sourceComponent: root.delegate

                    onLoaded: {
                        if (item) {
                            item.modelData = Qt.binding(() => listItem.modelData)
                            item.index = Qt.binding(() => listItem.index)
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.itemClicked(listItem.index)
            }
        }

        snapMode: root.itemSnapping ? ListView.SnapOneItem : ListView.NoSnap
    }

    function scrollToIndex(idx) {
        if (root.isWeighted) {
            focusAnimation.stop()
            focusAnimation.to = weightedContainer.clampFocus(idx)
            focusAnimation.start()
        } else {
            listView.positionViewAtIndex(idx, ListView.Beginning)
        }
    }
}
