import QtQuick 2.15
import "../../colors.js" as Palette
import "../actions" as Actions

Rectangle {
    id: root
    property string title: "Notification"
    property string body: "Message details go here."
    property bool expanded: false
    property bool showActions: true
    property bool dismissible: true
    property bool autoRestore: false
    // Tag to help parent containers detect cards reliably
    property bool isNotificationCard: true
    // If false, chevron and expandable content are hidden
    property bool expandable: (showActions || (body && body.length > 0))
    // Collapse progress used to let following cards slide up while this one dismisses
    property real collapseProgress: 0

    // Ensure background updates when role or progress changes
    onGroupRoleChanged: bg.requestPaint()
    onDismissProgressChanged: bg.requestPaint()
    // Grouping role: controls which corners are fully rounded vs sharp when stacked
    // Allowed: "single", "top", "middle", "bottom"
    property string groupRole: "single"
    // Dismiss progress (0..1) used to morph corners while swiping
    property real dismissProgress: 0
    signal dismissed()
    signal actionClicked(string action)

    radius: 0
    color: "transparent"
    border.width: 0
    layer.enabled: true
    implicitWidth: 360
    readonly property real baseImplicitHeight: content.implicitHeight + 16 * 2
    implicitHeight: Math.max(0, (1.0 - collapseProgress) * baseImplicitHeight)

    // Custom background with per-corner radii and luminous overlay
    Canvas {
        id: bg
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var w = width, h = height
            var round = 16
            var sharp = 2
            function lerp(a,b,t){ return a + (b-a) * Math.max(0, Math.min(1, t)) }
            var baseTL = (root.groupRole === 'single' || root.groupRole === 'top') ? round : sharp
            var baseTR = (root.groupRole === 'single' || root.groupRole === 'top') ? round : sharp
            var baseBL = (root.groupRole === 'single' || root.groupRole === 'bottom') ? round : sharp
            var baseBR = (root.groupRole === 'single' || root.groupRole === 'bottom') ? round : sharp
            if (root.groupRole === 'middle') { baseTL = baseTR = baseBL = baseBR = sharp }
            var rTL = lerp(baseTL, round, root.dismissProgress)
            var rTR = lerp(baseTR, round, root.dismissProgress)
            var rBL = lerp(baseBL, round, root.dismissProgress)
            var rBR = lerp(baseBR, round, root.dismissProgress)
            function roundedRect(tl, tr, br, bl) {
                ctx.beginPath()
                ctx.moveTo(tl, 0)
                ctx.lineTo(w - tr, 0)
                ctx.arcTo(w, 0, w, tr, tr)
                ctx.lineTo(w, h - br)
                ctx.arcTo(w, h, w - br, h, br)
                ctx.lineTo(bl, h)
                ctx.arcTo(0, h, 0, h - bl, bl)
                ctx.lineTo(0, tl)
                ctx.arcTo(0, 0, tl, 0, tl)
                ctx.closePath()
            }
            // base
            ctx.fillStyle = Palette.palette().surface
            roundedRect(rTL, rTR, rBR, rBL)
            ctx.fill()
            // luminous overlay
            ctx.globalAlpha = 0.04
            ctx.fillStyle = Palette.palette().inverseSurface
            roundedRect(rTL, rTR, rBR, rBL)
            ctx.fill()
            ctx.globalAlpha = 1.0
        }
    }

    // swipe-to-dismiss using built-in drag (stable) with corner morphing
    MouseArea {
        id: swipeArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: false
        propagateComposedEvents: true
        preventStealing: true
        drag.target: root
        drag.axis: Drag.XAxis
        drag.minimumX: -root.width
        drag.maximumX: root.width
        drag.filterChildren: true
        onPressed: {
            if (snapBack.running) snapBack.stop()
            if (root.dismissProgress < 0.12) root.dismissProgress = 0.12
            bg.requestPaint()
        }
        onReleased: {
            var farEnough = Math.abs(root.x) > root.width * 0.35
            if (farEnough && root.dismissible) {
                animOut.start()
            } else {
                snapBack.to = 0; snapBack.start()
            }
        }
        onCanceled: { snapBack.to = 0; snapBack.start() }
    }
    NumberAnimation { id: snapBack; target: root; property: "x"; duration: 200; easing.type: Easing.OutCubic; onStopped: { root.dismissProgress = 0; bg.requestPaint() } }
    onXChanged: {
        if (swipeArea.drag.active || snapBack.running || animOut.running) {
            root.dismissProgress = Math.max(0.12, Math.min(1, Math.abs(root.x) / Math.max(1, root.width)))
        }
        bg.requestPaint()
    }
    // Smooth reposition when previous card is removed
    Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        // Header row with avatar, title, chevron, close
        Item {
            id: header
            width: parent.width
            height: Math.max(32, titleText.implicitHeight)

            Rectangle { id: avatar; width: 32; height: 32; radius: 8; color: Palette.palette().primary; opacity: 0.15; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
            Text {
                id: titleText
                text: root.title
                color: Palette.palette().onSurface
                font.pixelSize: 16
                anchors.left: avatar.right
                anchors.leftMargin: 8
                anchors.right: closeBtn.left
                anchors.rightMargin: 8
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
            // Chevron toggle
            Rectangle {
                id: chevronBtn
                width: 24; height: 24; radius: 12
                color: 'transparent'
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.expandable
                rotation: root.expanded ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
                Canvas {
                    anchors.centerIn: parent
                    width: 12; height: 12
                    onPaint: {
                        var ctx = getContext('2d'); ctx.reset();
                        ctx.strokeStyle = Palette.palette().onSurfaceVariant; ctx.lineWidth = 2; ctx.lineCap = 'round';
                        ctx.beginPath(); ctx.moveTo(1,4); ctx.lineTo(6,9); ctx.lineTo(11,4); ctx.stroke();
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: root.expanded = !root.expanded; hoverEnabled: true }
            }
            // Close small X
            Rectangle {
                id: closeBtn
                width: 24; height: 24; radius: 12
                color: 'transparent'
                anchors.right: chevronBtn.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                Canvas {
                    anchors.centerIn: parent
                    width: 12; height: 12
                    onPaint: { var ctx = getContext('2d'); ctx.reset(); ctx.strokeStyle = Palette.palette().onSurfaceVariant; ctx.lineWidth = 2; ctx.beginPath(); ctx.moveTo(2,2); ctx.lineTo(10,10); ctx.moveTo(10,2); ctx.lineTo(2,10); ctx.stroke(); }
                }
                MouseArea { anchors.fill: parent; onClicked: if (root.dismissible) animOut.start(); hoverEnabled: true }
            }
        }

        // Expanding content area (body + actions)
        Item {
            id: expander
            width: parent.width
            clip: true
            visible: root.expandable
            height: root.expanded ? expanderContent.implicitHeight : 0
            Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }

            Column {
                id: expanderContent
                width: parent.width
                spacing: 8
                Text { text: root.body; color: Palette.palette().onSurfaceVariant; wrapMode: Text.Wrap }
                Row {
                    spacing: 8
                    visible: root.showActions
                    Actions.Button { text: "ACTION"; textButton: true; onClicked: root.actionClicked(text) }
                    Actions.Button { text: "DISMISS"; textButton: true; onClicked: root.actionClicked(text) }
                }
            }
        }
    }

    SequentialAnimation {
        id: animOut
        PropertyAnimation { target: root; properties: "scale"; to: 0.92; duration: 110; easing.type: Easing.InOutQuad }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0.0; duration: 140 }
            NumberAnimation { target: root; property: "x"; to: root.x > 0 ? root.width : -root.width; duration: 160; easing.type: Easing.InOutQuad }
            // Collapse height so following cards slide into place smoothly
            NumberAnimation { target: root; property: "collapseProgress"; to: 1.0; duration: 160; easing.type: Easing.InOutQuad }
        }
        onFinished: {
            root.dismissed()
            if (root.autoRestore) {
                root.x = 0
                root.scale = 0.96
                root.opacity = 0.0
                root.collapseProgress = 0
                animIn.start()
            } else {
                root.destroy()
            }
        }
    }

    ParallelAnimation {
        id: animIn
        NumberAnimation { target: root; property: "opacity"; to: 1.0; duration: 160; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.OutCubic }
    }
}


