import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../colors.js" as Palette
import "../icons" as Icon

Item {
    id: root
    property string label: ""
    property url iconSource: ""
    // Optional test icon names: "home", "search", "person"
    property string iconName: ""
    property bool active: false
    // Indicator line position: "bottom", "top", "left", "right"
    property string indicatorPosition: "bottom"
    property int padding: 8
    property int spacing: 4
    property int iconSize: 20
    property color indicatorColor: Palette.palette().primary
    property color activeIconBackground: Palette.palette().secondaryContainer
    property color activeIconColor: Palette.palette().onSecondaryContainer
    property color inactiveIconColor: Palette.palette().onSurface
    signal clicked()

    implicitWidth: Math.max(iconSize + padding * 2, contentCol.implicitWidth + padding * 2)
    implicitHeight: Math.max(iconSize + padding * 2, contentCol.implicitHeight + padding * 2 + indicatorThickness)

    readonly property int indicatorThickness: 3

    // Content stack
    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: padding
        spacing: root.spacing

        // Icon area with optional pill background when active
        Item {
            id: iconWrap
            Layout.alignment: Qt.AlignHCenter
            width: Math.max(iconSize, labelItem.implicitWidth)
            height: iconSize

            Rectangle {
                id: activeBg
                anchors.centerIn: parent
                width: iconSize + 16
                height: iconSize + 8
                radius: height / 2
                color: activeIconBackground
                visible: root.active
                opacity: root.active ? 1 : 0
                scale: root.active ? 1 : 0.8
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
            }

            // Icon priority: iconName (drawn), else iconSource (image)
            Icon.Icon { anchors.centerIn: parent; name: root.iconName; size: iconSize; color: root.active ? activeIconColor : inactiveIconColor; visible: root.iconName !== "" }
            Image { anchors.centerIn: parent; source: iconSource; width: iconSize; height: iconSize; visible: iconSource !== "" && root.iconName === ""; fillMode: Image.PreserveAspectFit; smooth: true }
        }

        // Label (optional)
        Text {
            id: labelItem
            text: root.label
            visible: root.label.length > 0
            color: root.active ? Palette.palette().onSurface : Palette.palette().onSurfaceVariant
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        }
    }

    // Indicator line (primary color)
    Rectangle {
        id: indicator
        color: indicatorColor
        visible: root.active
        anchors {
            left: indicatorLeft
            right: indicatorRight
            top: indicatorTop
            bottom: indicatorBottom
        }
        height: (indicatorPosition === "top" || indicatorPosition === "bottom") ? indicatorThickness : undefined
        width: (indicatorPosition === "left" || indicatorPosition === "right") ? indicatorThickness : undefined
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        // Anchor helpers to keep code short
        readonly property var indicatorLeft: (indicatorPosition === "left") ? parent.left : (indicatorPosition === "right" ? undefined : parent.left)
        readonly property var indicatorRight: (indicatorPosition === "right") ? parent.right : (indicatorPosition === "left" ? undefined : parent.right)
        readonly property var indicatorTop: (indicatorPosition === "top") ? parent.top : undefined
        readonly property var indicatorBottom: (indicatorPosition === "bottom") ? parent.bottom : undefined
    }

    // Hover/press interactions
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}


