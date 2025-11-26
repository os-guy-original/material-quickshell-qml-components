import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import ".." as Components
import "../feedback" as Feedback

Item {
    id: root

    property alias text: label.text
    // variants: contained (default), outlined, tonal, text
    property bool outlined: false
    property bool tonal: false
    property bool textButton: false
    property bool enabled: true
    property bool busy: false
    property bool active: false
    // Accent decides contained/outlined/text foreground; default primary
    property color accent: Components.ColorPalette.primary
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
    clip: true
    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    // Animated corner radius - pill when idle or active, sharp when pressed (unless active)
    readonly property real _cornerRadius: (active || !pressed) ? (height / 2) : 4

    // Border (outside masking for outlined buttons)
    Rectangle {
        id: borderRect
        anchors.fill: parent
        radius: root._cornerRadius
        color: "transparent"
        border.width: outlined ? 1 : 0
        border.color: !enabled ? Qt.rgba(0.45,0.45,0.45,1) : (tonal ? Components.ColorPalette.primary : root._accentColor())
        
        Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
    }

    // Background with ripple - using layer.effect for masking
    Item {
        id: background
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: background.width
                height: background.height
                Rectangle {
                    id: maskRect
                    anchors.fill: parent
                    radius: root._cornerRadius
                    smooth: true
                    
                    Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
                }
            }
        }
        
        // Background color
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: !enabled ? Qt.rgba(0.30,0.30,0.30,1) : (outlined || textButton ? "transparent" : (tonal ? Components.ColorPalette.primaryContainer : root._backgroundColor()))
            opacity: 1.0

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        }
        
        // Ripple effect
        Feedback.RippleEffect {
            id: rippleEffect
            rippleColor: root._rippleColor()
        }
    }

    // State overlay to darken on hover/press like Material You
    Rectangle {
        id: stateOverlay
        anchors.fill: parent
        radius: root._cornerRadius
        visible: enabled
        color: textButton || outlined
               ? Components.ColorPalette.onSurface
                : (tonal ? Components.ColorPalette.onPrimaryContainer : (root.kind === "danger" ? Components.ColorPalette.onError : Components.ColorPalette.onPrimary))
        opacity: pressed ? 0.12 : (hovered ? 0.08 : 0.0)
        
        Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: !enabled ? Qt.rgba(0.82,0.82,0.82,1)
             : (textButton ? root._accentColor() : (outlined ? root._accentColor() : (tonal ? Components.ColorPalette.onPrimaryContainer : (root.kind === "danger" ? Components.ColorPalette.onError : Components.ColorPalette.onPrimary))))
        text: "Button"
        font.pixelSize: 14
        opacity: 1.0
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }

    function _accentColor() {
        if (root.kind === "danger") return Components.ColorPalette.error
        if (root.kind === "cancel") return Components.ColorPalette.onSurfaceVariant
        return root.accent
    }
    function _backgroundColor() {
        if (root.kind === "danger") return Components.ColorPalette.error
        if (root.kind === "cancel") return Components.ColorPalette.surfaceVariant
        return root.accent
    }
    function _rippleColor() {
        // Contained button (default): onPrimary
        // Outlined or text button: onSurface
        // Tonal button: onPrimaryContainer
        // Danger button: onError
        if (root.kind === "danger") {
            return Components.ColorPalette.onError
        }
        if (outlined || textButton) {
            return Components.ColorPalette.onSurface
        }
        if (tonal) {
            return Components.ColorPalette.onPrimaryContainer
        }
        return Components.ColorPalette.onPrimary
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onClicked: root.clicked()
        onPressed: {
            if (enabled) {
                root.pressed = true
                rippleEffect.startHold(mouseX, mouseY)
            }
        }
        onReleased: {
            if (enabled) {
                root.pressed = false
                rippleEffect.endHold()
            }
        }
        onCanceled: {
            if (enabled) {
                root.pressed = false
                rippleEffect.endHold()
            }
        }
        onEntered: if (enabled) root.hovered = true
        onExited: if (enabled) { root.hovered = false; root.pressed = false; rippleEffect.endHold() }
    }

    // Optional simple busy indicator dot
    Rectangle {
        visible: busy
        width: 8; height: 8; radius: 4
        color: textButton || outlined ? accent : Components.ColorPalette.onPrimary
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: label.left
        anchors.rightMargin: 8
    }
}
