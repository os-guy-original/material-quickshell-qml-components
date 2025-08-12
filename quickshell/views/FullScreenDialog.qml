import QtQuick 2.15
import QtQuick.Window 2.15
import "../resources/colors.js" as Palette
import "../resources/components/actions" as Actions

Window {
    id: fs
    title: "Fullscreen Dialog"
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "transparent"
    modality: Qt.ApplicationModal
    visible: false
    visibility: Window.FullScreen

    property string titleText: "Title"
    property string bodyText: "Message"
    property string primaryText: "OK"
    property string secondaryText: "Cancel"
    property bool dismissible: true
    signal accepted()
    signal rejected()

    // scrim
    Rectangle {
        anchors.fill: parent
        color: Palette.palette().onSurface
        opacity: fs.visible ? 0.32 : 0.0
        visible: true
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
        MouseArea { anchors.fill: parent; enabled: fs.visible && fs.dismissible; onClicked: fs.close() }
    }

    // centered Material card
    Rectangle {
        id: card
        width: Math.max(320, Math.min(520, content.implicitWidth + 32))
        height: content.implicitHeight + 32
        radius: 12
        color: Palette.palette().surface
        anchors.centerIn: parent
        opacity: fs.visible ? 1.0 : 0.0
        scale: fs.visible ? 1.0 : 0.97
        y: fs.visible ? parent.height/2 : parent.height/2 + 8
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
            Text { text: fs.titleText; color: Palette.palette().onSurface; font.pixelSize: 18 }
            Text { text: fs.bodyText; color: Palette.palette().onSurfaceVariant; wrapMode: Text.Wrap; width: card.width - 32 }
            Row {
                spacing: 8
                anchors.right: parent.right
                Actions.Button { text: fs.secondaryText; textButton: true; visible: fs.secondaryText.length > 0; onClicked: { fs.close(); fs.rejected() } }
                Actions.Button { text: fs.primaryText; onClicked: { fs.close(); fs.accepted() } }
            }
        }
    }
}


