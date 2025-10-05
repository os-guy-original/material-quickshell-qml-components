import QtQuick 2.15
import QtQml 2.15
import "../../colors.js" as Palette
import "./MenuRegistry.js" as MenuRegistry

/*
  New HamburgerMenu implementation
  - items: [{ label, enabled?, submenu?, onTriggered? }]
  - API: openAt(x,y), openAtItem(item), close(), signal closed()
  - Features:
    - 48dp rows
    - Circular expanding ripple centered on pointer
    - Submenu support (auto-side selection)
    - Keyboard navigation: Up/Down, Right (open submenu), Enter, Esc/Left
    - No DropShadow
*/

Item {
    id: root
    anchors.fill: parent
    z: 999

    // Public API
    property bool open: false
    property var items: []
    // mark if this menu is a submenu (so opening won't close its parent via MenuRegistry)
    property bool isSubmenu: false
    onItemsChanged: {
        if (panel) { panel.maxRowWidth = 0; panel.updateSize() }
    }

    // External back pill overlay (outside and above the menu panel)
    Rectangle {
        id: backPillOverlay
        property bool _suppressAnim: true
        visible: root.open && root.currentLevel > 0 && panel.visible
        width: 48
        height: root.backPillHeight
        radius: height / 2
        color: Palette.palette().surfaceVariant
        // Center horizontally over the panel
        x: panel.x + Math.round((panel.width - width) / 2)
        y: Math.max(0, panel.y - (root.backPillHeight + root.backGap))
        z: panel.z + 1
        Behavior on x { enabled: !backPillOverlay._suppressAnim; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on y { enabled: !backPillOverlay._suppressAnim; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        // No border per request; just the pill background and arrow
        Text { text: "‹"; anchors.centerIn: parent; color: Palette.palette().onSurface; font.pixelSize: 16 }
        MouseArea { anchors.fill: parent; onClicked: root.popLevel() }
    }
    property int menuX: 0
    property int menuY: 0
    property int minWidth: 0
    signal closed()

    // Pre-measure labels to get a reliable max row width before first render
    function _preMeasureMaxRowWidth(itemsArr) {
        var maxW = 0
        var arr = itemsArr || items
        if (!arr || !arr.length) return 0
        for (var i = 0; i < arr.length; i++) {
            var it = arr[i]
            var txt = (it && it.label) ? String(it.label) : ""
            // Create a transient Text to read implicitWidth
            var t = Qt.createQmlObject('import QtQuick 2.15; Text { text: "' + txt.replace(/"/g, '\\"') + '"; font.pixelSize: 15; visible: false }', root)
            if (t && typeof t.implicitWidth === 'number') {
                var rowW = t.implicitWidth + (it && it.submenu ? 48 : 24)
                if (rowW > maxW) maxW = rowW
                t.destroy()
            }
        }
        return Math.round(maxW)
    }

    // Predict height for a given items array (rows are 48px + spacing between)
    function _predictHeight(itemsArr) {
        var arr = itemsArr || []
        var rows = arr.length
        var body = rows > 0 ? (rows * 48 + Math.max(0, rows - 1) * 4) : 0 // 4 = content.spacing
        var margins = 16 // top+bottom margins on content
        return body + margins
    }

    // Internal
    property int focusedIndex: -1
    // Sliding navigation state
    property var itemStack: [] // array of item arrays
    property int currentLevel: 0
    property var visibleItems: []
    property var nextItems: []
    property bool animating: false
    onIsSubmenuChanged: { if (isSubmenu) console.log("[HamburgerMenu] 'isSubmenu' is deprecated; using single in-place sliding menu.") }

    // Back pill configuration
    property int backPillHeight: 28
    property int backGap: 8

    // Slide animations and navigation at root scope
    property var _afterSlide: null
    NumberAnimation { id: slideA; target: pageA; property: "x"; duration: 160; easing.type: Easing.OutCubic }
    NumberAnimation { id: slideB; target: pageB; property: "x"; duration: 160; easing.type: Easing.OutCubic; onStopped: { if (root._afterSlide) { var f = root._afterSlide; root._afterSlide = null; f() } } }

    function pushLevel(items) {
        if (!items || root.animating) return
        root.animating = true
        root.nextItems = items
        pageB.x = viewport.width
        // Predict size for next items and pre-apply so the panel resizes as we slide
        panel.maxRowWidth = root._preMeasureMaxRowWidth(items)
        var predictedW = Math.max(root.minWidth, panel.maxRowWidth > 0 ? panel.maxRowWidth + 36 : panel.width)
        var predictedH = _predictHeight(items)
        panel.width = predictedW
        panel.height = predictedH
        // keep incoming page hidden during slide; outgoing pageA remains visible
        pageB.opacity = 0
        slideA.to = -viewport.width
        slideB.to = 0
        root._afterSlide = function(){
            try { root.itemStack.push(items); root.currentLevel = root.itemStack.length - 1; root.visibleItems = items } catch(e) {}
            pageA.x = 0; pageB.x = viewport.width
            root.animating = false
            panel.maxRowWidth = root._preMeasureMaxRowWidth(root.visibleItems)
            root.nextItems = []
            panel.updateSize()
            // after commit, ensure only active page is visible
            pageA.opacity = 1
            pageB.opacity = 0
        }
        slideA.start(); slideB.start()
    }

    function popLevel() {
        if (root.currentLevel <= 0 || root.animating) return
        root.animating = true
        var prevItems = root.itemStack[root.currentLevel - 1]
        root.nextItems = prevItems
        pageB.x = -viewport.width
        // Predict size for previous items and pre-apply
        panel.maxRowWidth = root._preMeasureMaxRowWidth(prevItems)
        var predictedW2 = Math.max(root.minWidth, panel.maxRowWidth > 0 ? panel.maxRowWidth + 36 : panel.width)
        var predictedH2 = _predictHeight(prevItems)
        panel.width = predictedW2
        panel.height = predictedH2
        // keep incoming page hidden during slide
        pageB.opacity = 0
        slideA.to = viewport.width
        slideB.to = 0
        root._afterSlide = function(){
            try { root.itemStack.pop(); root.currentLevel = root.itemStack.length - 1; root.visibleItems = prevItems } catch(e) {}
            pageA.x = 0; pageB.x = viewport.width
            root.animating = false
            panel.maxRowWidth = root._preMeasureMaxRowWidth(root.visibleItems)
            root.nextItems = []
            panel.updateSize()
            pageA.opacity = 1
            pageB.opacity = 0
        }
        slideA.start(); slideB.start()
    }

    onOpenChanged: {
        if (open) {
            // Only request global open for top-level menus. Submenus should not close their parent.
            if (!root.isSubmenu) MenuRegistry.requestOpen(root)
            panel.forceActiveFocus()
            focusedIndex = -1
            // Prepare for sizing and show only after measurement to avoid first-open broken layout
            panel.sized = false
            // clear any fading state (in case we were mid-fade from previous close)
            panel.fading = false
            panel.opacity = 0
            // init stack FIRST so we can pre-measure correct contents
            try { root.itemStack = [ root.items ? root.items : [] ]; root.currentLevel = 0; root.visibleItems = root.itemStack[0]; } catch(e) { root.itemStack = [[]]; root.currentLevel = 0; root.visibleItems = [] }
            // Pre-measure to establish a good initial size (width + height)
            try { panel.maxRowWidth = root._preMeasureMaxRowWidth(root.visibleItems) } catch(e2) { panel.maxRowWidth = 0 }
            var predictedW = Math.max(root.minWidth, (panel.maxRowWidth > 0 ? panel.maxRowWidth + 36 : 160))
            var predictedH = _predictHeight(root.visibleItems)
            // keep hidden until sized to avoid first-open wrong size flash
            panel.visible = false
            panel.width = predictedW
            panel.height = predictedH
            panel.measuredCount = 0
            // Defer size calculation to allow repeater/delegates to complete
            Qt.callLater(function(){ Qt.callLater(panel.updateSize) })
        } else {
            MenuRegistry.notifyClosed(root)
        }
    }

    function openAt(x, y) {
        menuX = Math.round(x)
        menuY = Math.round(y)
        open = true
    }
    function openAtItem(item) {
        if (!item || !item.mapToItem) { openAt(0,0); return }
        var p = item.mapToItem(root, 0, item.height)
        openAt(p.x, p.y)
    }
    function close() {
        open = false
        closed()
    }

    // click-away
    MouseArea { anchors.fill: parent; visible: root.open; enabled: visible; onClicked: root.close(); hoverEnabled: true }

    Rectangle {
        id: panel
        property bool sized: false
        property int measuredCount: 0
        x: Math.min(Math.max(0, root.menuX), root.width - width)
        y: Math.min(Math.max(0, root.menuY), root.height - height)
        // Measured max row width + paddings computed in updateSize
        property int maxRowWidth: 0
        property int sizeAttempts: 0
        property bool fading: false
        property bool _postAdjusted: false
        // width and height are assigned in updateSize()
        // Darker tonal surface and no border
        color: Qt.darker(Palette.palette().surfaceVariant, 1.12)
        radius: 12
        border.width: 0
    visible: false
    opacity: 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        // Animate resize to follow content changes smoothly
        Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        // Suppress position animation for the very first show to avoid (0,0) slide-in
        property bool _suppressPosAnim: true
        Behavior on x { enabled: !panel._suppressPosAnim; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on y { enabled: !panel._suppressPosAnim; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        z: 10

        focus: true
        // page-level fade handled on pageA/pageB; no global content fade
        Keys.onPressed: function(event) {
            if (!root.open) return
            if (event.key === Qt.Key_Down) {
                focusedIndex = Math.min(rep.count - 1, focusedIndex + 1)
                rep.forceActiveDelegate = focusedIndex
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                focusedIndex = Math.max(0, focusedIndex - 1)
                rep.forceActiveDelegate = focusedIndex
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                if (focusedIndex >= 0 && focusedIndex < rep.count) {
                    var d = rep.itemAt(focusedIndex)
                    if (d && d.itemData && d.itemData.submenu) root.pushLevel(d.itemData.submenu)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Escape) {
                if (root.currentLevel > 0) root.popLevel(); else root.close();
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (focusedIndex >= 0 && focusedIndex < rep.count) {
                    var d = rep.itemAt(focusedIndex)
                    if (d) d.activateRow()
                }
                event.accepted = true
            }
        }

        Column {
            id: content
            anchors.margins: 8
            anchors.fill: parent
            spacing: 4
            // content opacity controlled at page level (pageA/pageB)

            // Disable internal header; back pill will be drawn outside the panel
            Item { id: header; width: parent.width; height: 0; visible: false }

            // Shared row delegate used by both pages
            Component {
                id: rowDelegate
                Item {
                    id: rowItem
                    property bool measured: false
                    property var itemData: modelData
                    width: parent.width - 16
                    height: 48
                    property bool hovered: false

                    // full-width hover background (edge-to-edge)
                    Rectangle {
                        id: hoverRect
                        x: -8
                        y: 0
                        width: panel.width
                        height: parent.height
                        color: Palette.isDarkMode() ? Qt.lighter(Palette.palette().surfaceVariant, 1.18) : Qt.darker(Palette.palette().surfaceVariant, 1.08)
                        opacity: hovered ? 1.0 : 0.0
                        radius: 0
                        z: 0
                        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                    }

                    // content container
                    Item {
                        anchors.fill: parent
                        anchors.margins: 8

                        Text {
                            id: label
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: itemData && itemData.label ? itemData.label : ""
                            color: Palette.palette().onSurface
                            font.pixelSize: 15
                            z: 2
                            Component.onCompleted: {
                                if (!rowItem.measured) { rowItem.measured = true; panel.measuredCount++ }
                            }
                            onImplicitWidthChanged: { Qt.callLater(panel.updateSize) }
                        }

                        Text {
                            id: chevron
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !!(itemData && itemData.submenu && itemData.submenu.length > 0)
                            text: "›"
                            color: Palette.palette().onSurfaceVariant
                            font.pixelSize: 16
                            z: 2
                        }
                    }

                    // Activate the row: either trigger action or open submenu (slide)
                    function activateRow() {
                        if (itemData && itemData.enabled === false) return
                        if (itemData && itemData.submenu) openSubmenuAtRow()
                        else { if (itemData && itemData.onTriggered) itemData.onTriggered(); root.close() }
                    }

                    // Deprecated API kept for compatibility
                    function openSubmenuAtRow() {
                        console.log("[HamburgerMenu] openSubmenuAtRow is deprecated; sliding into submenu instead.")
                        if (itemData && itemData.submenu) root.pushLevel(itemData.submenu)
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: { hovered = true }
                        onExited: { hovered = false }
                        onClicked: function(mouse) { activateRow() }
                    }

                }
            }

            // Sliding viewport with two pages
            Item {
                id: viewport
                clip: true
                width: parent.width
                height: Math.max(pageA.implicitHeight, pageB.implicitHeight)

                Column {
                    id: pageA
                    x: 0
                    width: viewport.width
                    spacing: 4
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    Repeater {
                        id: rep
                        model: root.visibleItems || []
                        property int forceActiveDelegate: -1
                        delegate: rowDelegate
                    }
                }

                Column {
                    id: pageB
                    x: viewport.width
                    width: viewport.width
                    spacing: 4
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    Repeater {
                        id: repNext
                        model: root.nextItems || []
                        delegate: rowDelegate
                    }
                }
            }
        }

        function updateSize() {
            // Fully predictive sizing: compute from data, not delegates
            if (!root.open) { panel.visible = false; return }
            panel.maxRowWidth = root._preMeasureMaxRowWidth(root.visibleItems)
            var measuredW = Math.max(root.minWidth, (panel.maxRowWidth > 0 ? panel.maxRowWidth + 36 : panel.width))
            var measuredH = _predictHeight(root.visibleItems)
            panel.width = Math.round(measuredW)
            panel.height = Math.round(measuredH)
            // Clear nextItems after slide to prevent duplicates
            root.nextItems = []
            if (root.width <= 1 || root.height <= 1) { Qt.callLater(panel.updateSize); return }
            // Disable initial position animation to avoid (0,0) slide-in
            var firstShow = !panel.visible
            if (firstShow) panel._suppressPosAnim = true
            panel.x = Math.min(Math.max(0, root.menuX), root.width - panel.width)
            var extra = root.currentLevel > 0 ? (root.backPillHeight + root.backGap) : 0
            panel.y = Math.min(Math.max(extra, root.menuY + extra), root.height - panel.height)
            panel.sized = true
            if (root.open) {
                panel.visible = true
                if (panel.opacity === 0) Qt.callLater(function(){ panel.opacity = 1 })
                // first open: once placed/sized, fade in current page
                if (firstShow) Qt.callLater(function(){ pageA.opacity = 1 })
            }
            // Enable position animation after first placement
            if (firstShow) Qt.callLater(function(){ panel._suppressPosAnim = false; backPillOverlay._suppressAnim = false })
            // no global content fade; per-page opacity handles reveal
        }
    // Removed auto-update on completed to avoid flashing before open

        // watch for root.open to trigger fade-out instead of immediate hide
        Connections {
            target: root
            function onOpenChanged() {
                if (!root.open && panel.sized) {
                    panel.fading = true
                    // animate opacity to 0; Behavior on opacity will animate
                    panel.opacity = 0
                }
            }
        }
        // when opacity becomes 0 and we're in fading state, finalize hide
        onOpacityChanged: {
            if (panel.opacity === 0 && panel.fading && !root.open) {
                panel.visible = false
                panel.fading = false
                panel.sized = false
            }
        }
    }
}
