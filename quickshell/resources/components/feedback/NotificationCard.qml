import QtQuick 2.15
import ".." as Components
import "../actions" as Actions
import "../layout" as Layout

Rectangle {
    id: root
    property string title: "Notification"
    property string body: "Message details go here."
    property string appIcon: ""
    property var actions: []
    property bool expanded: false
    property bool showActions: true
    property bool dismissible: true
    property bool autoRestore: false
    property bool isDismissing: false
    property var pendingAction: null
    // Tag to help parent containers detect cards reliably
    property bool isNotificationCard: true
    // If false, chevron and expandable content are hidden
    property bool expandable: (body && body.trim().length > 0) || (showActions && actions && actions.length > 0)
    // Collapse progress used to let following cards slide up while this one dismisses
    property real collapseProgress: 0
    
    // Expose the animation so parent can trigger it
    property alias animOut: animOut

    // Grouping role: controls which corners are fully rounded vs sharp when stacked
    property string groupRole: "single"
    
    // Dismiss progress (0..1) used to morph corners while swiping
    property real dismissProgress: 0
    signal dismissed()
    signal actionClicked(string action)

    radius: 16
    color: Components.ColorPalette.isDarkMode ? Components.ColorPalette.surface : Qt.darker(Components.ColorPalette.background, 1.08)
    border.width: 0
    clip: true
    antialiasing: true
    implicitWidth: 360
    readonly property real baseImplicitHeight: content.implicitHeight + 16 * 2
    implicitHeight: Math.max(0, (1.0 - collapseProgress) * baseImplicitHeight)
    
    // Luminous overlay for depth
    Rectangle {
        id: overlay
        anchors.fill: parent
        radius: parent.radius
        color: Components.ColorPalette.inverseSurface
        opacity: 0.04
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
        }
        onReleased: {
            var farEnough = Math.abs(root.x) > root.width * 0.35
            if (farEnough && root.dismissible) {
                root.triggerDismiss()
            } else {
                snapBack.to = 0; snapBack.start()
            }
        }
        onCanceled: { snapBack.to = 0; snapBack.start() }
    }
    NumberAnimation { id: snapBack; target: root; property: "x"; duration: 200; easing.type: Easing.OutCubic; onStopped: { root.dismissProgress = 0 } }
    onXChanged: {
        if (swipeArea.drag.active || snapBack.running || animOut.running) {
            root.dismissProgress = Math.max(0.12, Math.min(1, Math.abs(root.x) / Math.max(1, root.width)))
        }
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        // Header row with avatar, title, chevron, close
        Item {
            id: header
            width: parent.width
            height: Math.max(32, titleText.implicitHeight)

            Rectangle { 
                id: avatar
                width: 32
                height: 32
                radius: 16
                color: Qt.rgba(Components.ColorPalette.primary.r, Components.ColorPalette.primary.g, Components.ColorPalette.primary.b, 0.15)
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                
                Image {
                    id: iconImage
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: root.appIcon || ""
                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectFit
                    smooth: false
                    visible: status === Image.Ready
                    asynchronous: true
                    cache: true
                    onStatusChanged: {
                        if (status === Image.Error) {
                            visible = false
                        }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: root.title.charAt(0).toUpperCase()
                    font.pixelSize: 16
                    font.bold: true
                    color: Components.ColorPalette.primary
                    visible: !root.appIcon || root.appIcon === ""
                }
            }
            
            Text {
                id: titleText
                text: root.title
                color: Components.ColorPalette.onSurface
                font.pixelSize: 16
                anchors.left: avatar.right
                anchors.leftMargin: 8
                anchors.right: closeBtn.left
                anchors.rightMargin: 8
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
            }
            // Chevron toggle
            Actions.Expander {
                id: chevronBtn
                size: 24
                iconSize: 12
                hasBackground: false
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.expandable
                expanded: root.expanded
                onToggled: function(isExpanded) {
                    root.expanded = isExpanded
                }
            }
            // Close small X
            Rectangle {
                id: closeBtn
                width: 24; height: 24; radius: 12
                color: closeBtnArea.containsMouse ? Qt.rgba(Components.ColorPalette.onSurface.r, Components.ColorPalette.onSurface.g, Components.ColorPalette.onSurface.b, 0.08) : 'transparent'
                anchors.right: chevronBtn.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                // Use Text with X character instead of Canvas for better performance
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Components.ColorPalette.onSurfaceVariant
                }
                
                MouseArea { 
                    id: closeBtnArea
                    anchors.fill: parent
                    onClicked: if (root.dismissible) root.triggerDismiss()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Expanding content area (body + actions)
        Item {
            id: expanderWrapper
            width: parent.width
            height: root.expanded ? expanderContent.implicitHeight : 0
            clip: true
            visible: root.expandable
            
            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
            
            Column {
                id: expanderContent
                width: parent.width
                spacing: 12
                opacity: root.expanded ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            
            Item {
                width: parent.width
                height: 12
            }
            
            Text {
                width: parent.width
                text: root.body
                color: Components.ColorPalette.onSurfaceVariant
                font.pixelSize: 14
                wrapMode: Text.Wrap
                lineHeight: 1.4
                renderType: Text.NativeRendering
            }
            
            // Action buttons row with pill-shaped buttons (OneUI style)
            Row {
                    width: parent.width
                    height: 48
                    spacing: 8
                    visible: root.showActions && root.actions && root.actions.length > 0
                    
                    property int buttonCount: (root.actions ? root.actions.length : 0) + 1
                    property int buttonWidth: (width - spacing * (buttonCount - 1)) / buttonCount
                    
                    Repeater {
                        model: root.actions || []
                        
                        Rectangle {
                            width: parent.buttonWidth
                            height: 40
                            radius: 20
                            color: buttonArea.containsMouse ? Components.ColorPalette.primaryContainer : Components.ColorPalette.surfaceVariant
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.text || "Action"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: buttonArea.containsMouse ? Components.ColorPalette.onPrimaryContainer : Components.ColorPalette.onSurfaceVariant
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                            
                            MouseArea {
                                id: buttonArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Store the action to invoke after animation
                                    root.pendingAction = modelData
                                    // Start dismiss animation
                                    root.triggerDismiss()
                                }
                            }
                        }
                    }
                    
                    // Dismiss button
                    Rectangle {
                        width: parent.buttonWidth
                        height: 40
                        radius: 20
                        color: dismissArea.containsMouse ? Components.ColorPalette.primaryContainer : Components.ColorPalette.surfaceVariant
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Dismiss"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: dismissArea.containsMouse ? Components.ColorPalette.onPrimaryContainer : Components.ColorPalette.onSurfaceVariant
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                        
                        MouseArea {
                            id: dismissArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.triggerDismiss()
                        }
                    }
                }
            }
        }
        }

    property bool isBeingDestroyed: false
    
    Component.onDestruction: {
        isBeingDestroyed = true
    }
    
    // Function to trigger dismiss with proper animation
    function triggerDismiss() {
        if (root.isDismissing) return
        root.isDismissing = true
        dismissAnim.start()
    }
    
    // Complete dismiss animation
    SequentialAnimation {
        id: dismissAnim
        
        ParallelAnimation {
            // Collapse expander if expanded
            NumberAnimation {
                target: expanderWrapper
                property: "height"
                to: 0
                duration: root.expanded ? 300 : 0
                easing.type: Easing.OutCubic
            }
            
            // Fade out slightly during collapse
            NumberAnimation { 
                target: root
                property: "opacity"
                to: 0.7
                duration: root.expanded ? 300 : 0
                easing.type: Easing.OutCubic
            }
        }
        
        // Then fade out completely
        ParallelAnimation {
            NumberAnimation { 
                target: root
                property: "opacity"
                to: 0.0
                duration: 200
                easing.type: Easing.InOutQuad
            }
            NumberAnimation { 
                target: root
                property: "collapseProgress"
                to: 1.0
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        
        onFinished: {
            // Invoke pending action after animation
            if (root.pendingAction && typeof root.pendingAction.invoke === "function") {
                root.pendingAction.invoke()
                root.pendingAction = null
            }
            
            if (!root.isBeingDestroyed) {
                root.dismissed()
            }
            if (root.autoRestore && !root.isBeingDestroyed) {
                root.x = 0
                root.scale = 1.0
                root.opacity = 1.0
                root.collapseProgress = 0
                root.expanded = false
                root.isDismissing = false
                animIn.start()
            }
        }
    }
    
    // Keep the old animOut for compatibility (just calls triggerDismiss)
    SequentialAnimation {
        id: animOut
        ScriptAction {
            script: {
                root.triggerDismiss()
            }
        }
    }

    ParallelAnimation {
        id: animIn
        NumberAnimation { target: root; property: "opacity"; to: 1.0; duration: 160; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.OutCubic }
    }
}


