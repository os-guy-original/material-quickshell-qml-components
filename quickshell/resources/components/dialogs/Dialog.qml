import QtQuick 2.15
import "../../colors.js" as Palette
import "../actions" as Actions
import "../DialogService.js" as DialogService
// Ensure local components (e.g., Button.qml) are available
import "."

Item {
    id: root
    property bool open: false
    property string title: "Title"
    property string text: "Message"
    property string primaryText: "OK"
    property string secondaryText: "Cancel"
    property bool dismissible: false
    // Increase padding and maxWidth to more closely match Android Material dialog sizes
    property int padding: 20
    property int maxWidth: 560
    // If > 0, dialog content width is forced to this value (inside padding)
    property int preferredWidth: -1
    // Internal helper for measuring content without causing binding loops
    readonly property int _contentWidthLimit: (preferredWidth > 0
                                              ? Math.max(0, preferredWidth - padding * 2)
                                              : Math.max(0, maxWidth - padding * 2))
    property bool _closing: false
    property var _onAccepted: null
    property var _onRejected: null
    signal accepted()
    signal rejected()

    // Public slot for custom content
    // Anything assigned to this container will appear between body text and actions
    property alias contentContainer: extraContainer
    // Allow placing arbitrary children inside Dialog { ... }
    default property alias contentData: extraContainer.data

    anchors.fill: parent
    visible: open || _closing
    z: 999
    Keys.onEscapePressed: if (dismissible) open = false
    Component.onCompleted: DialogService.register(root)

    // scrim
        Rectangle {
            anchors.fill: parent
            color: Palette.palette().onSurface
            opacity: root.open ? 0.32 : 0.0
            visible: true
            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                // Always swallow outside clicks; never close dialog via scrim
                enabled: root.open
                onClicked: function(mouse) { mouse.accepted = true }
                onPressed: function(mouse) { mouse.accepted = true }
            }
        }

    // dialog surface
        Rectangle {
        id: card
    width: root.preferredWidth > 0
         ? Math.max(280, root.preferredWidth)
         : Math.max(320, Math.min(root.maxWidth, content.implicitWidth + root.padding * 2))
        height: content.implicitHeight + root.padding * 2
        radius: 12
        color: Palette.palette().surface
        anchors.centerIn: parent
        opacity: root.open ? 1.0 : 0.0
        scale: root.open ? 1.0 : 0.97
        y: root.open ? parent.height/2 : parent.height/2 + 8
        layer.enabled: true
        layer.smooth: true
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        
        // Swallow clicks on empty areas of the card so the scrim behind doesn't close the dialog
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: false
            propagateComposedEvents: false
            onClicked: {/* swallow */}
            onPressed: {/* swallow */}
        }

        Column {
            id: content
            x: root.padding
            y: root.padding
            spacing: 12
            Text { id: titleLabel; text: root.title; color: Palette.palette().onSurface; font.pixelSize: 18 }
            Text {
                id: bodyText
                text: root.text
                color: Palette.palette().onSurfaceVariant
                wrapMode: Text.Wrap
                // Avoid binding loop: when preferredWidth <= 0, measure against max width, not card.width
                width: (root.preferredWidth > 0)
                       ? Math.max(0, card.width - root.padding * 2)
                       : root._contentWidthLimit
            }
            // Custom content slot
            Item {
                id: extraContainer
                // When preferredWidth is set, fill card. Otherwise, use measurement limit
                width: (root.preferredWidth > 0)
                       ? Math.max(0, card.width - root.padding * 2)
                       : root._contentWidthLimit
                height: childrenRect.height
                implicitWidth: width
                implicitHeight: height
            }
            Item {
                width: Math.max(titleLabel.implicitWidth, bodyText.width)
                height: actions.implicitHeight
                Row {
                    id: actions
                    x: parent.width - actions.implicitWidth
                    spacing: 8
                    Actions.Button { text: root.secondaryText; textButton: true; visible: root.secondaryText.length > 0; onClicked: { root.close(); root.rejected(); if (root._onRejected) root._onRejected() } }
                    Actions.Button { text: root.primaryText; onClicked: { root.close(); root.accepted(); if (root._onAccepted) root._onAccepted() } }
                }
            }
        }
    }

    function close() {
        if (!_closing && open) {
            _closing = true
            open = false
            closeFinisher.start()
        } else {
            open = false
        }
    }

    Timer {
        id: closeFinisher
        interval: 220
        repeat: false
        onTriggered: {
            // Clear deferred event handlers to avoid stale callbacks after dialog is closed
            root._closing = false
        }
    }
}


