import QtQuick 2.15
import "../../colors.js" as Palette

Rectangle {
    id: root
    // Custom container (no outline) that grows to max size with margins
    property real cornerRadius: 10
    // Background: biraz daha koyu ve belirgin
    property color backgroundColor: Qt.darker(Palette.palette().background, 1.08)
    property color borderColor: Palette.palette().outline
    property real borderWidth: 0
    property real padding: 16
    // external margins to avoid touching navbars or window edges
    property real outerMargin: 16
    // toggleable debug outline from parent
    property bool debugOutline: false
    // whether to fill parent; if false, anchoring is not applied
    property bool fillParent: false
    // insets to reserve space for internal bars (top/bottom/left/right)
    property int contentTopInset: 0
    property int contentBottomInset: 0
    property int contentLeftInset: 0
    property int contentRightInset: 0
    // Optional bottom navigation bar integration
    property Item bottomBar: null


    // Fill parent while keeping an outer margin
    anchors.margins: outerMargin
    anchors.left: fillParent && parent ? parent.left : undefined
    anchors.right: fillParent && parent ? parent.right : undefined
    anchors.top: fillParent && parent ? parent.top : undefined
    anchors.bottom: fillParent && parent ? parent.bottom : undefined

    color: backgroundColor
    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
    clip: true
    border.color: debugOutline ? Palette.palette().primary : borderColor
    border.width: debugOutline ? 1 : 0
    radius: cornerRadius

    // Measure content bounds
    property real contentImplicitWidth: contentHolder.childrenRect.width
    property real contentImplicitHeight: contentHolder.childrenRect.height

    default property alias content: contentHolder.data
    implicitWidth: Math.max(0, contentImplicitWidth + padding * 2 + contentLeftInset + contentRightInset)
    implicitHeight: Math.max(0, contentImplicitHeight + padding * 2 + contentTopInset + contentBottomInset)

    // Scrollable viewport when content exceeds available space
    // Overscroll glow at edges when dragged beyond bounds
    property color glowColor: Palette.palette().primary
    // Multiplier to boost touchpad pixelDelta scrolling
    property real wheelMultiplier: 3.0
    property real topOvershoot: Math.max(0, -viewport.contentY)
    property real bottomOvershoot: Math.max(0, viewport.contentY + viewport.height - viewport.contentHeight)
    Flickable {
        id: viewport
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: padding + contentLeftInset
        anchors.rightMargin: padding + contentRightInset
        anchors.topMargin: padding + contentTopInset
        anchors.bottomMargin: padding + contentBottomInset
        clip: true
        flickableDirection: Flickable.VerticalFlick
        // prevent horizontal scroll; if content wider, keep window stable
        contentWidth: width
        contentHeight: contentHolder.implicitHeight
        boundsBehavior: Flickable.DragOverBounds
        interactive: contentHeight > height
        maximumFlickVelocity: 2400
        flickDeceleration: 2800

        Item {
            id: contentHolder
            // expand to viewport width, height grows with content
            width: viewport.width
            implicitHeight: childrenRect.height + (root.bottomBar && root.bottomBar.visible ? root.bottomBar.height : 0)
        }

            // Fallback wheel support via MouseArea to catch trackpads/mice universally
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: false
                propagateComposedEvents: true
                onWheel: function(wheel) {
                    var step = 100
                    var dy = (wheel.pixelDelta && wheel.pixelDelta.y !== 0)
                             ? wheel.pixelDelta.y * root.wheelMultiplier
                             : (wheel.angleDelta.y / 120) * step
                    var maxY = Math.max(0, viewport.contentHeight - viewport.height)
                    var targetY = Math.max(0, Math.min(viewport.contentY - dy, maxY))
                    if (wheelAnim.running) wheelAnim.stop()
                    wheelAnim.to = targetY
                    wheelAnim.start()
                    wheel.accepted = true
                }
            }

        // Smooth wheel support (mouse and touchpad)
        NumberAnimation { id: wheelAnim; target: viewport; property: "contentY"; duration: 140; easing.type: Easing.OutCubic }
            WheelHandler {
            id: wheelHandler
            target: viewport
            onWheel: (event) => {
                if (event.accepted) return
                // Prefer pixelDelta for high-resolution touchpads, fall back to angleDelta steps
                var step = 100
                    var dy = event.pixelDelta && event.pixelDelta.y !== 0
                             ? event.pixelDelta.y * root.wheelMultiplier
                         : (event.angleDelta.y / 120) * step
                var maxY = Math.max(0, viewport.contentHeight - viewport.height)
                var target = Math.max(0, Math.min(viewport.contentY - dy, maxY))
                if (wheelAnim.running) wheelAnim.stop()
                wheelAnim.to = target
                wheelAnim.start()
                event.accepted = true
            }
        }
    }

    // Overscroll glow removed per request

    // Bottom navigation bar slot anchored to bottom
    Item {
        id: bottomSlot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: bottomBar && bottomBar.visible ? bottomBar.height : 0
        visible: bottomBar && bottomBar.visible
        // When a bar is provided, reparent here so it fills width
        Component.onCompleted: {
            if (root.bottomBar) {
                root.bottomBar.parent = bottomSlot
            }
            // ensure viewport leaves space for the bar
            viewport.anchors.bottomMargin = root.padding + root.contentBottomInset + height
        }
        onHeightChanged: viewport.anchors.bottomMargin = root.padding + root.contentBottomInset + height
        onVisibleChanged: viewport.anchors.bottomMargin = root.padding + root.contentBottomInset + (visible ? height : 0)
    }
}


