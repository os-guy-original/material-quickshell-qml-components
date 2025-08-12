import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../colors.js" as Palette

Item {
    id: root
    // Do not clip so hover overlays render fully within our padded bounds
    clip: false
    // Raise hovered/pressed/checked radios above siblings so overlay isn't occluded
    z: (hovered || pressed) ? 10 : (checked ? 5 : 0)

    // Public API
    property bool checked: false
    property bool enabled: true
    property string text: ""
    property var value: undefined
    // Visual customization
    property color accent: Palette.palette().primary
    // "right" (default) | "left"
    property string labelPosition: "right"
    // Wrapping support for long labels
    property bool labelWrap: false
    // When > 0 and labelWrap is true, label will wrap to this maximum width
    property int labelMaxWidth: -1
    // When true, and a width hint is provided externally, use the full available width for label
    // while keeping text single-line and elided (for compact containers like dialogs)
    property bool fillLabel: false
    // Compact sizing
    property bool dense: false
    // Show in error accent (e.g., form validation)
    property bool error: false
    // Optional grouping (assign to a RadioGroup instance)
    property var group: null

    // State flags
    property bool hovered: false
    property bool pressed: false

    signal toggled(bool checked)

    // Identification flag for RadioGroup discovery
    readonly property bool __isRadioButton: true

    // External height override (used by RadioGroup to equalize row height)
    property int externalHeight: -1
    // External baseline center within the item (used by RadioGroup to align controls/labels)
    property int baselineCenter: -1
    // External label column width when label is on the left (group-level alignment)
    property int externalLabelColumnWidth: -1
    // When placed in a vertical RadioGroup that wants children to fill width,
    // group can tell us the available width so we can wrap label text gracefully
    property int externalAvailableWidth: -1
    // Auto-wrap label when there is an externalAvailableWidth
    property bool autoWrap: true

    readonly property int controlSize: dense ? 16 : 18
    readonly property int innerDotSize: dense ? 8 : 10

    readonly property int _labelWidthHint: (labelWrap && labelMaxWidth > 0)
                                           ? labelMaxWidth
                                           : label.implicitWidth
    readonly property int _effectiveLabelWidth: (externalLabelColumnWidth > 0)
                                                ? externalLabelColumnWidth
                                                : _labelWidthHint
    readonly property int _baseImplicitHeight: Math.max(controlSize, labelWrap ? label.paintedHeight : label.height)
    // Ensure layout containers (Flow/Row/Column) get concrete size
    // Ensure good behavior inside QtQuick.Layouts containers
    Layout.fillWidth: false
    // Reserve space for hover background around control to avoid container collapse on hover
    readonly property int _extraTextHeight: Math.max(0, (labelWrap ? label.paintedHeight : label.height) - controlSize)
    // Ensure hover overlay (controlSize + 10) never gets clipped by our bounds
    // overlay extra radius is 5px; keep a bit larger margin for safety
    readonly property int _hoverPadding: 6
    readonly property int _labelGap: 6
    // Fallback text metrics to avoid transient 0-width during first layout
    TextMetrics { id: _tm; text: root.text; font: label.font }
    readonly property int _labelWidthSafe: Math.max(_labelWidthHint, Math.round(_tm.width))
    // Use safe label width to avoid zero-size/overlap in parent Row/Flow
    implicitWidth: (labelPosition === "left"
                    ? (_labelWidthSafe + _labelGap + controlSize)
                    : (controlSize + _labelGap + _labelWidthSafe)) + _hoverPadding*2
    // In vertical groups the RadioGroup will reset externalHeight to -1 so
    // our implicitHeight stays natural and does not stretch on parent resize
    implicitHeight: (externalHeight > 0 ? externalHeight : _baseImplicitHeight) + _hoverPadding*2
    // Allow group to override width when providing available width (for wrapping)
    width: externalAvailableWidth > 0 ? externalAvailableWidth : implicitWidth
    height: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    // (removed duplicate implicitWidth assignment)

    // Keep checked true when clicked; radios do not uncheck on re-click
    onCheckedChanged: {
        if (checked && group && group._notifyChecked) {
            group._notifyChecked(root)
        }
    }

    // Manual layout: avoids anchors/Row within Column conflicts
    Item {
        id: content
        anchors.fill: parent
        anchors.margins: _hoverPadding

        // Control (outer ring + inner dot + state overlay)
        Item {
            id: control
            width: controlSize
            height: controlSize
            x: (labelPosition === "left") ? (_effectiveLabelWidth + _labelGap) : 0
            y: baselineCenter >= 0 ? Math.max(0, baselineCenter - height / 2)
                                   : Math.max(0, (root.height - height) / 2)

            Rectangle {
                id: ring
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: !root.enabled
                              ? Qt.rgba(0.5,0.5,0.5,1)
                              : (root.checked
                                 ? (root.error ? Palette.palette().error : root.accent)
                                 : Palette.palette().onSurfaceVariant)
                opacity: 1.0
                Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }

            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: innerDotSize
                height: innerDotSize
                radius: width / 2
                visible: root.checked
                color: !root.enabled
                       ? Qt.rgba(0.72,0.72,0.72,1)
                       : (root.error ? Palette.palette().error : root.accent)
                scale: root.checked ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }

            Rectangle {
                id: stateOverlay
                anchors.centerIn: parent
                width: controlSize + 10
                height: controlSize + 10
                radius: width / 2
                color: root.checked
                       ? (root.error ? Palette.palette().onErrorContainer : Palette.palette().onPrimary)
                       : Palette.palette().onSurface
                opacity: root.enabled ? (root.pressed ? 0.12 : (root.hovered ? 0.08 : 0.0)) : 0.0
                Behavior on opacity { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
            }
        }

        // Label
        Text {
            id: label
            text: root.text
            color: root.enabled ? Palette.palette().onSurface : Qt.rgba(0.75,0.75,0.75,1)
            font.pixelSize: 14
            wrapMode: (root.labelWrap || (root.autoWrap && root.externalAvailableWidth > 0)) ? Text.WordWrap : Text.NoWrap
            // Compute a dynamic width when auto-wrapping is enabled or when labelWrap+labelMaxWidth provided
            readonly property int _autoWidth: (root.externalAvailableWidth > 0)
                ? Math.max(0, root.externalAvailableWidth - root.controlSize - root._labelGap - root._hoverPadding*2)
                : -1
            width: (labelPosition === "left")
                     ? ((root.autoWrap && _autoWidth > 0 && root.externalLabelColumnWidth <= 0)
                        ? Math.min(_autoWidth, _effectiveLabelWidth)
                        : (root.fillLabel && _autoWidth > 0 ? _autoWidth : _effectiveLabelWidth))
                     : ((root.labelWrap && root.labelMaxWidth > 0)
                        ? root.labelMaxWidth
                        : ((root.autoWrap && _autoWidth > 0)
                            ? (root.fillLabel ? _autoWidth : _autoWidth)
                            : (root.fillLabel && _autoWidth > 0 ? _autoWidth : implicitWidth)))
            x: (labelPosition === "left") ? 0 : (controlSize + _labelGap)
            y: baselineCenter >= 0 ? Math.max(0, baselineCenter - height / 2)
                                   : Math.max(0, (root.height - height) / 2)
            elide: Text.ElideRight
            maximumLineCount: (wrapMode === Text.NoWrap ? 1 : 0)
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (!root.checked) {
                root.checked = true
                root.toggled(true)
            }
        }
        onPressedChanged: if (enabled) root.pressed = pressed
        onEntered: if (enabled) root.hovered = true
        onExited: if (enabled) { root.hovered = false; root.pressed = false }
    }
}


