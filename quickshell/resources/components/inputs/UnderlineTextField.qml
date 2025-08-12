import QtQuick 2.15
import "../../colors.js" as Palette
import "."
import "../Menu/ContextMenuHelper.js" as Ctx

Item {
    id: root
    // API
    property alias text: input.text
    property string placeholderText: ""
    property bool enabled: true
    property bool error: false
    property bool dense: false
    property bool showLeadingIcon: false
    property url leadingIcon: ""
    // Resolve short icon names (e.g. "search") to icons folder automatically
    readonly property url _resolvedLeadingIcon: (function(){
        if (!leadingIcon || leadingIcon === "") return ""
        var s = leadingIcon.toString()
        if (s.indexOf("/") === -1 && s.indexOf(":") === -1) {
            return Qt.resolvedUrl("../../icons/" + s + ".svg")
        }
        return leadingIcon
    })()
    property string helperText: ""
    property bool showHelper: false
    signal accepted(string text)
    // Context menu API
    property bool contextMenuEnabled: true
    // Internal instance holder for overlay
    property Item _contextMenu: null
    function _buildContextItems() { return Ctx.defaultTextInputItems(input) }
    function _openContextFrom(anchorItem, mouseX, mouseY) {
        if (!contextMenuEnabled) { console.log("ULineTF ctx: disabled"); return }
        var items = _buildContextItems()
        Ctx.openMenu(root, anchorItem, mouseX, mouseY, items)
    }

    // Metrics
    readonly property int fieldHeight: dense ? 40 : 48
    readonly property int sidePadding: 0
    implicitWidth: 260
    implicitHeight: fieldHeight + (showHelper || error ? 18 : 0)

    // Field area
    Item {
        id: field
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.fieldHeight

        // Input
        // Clip long text/selection within field height
        Item {
            id: inputClip
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.topMargin: 1
            anchors.bottomMargin: 1
            height: parent.height - 2
            clip: true

            TextInput {
                id: input
                anchors.fill: parent
                leftPadding: showLeadingIcon && leadingIcon !== "" ? 22 : 0
                verticalAlignment: Text.AlignVCenter
                color: error ? Palette.palette().error : Palette.palette().onSurface
                selectionColor: Qt.darker(Palette.palette().primary, 1.8)
                selectByMouse: true
                mouseSelectionMode: TextInput.SelectCharacters
                cursorVisible: activeFocus
                font.pixelSize: 14
                enabled: root.enabled
                onAccepted: root.accepted(text)
            }
        }
        // Right-click context menu on the whole field (place above input)
        MouseArea {
            anchors.fill: parent
            z: 100
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true
            onPressed: function(e) {
                if (e.button !== Qt.RightButton) return
                input.forceActiveFocus()
                try {
                    var pt = mapToItem(input, e.x, e.y)
                    if (input.selectionStart === input.selectionEnd) {
                        input.cursorPosition = input.positionAt(pt.x, pt.y)
                    }
                } catch (err) {}
                console.log("ULineTF RMB: pressed at", e.x, e.y)
                _openContextFrom(field, e.x, e.y)
                e.accepted = true
            }
        }

        // Placeholder shown when empty and unfocused (under input to not block selection)
        Text {
            anchors.left: inputClip.left
            anchors.right: inputClip.right
            anchors.verticalCenter: inputClip.verticalCenter
            color: Palette.palette().onSurfaceVariant
            text: root.placeholderText
            visible: !input.text.length && !input.activeFocus
            font.pixelSize: 14
            elide: Text.ElideRight
            z: 0
        }

        // Leading icon
        Image {
            visible: showLeadingIcon && root._resolvedLeadingIcon !== ""
            source: root._resolvedLeadingIcon
            width: 16; height: 16
            anchors.verticalCenter: inputClip.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 2
            smooth: true
            opacity: root.enabled ? 1.0 : 0.38
        }

        // Underline (inactive)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.darker(Palette.palette().outline, 1.15)
            opacity: root.enabled ? 1.0 : 0.38
        }

        // Underline (active/error)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: error ? Palette.palette().error : Palette.palette().primary
            opacity: input.activeFocus || error ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        }
    }

    // Helper/Error line
    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: field.bottom
        anchors.topMargin: 2
        text: error ? (helperText || "Error") : helperText
        color: error ? Palette.palette().error : Palette.palette().onSurfaceVariant
        visible: error || showHelper
        font.pixelSize: 12
        elide: Text.ElideRight
    }
}


