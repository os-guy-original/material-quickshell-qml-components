import QtQuick 2.15
import "../../colors.js" as Palette
import "../icons" as Icon

Item {
    id: root
    // Android QS-like tile: icon left, two-line label, rounded rect
    property string title: ""
    property string subtitleOn: "On"
    property string subtitleOff: "Off"
    property url iconSource: ""
    property string iconName: ""
    property bool checked: false
    property bool enabled: true
    signal toggled(bool checked)

    readonly property color activeBg: Palette.palette().primary
    readonly property color activeFg: Palette.palette().onPrimary
    readonly property color inactiveBg: Palette.palette().surfaceVariant
    readonly property color inactiveFg: Palette.palette().onSurface
    readonly property color outlineCol: Palette.palette().outline
    // Unified foreground color for icon + primary text
    property color fgColor: checked ? activeFg : inactiveFg

    implicitWidth: Math.max(140, contentRow.implicitWidth + 24)
    implicitHeight: Math.max(56, contentRow.implicitHeight + 16)

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 16
        color: root.checked ? activeBg : inactiveBg
        // No outline in either state per request
        border.width: 0
        opacity: root.enabled ? 1.0 : 0.38
        Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
    }

    Row {
        id: contentRow
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // icon slot
        Item {
            width: 22; height: 22
            anchors.verticalCenter: parent.verticalCenter
            Icon.Icon {
                anchors.fill: parent
                name: root.iconName
                size: 22
                color: root.fgColor
                visible: root.iconName && root.iconName.length > 0
                Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
            }
            Image { anchors.fill: parent; source: root.iconSource; fillMode: Image.PreserveAspectFit; visible: !(root.iconName && root.iconName.length > 0) && root.iconSource !== ""; cache: true; smooth: true }
        }

        Column {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: root.title
                color: root.fgColor
                font.pixelSize: 14
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
            }
            Text {
                text: root.checked ? root.subtitleOn : root.subtitleOff
                color: root.checked ? root.fgColor : Palette.palette().onSurfaceVariant
                font.pixelSize: 12
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
            }
        }
    }

    // hover/press overlay
    Rectangle {
        anchors.fill: parent
        radius: bg.radius
        color: Palette.palette().onSurface
        opacity: mouse.pressed ? 0.14 : (mouse.containsMouse ? 0.06 : 0.0)
        visible: root.enabled
        Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onClicked: { root.checked = !root.checked; root.toggled(root.checked) }
    }
}


