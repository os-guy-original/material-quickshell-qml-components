import QtQuick 2.15
import "../../colors.js" as Palette
import "."
import "../Menu/ContextMenuHelper.js" as Ctx
import "../feedback" as Feedback

Item {
    id: root
    // API
    property string text: ""
    
    onTextChanged: {
        if (multiline && textArea.text !== text) textArea.text = text
        else if (!multiline && input.text !== text) input.text = text
    }
    
    Connections {
        target: input
        function onTextChanged() { if (!multiline) root.text = input.text }
    }
    
    Connections {
        target: textArea
        function onTextChanged() { if (multiline) root.text = textArea.text }
    }
    property string placeholderText: ""
    property string labelText: ""
    property bool enabled: true
    property bool error: false
    property bool dense: false
    property bool multiline: false
    property bool showLeadingIcon: false
    property string leadingIconText: "\uE8B6"  // search icon unicode
    property bool showTrailingIcon: false
    property string trailingIconText: "\uE5CD"  // close icon
    property string prefixText: ""
    property string suffixText: ""
    property bool floating: (multiline ? textArea.activeFocus || textArea.text.length > 0 : input.activeFocus || input.text.length > 0)
    
    signal trailingIconClicked()

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
    readonly property int fieldHeight: multiline ? Math.max(56, textArea.contentHeight + 32) : (dense ? 40 : 48)
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

        // Background fill
        Rectangle {
            id: background
            anchors.fill: parent
            color: Palette.palette().surfaceVariant
            opacity: root.enabled ? 1.0 : 0.5
            clip: true
            
            // Ripple effect
            Feedback.RippleEffect {
                id: rippleEffect
                anchors.fill: parent
                rippleColor: Palette.palette().primary
                rippleDuration: 400
            }
        }
        
        // Click area to trigger ripple and focus
        MouseArea {
            id: clickArea
            anchors.fill: parent
            z: 5
            onPressed: function(mouse) {
                if (!input.activeFocus && !textArea.activeFocus) {
                    rippleEffect.trigger(mouse.x, mouse.y)
                }
                if (multiline) {
                    textArea.forceActiveFocus()
                    var pt = mapToItem(textArea, mouse.x, mouse.y)
                    textArea.cursorPosition = textArea.positionAt(pt.x, pt.y)
                } else {
                    input.forceActiveFocus()
                    var pt = mapToItem(input, mouse.x, mouse.y)
                    input.cursorPosition = input.positionAt(pt.x, pt.y)
                }
                mouse.accepted = false
            }
        }

        // Input row with prefix/suffix
        Row {
            id: inputRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: multiline ? 24 : 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.leftMargin: showLeadingIcon ? 40 : 16
            anchors.rightMargin: showTrailingIcon ? 40 : 16
            spacing: 4
            
            // Prefix text
            Text {
                visible: prefixText !== ""
                text: prefixText
                color: Palette.palette().onSurfaceVariant
                font.pixelSize: 14
                anchors.bottom: parent.bottom
            }
            
            // Input clip area
            Item {
                id: inputClip
                width: parent.width - (prefixText !== "" ? prefixLabel.width + 4 : 0) - (suffixText !== "" ? suffixLabel.width + 4 : 0)
                height: parent.height
                clip: true
                
                // Single line input
                TextInput {
                    id: input
                    visible: !multiline
                    anchors.fill: parent
                    verticalAlignment: Text.AlignBottom
                    color: error ? Palette.palette().error : Palette.palette().onSurface
                    selectionColor: Qt.darker(Palette.palette().primary, 1.8)
                    selectByMouse: true
                    mouseSelectionMode: TextInput.SelectCharacters
                    cursorVisible: activeFocus
                    font.pixelSize: 14
                    enabled: root.enabled
                    onAccepted: root.accepted(text)
                }
                
                // Multi-line input
                TextEdit {
                    id: textArea
                    visible: multiline
                    anchors.fill: parent
                    color: error ? Palette.palette().error : Palette.palette().onSurface
                    selectionColor: Qt.darker(Palette.palette().primary, 1.8)
                    selectByMouse: true
                    font.pixelSize: 14
                    enabled: root.enabled
                    wrapMode: TextEdit.Wrap
                }
            }
            
            // Suffix text
            Text {
                id: suffixLabel
                visible: suffixText !== ""
                text: suffixText
                color: Palette.palette().onSurfaceVariant
                font.pixelSize: 14
                anchors.bottom: parent.bottom
            }
            
            // Hidden prefix for width calculation
            Text {
                id: prefixLabel
                visible: false
                text: prefixText
                font.pixelSize: 14
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

        // Floating label
        Text {
            id: floatingLabel
            anchors.left: parent.left
            anchors.leftMargin: showLeadingIcon ? 40 : 16
            y: root.floating ? 5 : (field.height - height) / 2
            text: (root.labelText && root.labelText.length) ? root.labelText : root.placeholderText
            color: root.error ? Palette.palette().error : ((multiline ? textArea.activeFocus : input.activeFocus) ? Palette.palette().primary : Palette.palette().onSurfaceVariant)
            font.pixelSize: root.floating ? 10 : 14
            elide: Text.ElideRight
            z: 10
            
            Behavior on y {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            Behavior on font.pixelSize {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }

        // Leading icon
        Text {
            visible: showLeadingIcon
            text: leadingIconText
            font.family: "Material Symbols Outlined"
            font.pixelSize: 20
            color: Palette.palette().onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            opacity: root.enabled ? 1.0 : 0.38
        }
        
        // Trailing icon
        Text {
            visible: showTrailingIcon
            text: trailingIconText
            font.family: "Material Symbols Outlined"
            font.pixelSize: 20
            color: Palette.palette().onSurfaceVariant
            opacity: root.enabled ? 1.0 : 0.38
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 2
            anchors.right: parent.right
            anchors.rightMargin: 12
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: root.trailingIconClicked()
            }
        }

        // Underline (inactive)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Palette.palette().isDarkMode ? Qt.lighter(Palette.palette().onSurfaceVariant, 1.2) : Qt.darker(Palette.palette().onSurfaceVariant, 1.2)
            opacity: root.enabled ? 1.0 : 0.38
        }

        // Underline (active/error) - Material You ripple from center
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            clip: true
            
            Rectangle {
                id: activeUnderline
                anchors.verticalCenter: parent.verticalCenter
                height: 2
                color: error ? Palette.palette().error : Palette.palette().primary
                
                // Material You: expand from center
                property real expandProgress: (multiline ? textArea.activeFocus : input.activeFocus) || error ? 1.0 : 0.0
                width: parent.width * expandProgress
                x: parent.width / 2 - width / 2
                
                Behavior on expandProgress {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // Helper/Error line
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
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


