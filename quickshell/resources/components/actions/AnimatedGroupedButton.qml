import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import ".." as Components
import "../feedback" as Feedback

Item {
    id: root

    property alias text: label.text
    property bool outlined: false
    property bool tonal: false
    property bool textButton: false
    property bool enabled: true
    property bool busy: false
    property color accent: Components.ColorPalette.primary
    property string kind: "default"
    property bool hovered: false
    property bool pressed: false
    signal clicked()
    
    // Grouped button properties
    property int baseWidth: 295
    property int expandAmount: 30
    property var siblingButton: null
    
    readonly property int _targetWidth: pressed ? (baseWidth + expandAmount) : ((siblingButton && siblingButton.pressed) ? (baseWidth - expandAmount) : baseWidth)
    
    implicitHeight: 60
    implicitWidth: baseWidth
    width: _targetWidth
    height: 60
    clip: true
    
    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.InOutCubic } }

    readonly property real _cornerRadius: pressed ? 4 : (height / 2)

    Rectangle {
        id: borderRect
        anchors.fill: parent
        radius: root._cornerRadius
        color: "transparent"
        border.width: outlined ? 1 : 0
        border.color: !enabled ? Qt.rgba(0.45,0.45,0.45,1) : (tonal ? Components.ColorPalette.primary : root._accentColor())
        
        Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
    }

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
                    anchors.fill: parent
                    radius: root._cornerRadius
                    smooth: true
                    
                    Behavior on radius { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }
                }
            }
        }
        
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: !enabled ? Qt.rgba(0.30,0.30,0.30,1) : (outlined || textButton ? "transparent" : (tonal ? Components.ColorPalette.primaryContainer : root._backgroundColor()))
            opacity: 1.0

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        }
        
        Feedback.RippleEffect {
            id: rippleEffect
            rippleColor: root._rippleColor()
        }
    }

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

    Rectangle {
        visible: busy
        width: 8; height: 8; radius: 4
        color: textButton || outlined ? accent : Components.ColorPalette.onPrimary
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: label.left
        anchors.rightMargin: 8
    }
}
