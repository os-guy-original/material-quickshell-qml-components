import QtQuick 2.15
import "../../colors.js" as Palette
import "."
import "../Menu/ContextMenuHelper.js" as Ctx

Item {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    // Floating label (outlined) like Material You
    property bool useFloatingLabel: true
    property string labelText: ""
    property real labelFontSize: 14
    property real floatingFontSize: 12
    property bool floating: input.activeFocus || input.text.length > 0
    property bool enabled: true
    property bool filled: false
    property bool error: false
    // Context menu API
    property bool contextMenuEnabled: true
    // Internal instance holder for overlay
    property Item _contextMenu: null
    function _buildContextItems() {
        return Ctx.defaultTextInputItems(input)
    }
    function _openContextFrom(anchorItem, mouseX, mouseY) {
        if (!contextMenuEnabled) { console.log("TF ctx: disabled"); return }
        var items = _buildContextItems()
        Ctx.openMenu(root, anchorItem, mouseX, mouseY, items)
    }
    signal accepted(string text)

    // Visual height of the field box (excludes helper/error text)
    property int fieldHeight: 44
    implicitWidth: 240
    // Reserve space for helper/error text so following content doesn't overlap
    implicitHeight: fieldHeight + ((root.error && errorLabel.text.length > 0) ? (errorLabel.implicitHeight + 4) : 0)

    Rectangle {
        id: background
        z: 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.fieldHeight
        radius: 12
        color: filled ? Palette.palette().surfaceVariant : Palette.palette().surface
        border.width: 1.2
        border.color: error ? Palette.palette().error : (input.activeFocus ? Palette.palette().primary : (Palette.palette().isDarkMode ? Qt.lighter(Palette.palette().outline, 1.3) : Qt.darker(Palette.palette().outline, 1.3)))
        opacity: enabled ? 1.0 : 0.38
        Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }

    // Clip long text and selection highlight to the field bounds
    Item {
        id: inputClip
        z: 2
        anchors.fill: background
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        clip: true

        TextInput {
            id: input
            anchors.fill: parent
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

    // Floating Label and Notch for outlined variant
    Item {
        id: labelLayer
        anchors.left: background.left
        anchors.right: background.right
        anchors.top: background.top
        anchors.bottom: background.bottom
        visible: useFloatingLabel && !filled
        clip: false
        // Keep under TextInput so text selection highlight is not obscured
        z: 1

        // Erase a notch from the border when floating
        // Keep it always visible and animate width so the notch fills slightly slower on blur
        Rectangle {
            id: notchEraser
            visible: true
            color: background.color
            height: floatingLabel.height
            width: root.floating ? (floatingLabel.paintedWidth + 12) : 0
            radius: 4
            x: floatingLabel.x - 6
            y: -1
            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }

        // Hidden measurement label (not rendered) to drive notch size/position bindings
        Text {
            id: floatingLabel
            visible: false
            text: (root.labelText && root.labelText.length) ? root.labelText : root.placeholderText
            color: root.error ? Palette.palette().error : (input.activeFocus ? Palette.palette().primary : Palette.palette().onSurfaceVariant)
            x: 12
            y: root.floating ? -height / 2 - 1 : (background.height - height) / 2
            font.pixelSize: root.floating ? floatingFontSize : labelFontSize
            elide: Text.ElideRight
            z: 3
            Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            Behavior on font.pixelSize { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        }
    }

    // Visible floating label drawn above the TextInput to avoid overlap during selection
    Text {
        id: floatingLabelOverlay
        visible: useFloatingLabel && !filled
        text: (root.labelText && root.labelText.length) ? root.labelText : root.placeholderText
        color: root.error ? Palette.palette().error : (input.activeFocus ? Palette.palette().primary : Palette.palette().onSurfaceVariant)
        x: 12
        y: root.floating ? -height / 2 - 1 : (background.height - height) / 2
        font.pixelSize: root.floating ? floatingFontSize : labelFontSize
        elide: Text.ElideRight
        z: 3
        Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        Behavior on font.pixelSize { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }

    // Focus on click anywhere in the field
    // Left-click focus and allow drag selection (below TextInput)
    MouseArea {
        anchors.fill: background
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        propagateComposedEvents: true
        onPressed: function(mouse) { input.forceActiveFocus(); mouse.accepted = false }
    }

    // Right-click context menu catcher (above TextInput so it always receives RMB)
    MouseArea {
        anchors.fill: background
        z: 100
        acceptedButtons: Qt.RightButton
        hoverEnabled: false
        cursorShape: Qt.IBeamCursor
        propagateComposedEvents: true
        onPressed: function(mouse) {
            if (mouse.button !== Qt.RightButton) { console.log("TF RMB: ignored button", mouse.button); return }
            input.forceActiveFocus()
            try {
                var pt = mapToItem(input, mouse.x, mouse.y)
                if (input.selectionStart === input.selectionEnd) {
                    input.cursorPosition = input.positionAt(pt.x, pt.y)
                }
            } catch (e) {}
            console.log("TF RMB: pressed at", mouse.x, mouse.y)
            _openContextFrom(background, mouse.x, mouse.y)
            mouse.accepted = true
        }
    }

    // Helper error text slot
    property alias errorText: errorLabel.text
    Text {
        id: errorLabel
        anchors.top: background.bottom
        anchors.left: parent.left
        anchors.topMargin: 4
        color: Palette.palette().error
        font.pixelSize: 12
        visible: root.error && text.length > 0
        text: ""
    }
}


