import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Components

Item {
    id: root
    // Content
    property string title: "Title"
    property string subtitle: ""
    property url iconSource: ""
    // Behavior
    property bool clickable: true
    property bool enabled: true
    signal clicked()

    // Grouped corner behavior like notifications
    // Allowed: "single", "top", "middle", "bottom"
    property string groupRole: "single"
    onGroupRoleChanged: { bg.requestPaint(); stateOverlay.requestPaint() }

    // Layout
    property int padding: 16
    implicitWidth: Math.max(280, contentRow.implicitWidth + padding * 2)
    implicitHeight: Math.max(56, contentRow.implicitHeight + padding * 2)
    
    // Animation state
    property bool _pressed: false
    property real _animProgress: 0.0
    
    Behavior on _animProgress { NumberAnimation { duration: 80; easing.type: Easing.InOutCubic } }

    // Allow external trailing content (e.g., switches) to be inserted at end of row
    // Using a dedicated slot so grouped tiles keep tight vertical spacing
    default property alias trailing: trailingSlot.data

    // Background using Canvas to allow per-corner radii
    // Dark theme: slightly brighter gray surface vs surrounding
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
            var pill = h / 2
            function lerp(a,b,t){ return a + (b-a) * Math.max(0, Math.min(1, t)) }
            var baseTL = (root.groupRole === 'single' || root.groupRole === 'top') ? round : sharp
            var baseTR = (root.groupRole === 'single' || root.groupRole === 'top') ? round : sharp
            var baseBL = (root.groupRole === 'single' || root.groupRole === 'bottom') ? round : sharp
            var baseBR = (root.groupRole === 'single' || root.groupRole === 'bottom') ? round : sharp
            if (root.groupRole === 'middle') { baseTL = baseTR = baseBL = baseBR = sharp }
            // Animate to pill shape when pressed
            var rTL = lerp(baseTL, pill, root._animProgress)
            var rTR = lerp(baseTR, pill, root._animProgress)
            var rBL = lerp(baseBL, pill, root._animProgress)
            var rBR = lerp(baseBR, pill, root._animProgress)
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

            // Base fill — use a near-neutral grey from the palette for a more subdued look
            var fill = Components.ColorPalette.surfaceVariant
            ctx.fillStyle = fill
            roundedRect(rTL, rTR, rBR, rBL)
            ctx.fill()

            // Subtle luminous overlay to mimic Material settings tiles
            ctx.globalAlpha = 0.035
            ctx.fillStyle = Components.ColorPalette.inverseSurface
            roundedRect(rTL, rTR, rBR, rBL)
            ctx.fill()
            ctx.globalAlpha = 1.0
        }
    }

    // Hover/press overlay when clickable (shape matches groupRole corners)
    Canvas {
        id: stateOverlay
        anchors.fill: parent
        opacity: !root.clickable || !root.enabled ? 0.0 : (mouse.pressed ? 0.12 : (mouse.containsMouse ? 0.06 : 0.0))
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            var w = width, h = height
            var round = 16
            var sharp = 2
            var pill = h / 2
            function lerp(a,b,t){ return a + (b-a) * Math.max(0, Math.min(1, t)) }
            var baseTL = (root.groupRole === 'single' || root.groupRole === 'top') ? round : sharp
            var baseTR = (root.groupRole === 'single' || root.groupRole === 'top') ? round : sharp
            var baseBL = (root.groupRole === 'single' || root.groupRole === 'bottom') ? round : sharp
            var baseBR = (root.groupRole === 'single' || root.groupRole === 'bottom') ? round : sharp
            if (root.groupRole === 'middle') { baseTL = baseTR = baseBL = baseBR = sharp }
            // Animate to pill shape when pressed
            var rTL = lerp(baseTL, pill, root._animProgress)
            var rTR = lerp(baseTR, pill, root._animProgress)
            var rBL = lerp(baseBL, pill, root._animProgress)
            var rBR = lerp(baseBR, pill, root._animProgress)
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
            ctx.fillStyle = Components.ColorPalette.onSurface
            roundedRect(rTL, rTR, rBR, rBL)
            ctx.fill()
        }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }

    // Content layout similar to Android settings rows
    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: padding
        spacing: 12

        // Leading icon (optional)
        Item {
            id: leading
            Layout.preferredWidth: iconSource ? 24 : 0
            Layout.preferredHeight: 24
            visible: iconSource !== ""
            Image {
                anchors.fill: parent
                source: iconSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: false
                visible: status === Image.Ready || status === Image.Loading
                onStatusChanged: {
                    if (status === Image.Error) {
                        visible = false
                    }
                }
            }
        }

        Column {
            id: textCol
            spacing: 2
            Layout.fillWidth: true
            Text {
                text: root.title
                color: root.enabled ? Components.ColorPalette.onSurface : Qt.rgba(0.7,0.7,0.7,1)
                font.pixelSize: 16
                elide: Text.ElideRight
            }
            Text {
                text: root.subtitle
                visible: root.subtitle.length > 0
                color: Components.ColorPalette.onSurfaceVariant
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        // Trailing slot for custom content (e.g., Switch)
        Item {
            id: trailingSlot
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: childrenRect.width
            implicitHeight: Math.max(24, childrenRect.height)
            visible: children.length > 0
        }

        // Trailing chevron if clickable
        Item {
            id: chevron
            Layout.preferredWidth: root.clickable ? 20 : 0
            Layout.preferredHeight: 20
            visible: root.clickable && trailingSlot.children.length === 0
            Canvas {
                anchors.centerIn: parent
                width: 12; height: 12
                onPaint: { var ctx = getContext('2d'); ctx.reset(); ctx.strokeStyle = Components.ColorPalette.onSurfaceVariant; ctx.lineWidth = 2; ctx.lineCap = 'round'; ctx.beginPath(); ctx.moveTo(2,1); ctx.lineTo(10,6); ctx.lineTo(2,11); ctx.stroke(); }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.clickable && root.enabled
        onClicked: root.clicked()
        onPressedChanged: {
            root._pressed = pressed
            root._animProgress = pressed ? 1.0 : 0.0
        }
    }
    
    // Repaint canvases when animation progresses
    Connections {
        target: root
        function on_AnimProgressChanged() {
            bg.requestPaint()
            stateOverlay.requestPaint()
        }
    }
}


