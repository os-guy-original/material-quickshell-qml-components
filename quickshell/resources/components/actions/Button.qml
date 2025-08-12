import QtQuick 2.15
import "../../colors.js" as Palette

Item {
    id: root

    property alias text: label.text
    // variants: contained (default), outlined, tonal, text
    property bool outlined: false
    property bool tonal: false
    property bool textButton: false
    property bool enabled: true
    property bool busy: false
    // Accent decides contained/outlined/text foreground; default primary
    property color accent: Palette.palette().primary
    // Semantic variants: "default" | "cancel" | "danger"
    property string kind: "default"
    property bool hovered: false
    property bool pressed: false
    signal clicked()
    readonly property int _collapsedHeight: 40
    readonly property int _collapsedWidth: Math.max(100, label.implicitWidth + 24 * 2)
    implicitHeight: _collapsedHeight
    implicitWidth: _collapsedWidth

    // Optional subtle morph when menuOpen
    width: _collapsedWidth
    height: _collapsedHeight
    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: height / 2
        color: !enabled ? Qt.rgba(0.30,0.30,0.30,1) : (outlined || textButton ? "transparent" : (tonal ? Palette.palette().secondaryContainer : root._backgroundColor()))
        border.width: outlined ? 1 : 0
        border.color: !enabled ? Qt.rgba(0.45,0.45,0.45,1) : (tonal ? Palette.palette().secondary : root._accentColor())
        opacity: 1.0

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        Behavior on radius { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    // State overlay to darken on hover/press like Material You
    Rectangle {
        id: stateOverlay
        anchors.fill: background
        radius: background.radius
        visible: enabled
        color: textButton || outlined
               ? Palette.palette().onSurface
                : (tonal ? Palette.palette().onSecondaryContainer : (root.kind === "danger" ? Palette.palette().onError : Palette.palette().onPrimary))
        opacity: pressed ? 0.12 : (hovered ? 0.08 : 0.0)
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: !enabled ? Qt.rgba(0.82,0.82,0.82,1)
             : (textButton ? root._accentColor() : (outlined ? root._accentColor() : (tonal ? Palette.palette().onSecondaryContainer : (root.kind === "danger" ? Palette.palette().onError : Palette.palette().onPrimary))))
        text: "Button"
        font.pixelSize: 14
        opacity: 1.0
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }

    function _accentColor() {
        if (root.kind === "danger") return Palette.palette().error
        if (root.kind === "cancel") return Palette.palette().onSurfaceVariant
        return root.accent
    }
    function _backgroundColor() {
        if (root.kind === "danger") return Palette.palette().error
        if (root.kind === "cancel") return Qt.rgba(0,0,0,0) // transparent for text/outlined by default
        return root.accent
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onClicked: root.clicked()
        onPressedChanged: if (enabled) root.pressed = pressed
        onEntered: if (enabled) root.hovered = true
        onExited: if (enabled) { root.hovered = false; root.pressed = false }
    }

    // Optional simple busy indicator dot
    Rectangle {
        visible: busy
        width: 8; height: 8; radius: 4
        color: textButton || outlined ? accent : Palette.palette().onPrimary
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: label.left
        anchors.rightMargin: 8
    }

    
}


