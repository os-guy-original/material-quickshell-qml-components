import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import "../resources/components" as Components
import "../resources/components/actions" as Actions

// Layer-shell based fullscreen overlay dialog (Wayland)
PanelWindow {
    id: layerDlg
    color: "transparent"
    visible: false
    focusable: true
    aboveWindows: true
    anchors { left: true; right: true; top: true; bottom: true }
    margins { left: 0; right: 0; top: 0; bottom: 0 }
    exclusiveZone: 0
    // Prefer overlay layer so it appears above fullscreen windows
    WlrLayershell.layer: WlrLayer.Overlay

    // API
    property string titleText: "Title"
    property string bodyText: "Message"
    property string primaryText: "OK"
    property string secondaryText: "Cancel"
    // Optional third action button
    property string tertiaryText: ""
    // Do not close unless a button is pressed
    property bool dismissible: false
    signal accepted()
    signal rejected()
    signal tertiarySelected()

    // Scrim covers the screen content
    Rectangle {
        anchors.fill: parent
        // Transparent black scrim for dimming effect
        color: Components.ColorPalette.shadow
        opacity: layerDlg.visible ? 0.45 : 0.0
        visible: true
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
        // Do not allow closing via scrim unless explicitly allowed
        MouseArea { anchors.fill: parent; enabled: layerDlg.visible && layerDlg.dismissible; onClicked: if (layerDlg.dismissible) layerDlg.visible = false }
    }

    // Centered Material card
    Rectangle {
        id: card
        width: Math.max(320, Math.min(520, content.implicitWidth + 32))
        height: content.implicitHeight + 32
        radius: 12
        color: Components.ColorPalette.surface
        anchors.centerIn: parent
        opacity: layerDlg.visible ? 1.0 : 0.0
        scale: layerDlg.visible ? 1.0 : 0.97
        y: layerDlg.visible ? parent.height/2 : parent.height/2 + 8
        layer.enabled: true
        layer.smooth: true
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Column {
            id: content
            x: 16
            y: 16
            spacing: 12
            Text { text: layerDlg.titleText; color: Components.ColorPalette.onSurface; font.pixelSize: 18 }
            Text { text: layerDlg.bodyText; color: Components.ColorPalette.onSurfaceVariant; wrapMode: Text.Wrap; width: card.width - 32 }
            Row {
                spacing: 8
                anchors.right: parent.right
                // Tertiary (text) button, shown before others
                Actions.Button { text: layerDlg.tertiaryText; textButton: true; visible: layerDlg.tertiaryText.length > 0; onClicked: { layerDlg.visible = false; layerDlg.tertiarySelected() } }
                Actions.Button { text: layerDlg.secondaryText; textButton: true; visible: layerDlg.secondaryText.length > 0; onClicked: { layerDlg.visible = false; layerDlg.rejected() } }
                Actions.Button { text: layerDlg.primaryText; onClicked: { layerDlg.visible = false; layerDlg.accepted() } }
            }
        }
    }
}


