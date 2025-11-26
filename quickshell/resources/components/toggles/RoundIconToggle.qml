import QtQuick 2.15
import ".." as Components
import "../icons" as Icon

Item {
    id: root
    property string iconName: ""
    property url iconSource: ""
    property bool checked: false
    property bool enabled: true
    property int diameter: 36
    signal toggled(bool checked)

    readonly property color activeBg: Components.ColorPalette.primary
    readonly property color activeFg: Components.ColorPalette.onPrimary
    readonly property color inactiveBg: Components.ColorPalette.isDarkMode ? Qt.lighter(Components.ColorPalette.surface, 1.08)
                                                            : Qt.darker(Components.ColorPalette.surface, 1.03)
    readonly property color inactiveFg: Components.ColorPalette.onSurface

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight

    Rectangle {
        id: background
        property int baseWidth: root.diameter
        property int expandedWidth: Math.round(root.diameter * 1.25)
        width: root.checked ? expandedWidth : baseWidth
        height: root.diameter
        radius: height / 2
        color: root.checked ? root.activeBg : root.inactiveBg
        border.width: 0
        antialiasing: true
        implicitWidth: width
        implicitHeight: height
        Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
        Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
    }

    // icon
    Item {
        id: iconHolder
        anchors.centerIn: background
        width: Math.round(root.diameter * 0.60)
        height: width

        Icon.Icon {
            anchors.fill: parent
            name: root.iconName
            size: parent.width
            color: root.checked ? root.activeFg : root.inactiveFg
            visible: root.iconName && root.iconName.length > 0
            Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }
        Image {
            anchors.fill: parent
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            visible: !(root.iconName && root.iconName.length > 0) && root.iconSource !== ""
            smooth: true
            cache: true
        }
    }

    // hover/press feedback
    Rectangle {
        anchors.fill: background
        radius: background.radius
        color: Components.ColorPalette.onSurface
        opacity: mouseArea.pressed ? 0.14 : (mouseArea.containsMouse ? 0.06 : 0.0)
        visible: root.enabled
        Behavior on opacity { NumberAnimation { duration: 110; easing.type: Easing.InOutQuad } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: background
        hoverEnabled: true
        enabled: root.enabled
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}


