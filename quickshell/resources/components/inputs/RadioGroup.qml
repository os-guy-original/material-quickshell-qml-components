import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    // Size to contents by default so containers like Column/Dialog can measure us
    width: implicitWidth
    height: implicitHeight
    // Internal reentrancy guard to avoid recursive updates on selection
    property bool _updating: false
    // Guard to avoid work during destruction/teardown
    property bool _destroying: false
    Component.onDestruction: {
        // Detach children from this group to avoid callbacks into a dying object
        var list = []
        function maybeAdd(node) {
            if (!node) return
            if ((node.__isRadioButton === true) || (node.toString && node.toString().indexOf("RadioButton") !== -1)) list.push(node)
        }
        for (var r = 0; r < root.children.length; r++) maybeAdd(root.children[r])
        if (container && container.data) { for (var i = 0; i < container.data.length; i++) maybeAdd(container.data[i]) }
        if (repeaterRow && repeaterRow.children) { for (var j = 0; j < repeaterRow.children.length; j++) maybeAdd(repeaterRow.children[j]) }
        if (repeaterColumn && repeaterColumn.children) { for (var k = 0; k < repeaterColumn.children.length; k++) maybeAdd(repeaterColumn.children[k]) }
        if (repeaterFlow && repeaterFlow.children) { for (var m = 0; m < repeaterFlow.children.length; m++) maybeAdd(repeaterFlow.children[m]) }
        for (var x = 0; x < list.length; x++) {
            var rb = list[x]
            if (rb && rb.hasOwnProperty("group")) rb.group = null
        }
        _destroying = true
    }

    // Holds the current selected value; can be any type
    property var currentValue: undefined
    // Optional name for forms
    property string name: ""
    // Layout orientation: "horizontal" (default) | "vertical"
    property string orientation: "horizontal"
    // Spacing between radios (slightly increased but still compact)
    property int spacing: 4
    // Wrap to next line when horizontal
    property bool wrap: false
    // Line spacing for Flow when wrap is enabled
    property int lineSpacing: 8
    // When true, horizontal layouts will expand to the parent's width (useful for wrapping)
    // Default false to avoid unnecessary growth when parent resizes
    property bool fillWidth: false
    // In compact containers (e.g., dialogs) force radio labels to NOT wrap
    property bool noWrapLabels: false
    // When true, and a width hint is available, expand label width to fill available space
    // while keeping text single-line with ellipsis (works together with noWrapLabels)
    property bool fillLabelWidth: false
    // Children are expected to be RadioButton instances
    default property alias content: container.data

    signal changed(var value)

    // Internal: called by RadioButton when it becomes checked
    function _notifyChecked(radio) {
        if (!radio) return
        if (root._updating) return
        root._updating = true
        // Snapshot selected value (fallback to text when value is undefined)
        root.currentValue = (radio.value !== undefined) ? radio.value : (radio.text !== undefined ? radio.text : null)
        root.changed(root.currentValue)
        // Uncheck all others in this group across all internal containers
        var radios = _collectAllRadios()
        for (var i = 0; i < radios.length; i++) {
            var child = radios[i]
            if (child && child !== radio && child.hasOwnProperty("checked")) {
                child.checked = false
            }
        }
        root._updating = false
    }

    // When currentValue changes programmatically, update matching radio
    onCurrentValueChanged: {
        if (root._updating) return
        root._updating = true
        var radios = _collectAllRadios()
        for (var i = 0; i < radios.length; i++) {
            var child = radios[i]
            if (child && child.hasOwnProperty("value") && child.hasOwnProperty("checked")) {
                child.checked = (child.value === root.currentValue)
            }
        }
        root._updating = false
    }

    // Assign this group to all children that expose a 'group' property
    function _assignGroupToChildren() {
        if (_destroying) return
        var radios = _collectAllRadios()
        for (var i = 0; i < radios.length; i++) {
            var child = radios[i]
            if (child && child.hasOwnProperty("group")) {
                child.group = root
                if (child.hasOwnProperty("value")) {
                    child.checked = (child.value === root.currentValue)
                }
                if (child.hasOwnProperty("checked") && child.checked === true) {
                    root._notifyChecked(child)
                }
            }
        }
    }

    function _collectAllRadios() {
        if (_destroying) return []
        var list = []
        function maybeAdd(node) {
            if (!node) return
            if ((node.__isRadioButton === true) || (node.toString && node.toString().indexOf("RadioButton") !== -1)) list.push(node)
        }
        // Direct children of root (when created imperatively with parent = group)
        for (var r = 0; r < root.children.length; r++) maybeAdd(root.children[r])
        if (container && container.data) { for (var i = 0; i < container.data.length; i++) maybeAdd(container.data[i]) }
        if (repeaterRow && repeaterRow.children) { for (var j = 0; j < repeaterRow.children.length; j++) maybeAdd(repeaterRow.children[j]) }
        if (repeaterColumn && repeaterColumn.children) { for (var k = 0; k < repeaterColumn.children.length; k++) maybeAdd(repeaterColumn.children[k]) }
        if (repeaterFlow && repeaterFlow.children) { for (var m = 0; m < repeaterFlow.children.length; m++) maybeAdd(repeaterFlow.children[m]) }
        return list
    }

    function _currentLayoutItem() {
        if (orientation === "vertical") return repeaterColumn
        if (wrap) return repeaterFlow
        return repeaterRow
    }

    function _adoptChildrenToVisibleContainer() {
        if (_destroying) return
        var target = _currentLayoutItem()
        var radios = _collectAllRadios()
        // Compute metrics. For vertical orientation we won't equalize heights
        var maxH = 0
        var maxBaseline = 0
        var maxLeftLabelWidth = 0
        for (var i = 0; i < radios.length; i++) {
            var rb = radios[i]
            var h = rb.implicitHeight
            if (h > maxH) maxH = h
            var b = Math.max(0, h / 2) // center baseline default
            if (b > maxBaseline) maxBaseline = b
            if (rb.labelPosition && rb.labelPosition === "left") {
                var lw = (rb.labelWrap && rb.labelMaxWidth > 0) ? rb.labelMaxWidth : rb.implicitWidth
                if (lw > maxLeftLabelWidth) maxLeftLabelWidth = lw
            }
        }
        var isVertical = (root.orientation === "vertical")
        var isFlow = (root.orientation !== "vertical" && root.wrap)
        var isRow = (root.orientation !== "vertical" && !root.wrap)
        for (var i = 0; i < radios.length; i++) {
            var rb = radios[i]
            if (rb.parent !== target) rb.parent = target
            // Equalize only for single-row horizontal layout.
            // Vertical and wrap(flow) layouts keep natural heights so line gaps don't grow on resize.
            if (rb.hasOwnProperty("externalHeight")) rb.externalHeight = isRow ? maxH : -1
            if (rb.hasOwnProperty("baselineCenter")) rb.baselineCenter = isRow ? maxBaseline : -1
            if (rb.hasOwnProperty("externalLabelColumnWidth") && rb.labelPosition === "left") rb.externalLabelColumnWidth = maxLeftLabelWidth
            // Provide available width hint so labels can wrap instead of stretching the row
            if (rb.hasOwnProperty("externalAvailableWidth")) {
                var avail = 0
                if (isVertical) {
                    // in vertical layout, Column width is the layout width
                    avail = repeaterColumn.width > 0 ? repeaterColumn.width : root.width
                } else if (isRow) {
                    // in horizontal, if fillWidth is enabled, use that, else don't constrain
                    avail = (root.fillWidth && repeaterRow.width > 0) ? repeaterRow.width : -1
                } else {
                    // flow layout: let each radio size itself; do not force-wrap by width
                    avail = -1
                }
                rb.externalAvailableWidth = avail
            }
            // Apply group-wide wrapping policy for compact containers
            if (rb.hasOwnProperty("autoWrap")) rb.autoWrap = !root.noWrapLabels
            if (rb.hasOwnProperty("labelWrap") && root.noWrapLabels) rb.labelWrap = false
            if (rb.hasOwnProperty("fillLabel")) rb.fillLabel = root.fillLabelWidth
        }
        _assignGroupToChildren()
    }

    // Container to host direct children; must be part of scene graph
    Item {
        id: container
        anchors.left: parent.left
        anchors.top: parent.top
        onChildrenChanged: root._assignGroupToChildren()
        Component.onCompleted: root._assignGroupToChildren()
    }

    // Apply layout depending on orientation for simple Row/Column wrappers
    // If the user provides their own Row/Column, spacing there takes precedence
    states: [
        State {
            name: "vertical"
            when: root.orientation === "vertical"
            PropertyChanges { target: repeaterColumn; visible: true }
            PropertyChanges { target: repeaterRow; visible: false }
            PropertyChanges { target: repeaterFlow; visible: false }
        },
        State {
            name: "horizontal-row"
            when: root.orientation !== "vertical" && !root.wrap
            PropertyChanges { target: repeaterColumn; visible: false }
            PropertyChanges { target: repeaterRow; visible: true }
            PropertyChanges { target: repeaterFlow; visible: false }
        },
        State {
            name: "horizontal-flow"
            when: root.orientation !== "vertical" && root.wrap
            PropertyChanges { target: repeaterColumn; visible: false }
            PropertyChanges { target: repeaterRow; visible: false }
            PropertyChanges { target: repeaterFlow; visible: true }
        }
    ]

    // Lightweight proxy rows to host direct RadioButton children that are not explicitly wrapped
    // Only attaches those items which are direct RadioButton instances
    Row {
        id: repeaterRow
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.fillWidth && parent ? parent.width : implicitWidth
        spacing: root.spacing
        visible: true
        Layout.fillWidth: root.fillWidth
        Layout.preferredWidth: width
        // Adopt direct RadioButton children by reparenting dynamically
        Component.onCompleted: adoptChildren()
        function adoptChildren() {
            root._adoptChildrenToVisibleContainer()
        }
        onChildrenChanged: { if (!root._destroying) root._assignGroupToChildren() }
    }
    Column {
        id: repeaterColumn
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.fillWidth && parent ? parent.width : implicitWidth
        spacing: root.spacing
        visible: false
        Layout.fillWidth: root.fillWidth
        Layout.preferredWidth: width
        Component.onCompleted: adoptChildren()
        function adoptChildren() {
            root._adoptChildrenToVisibleContainer()
        }
        onChildrenChanged: { if (!root._destroying) root._assignGroupToChildren() }
    }
    Flow {
        id: repeaterFlow
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.fillWidth && parent ? parent.width : (root.width > 0 ? root.width : implicitWidth)
        spacing: root.spacing
        flow: Flow.LeftToRight
        visible: false
        Layout.fillWidth: root.fillWidth
        Layout.preferredWidth: width
        Component.onCompleted: adoptChildren()
        function adoptChildren() {
            root._adoptChildrenToVisibleContainer()
        }
        onChildrenChanged: { if (!root._destroying) root._assignGroupToChildren() }
    }

    onOrientationChanged: { if (!_destroying) _adoptChildrenToVisibleContainer() }
    onWrapChanged: { if (!_destroying) _adoptChildrenToVisibleContainer() }
    onWidthChanged: { if (!_destroying) { _adoptChildrenToVisibleContainer() } }
    onChildrenChanged: { if (!_destroying) { _adoptChildrenToVisibleContainer() } }

    // Size to content when width/height not explicitly set
    implicitWidth: repeaterColumn.visible ? repeaterColumn.implicitWidth
                   : (repeaterFlow.visible ? repeaterFlow.implicitWidth : repeaterRow.implicitWidth)
    implicitHeight: repeaterColumn.visible ? repeaterColumn.implicitHeight
                    : (repeaterFlow.visible ? repeaterFlow.implicitHeight : repeaterRow.implicitHeight)
}


