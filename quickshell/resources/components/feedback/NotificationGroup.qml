import QtQuick 2.15
import ".." as Components
import "../actions" as Actions
import "../layout" as Layout
import "../../../shell/services"

Item {
    id: root
    property string appName: "App"
    property string appIcon: ""
    property var notifications: []
    property bool expanded: false
    property real dismissProgress: 0
    property bool isNewGroup: false
    property bool isSingleMode: notifications.length === 1
    
    signal dismissGroup()
    signal dismissNotification(var notification)
    
    width: parent.width
    height: Math.max(0, (1.0 - dismissProgress) * (groupHeader.height + notifColumn.height))
    clip: true
    opacity: (1.0 - dismissProgress) * (isNewGroup ? groupAppearProgress : 1.0)
    scale: (1.0 - (dismissProgress * 0.1)) * (isNewGroup ? (0.9 + groupAppearProgress * 0.1) : 1.0)
    
    property real groupAppearProgress: 0
    
    Component.onCompleted: {
        if (isNewGroup) {
            groupAppearAnim.start()
        } else {
            groupAppearProgress = 1.0
        }
    }
    
    NumberAnimation {
        id: groupAppearAnim
        target: root
        property: "groupAppearProgress"
        from: 0.0
        to: 1.0
        duration: 300
        easing.type: Easing.OutCubic
    }
    
    Column {
        width: parent.width
        spacing: 0
        
        // Group header - hide when in single mode
        Canvas {
            id: groupHeader
            width: parent.width
            height: root.isSingleMode ? 0 : 56
            opacity: root.isSingleMode ? 0.0 : 1.0
            visible: height > 0
            
            Behavior on height {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            
            property real roundRadius: 16
            property real bottomLeftRadius: root.expanded ? 0 : roundRadius
            property real bottomRightRadius: root.expanded ? 0 : roundRadius
            
            Behavior on bottomLeftRadius {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            Behavior on bottomRightRadius {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            onBottomLeftRadiusChanged: requestPaint()
            onBottomRightRadiusChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            
            onPaint: {
                try {
                    var ctx = getContext('2d')
                    if (!ctx) {
                        console.warn("NotificationGroup: Failed to get canvas context")
                        return
                    }
                    ctx.reset()
                    var w = width
                    var h = height
                    var rTop = roundRadius
                    var rBL = bottomLeftRadius
                    var rBR = bottomRightRadius
                    
                    ctx.beginPath()
                
                // Top-left corner
                ctx.moveTo(rTop, 0)
                
                // Top edge and top-right corner
                ctx.lineTo(w - rTop, 0)
                if (rTop > 0) {
                    ctx.arc(w - rTop, rTop, rTop, -Math.PI/2, 0)
                }
                
                // Right edge and bottom-right corner
                ctx.lineTo(w, h - rBR)
                if (rBR > 0) {
                    ctx.arc(w - rBR, h - rBR, rBR, 0, Math.PI/2)
                }
                
                // Bottom edge and bottom-left corner
                ctx.lineTo(rBL, h)
                if (rBL > 0) {
                    ctx.arc(rBL, h - rBL, rBL, Math.PI/2, Math.PI)
                }
                
                // Left edge and top-left corner
                ctx.lineTo(0, rTop)
                if (rTop > 0) {
                    ctx.arc(rTop, rTop, rTop, Math.PI, Math.PI * 1.5)
                }
                
                    ctx.closePath()
                    ctx.fillStyle = Components.ColorPalette.surfaceVariant
                    ctx.fill()
                } catch (e) {
                    console.error("NotificationGroup paint error:", e)
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) {
                    // Only toggle if not clicking on buttons
                    if (!chevronBtn.contains(mapToItem(chevronBtn, mouse.x, mouse.y)) && 
                        !closeBtn.contains(mapToItem(closeBtn, mouse.x, mouse.y))) {
                        root.expanded = !root.expanded
                    }
                }
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 12
                    
                    // App icon with rounded background
                    Rectangle {
                        id: iconRect
                        width: 32
                        height: 32
                        radius: 16
                        color: Qt.rgba(Components.ColorPalette.primary.r, Components.ColorPalette.primary.g, Components.ColorPalette.primary.b, 0.15)
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            radius: 10
                            clip: true
                            color: "transparent"
                            
                            Image {
                                id: iconImage
                                anchors.fill: parent
                                source: root.appIcon || ""
                                sourceSize.width: width
                                sourceSize.height: height
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready
                                asynchronous: false
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        // Hide on error, show fallback
                                        visible = false
                                    }
                                }
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.appName.charAt(0).toUpperCase()
                            font.pixelSize: 16
                            font.bold: true
                            color: Components.ColorPalette.primary
                            visible: !root.appIcon || root.appIcon === ""
                        }
                    }
                    
                    // App name and count
                    Column {
                        anchors.left: iconRect.right
                        anchors.leftMargin: 12
                        anchors.right: chevronBtn.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        
                        Text {
                            text: root.appName
                            font.pixelSize: 16
                            font.bold: true
                            color: Components.ColorPalette.onSurface
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        
                        Text {
                            text: root.notifications.length + " notification" + (root.notifications.length !== 1 ? "s" : "")
                            font.pixelSize: 12
                            color: Components.ColorPalette.onSurfaceVariant
                        }
                    }
                    
                    // Chevron
                    Actions.Expander {
                        id: chevronBtn
                        size: 24
                        iconSize: 12
                        hasBackground: false
                        anchors.right: closeBtn.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        expanded: root.expanded
                        onToggled: function(isExpanded) {
                            root.expanded = isExpanded
                        }
                    }
                    
                    // Clear group button
                    Rectangle {
                        id: closeBtn
                        width: 24
                        height: 24
                        radius: 12
                        color: 'transparent'
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Canvas {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            onPaint: {
                                var ctx = getContext('2d')
                                ctx.reset()
                                ctx.strokeStyle = Components.ColorPalette.onSurfaceVariant
                                ctx.lineWidth = 2
                                ctx.beginPath()
                                ctx.moveTo(2, 2)
                                ctx.lineTo(10, 10)
                                ctx.moveTo(10, 2)
                                ctx.lineTo(2, 10)
                                ctx.stroke()
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: function(mouse) {
                                mouse.accepted = true
                                if (root.dismissProgress === 0) {
                                    dismissAnim.start()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Notifications in group
        Item {
            id: notifColumn
            width: parent.width
            // In single mode, always show the notification (not collapsible)
            height: root.isSingleMode ? contentColumn.implicitHeight : (root.expanded ? contentColumn.implicitHeight : 0)
            clip: true
            
            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
            
            Column {
                id: contentColumn
                width: parent.width
                spacing: 2
                // In single mode, always show content
                opacity: root.isSingleMode ? 1.0 : (root.expanded ? 1.0 : 0.0)
                
                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
                
                Repeater {
                    model: root.notifications
                    
                    delegate: Loader {
                        id: notifLoader
                        width: parent.width
                        source: "NotificationCard.qml"
                        
                        property var notifData: modelData
                        property int notifIndex: index
                        property int totalNotifs: root.notifications.length
                        property var closedConnection: null
                        property var dismissedConnection: null
                        property var actionClickedConnection: null
                        
                        onLoaded: {
                            if (!item) return
                            
                            item.title = notifData.summary || "Notification"
                            item.body = notifData.body || ""
                            item.appIcon = NotificationService.getAppIcon(notifData)
                            item.actions = notifData.actions || []
                            item.showActions = true
                            item.dismissible = true
                            
                            // Set group role - single when only 1 notification
                            // First notification (index 0) is newest and should have sharp bottom
                            // Last notification is oldest and should have rounded bottom
                            if (totalNotifs === 1) {
                                item.groupRole = "single"
                            } else if (notifIndex === 0) {
                                item.groupRole = "middle"
                            } else if (notifIndex === totalNotifs - 1) {
                                item.groupRole = "bottom"
                            } else {
                                item.groupRole = "middle"
                            }
                            
                            // Listen to notification's closed signal to animate before removal
                            if (notifData && notifData.closed) {
                                closedConnection = notifData.closed.connect(function(reason) {
                                    console.log("Notification closed with reason:", reason)
                                    // Check if loader and item still exist
                                    if (notifLoader && notifLoader.item && notifLoader.item.animOut) {
                                        notifLoader.item.animOut.start()
                                    }
                                })
                            }
                            
                            // dismissed signal is emitted AFTER animation completes
                            dismissedConnection = item.dismissed.connect(function() {
                                // Only dismiss if not already closed by server
                                if (notifData && notifData.tracked) {
                                    root.dismissNotification(notifData)
                                }
                            })
                            
                            // actionClicked for Dismiss button - trigger animation, don't dismiss directly
                            actionClickedConnection = item.actionClicked.connect(function(action) {
                                if (action === "DISMISS") {
                                    // Check if loader and item still exist
                                    if (notifLoader && notifLoader.item && notifLoader.item.animOut) {
                                        notifLoader.item.animOut.start()
                                    } else if (notifData) {
                                        // Fallback if animOut doesn't exist
                                        root.dismissNotification(notifData)
                                    }
                                }
                            })
                        }
                        
                        Component.onDestruction: {
                            // Disconnect signals to prevent accessing destroyed objects
                            if (closedConnection) {
                                try { notifData.closed.disconnect(closedConnection) } catch(e) {}
                            }
                            if (dismissedConnection && item) {
                                try { item.dismissed.disconnect(dismissedConnection) } catch(e) {}
                            }
                            if (actionClickedConnection && item) {
                                try { item.actionClicked.disconnect(actionClickedConnection) } catch(e) {}
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dismiss animation
    SequentialAnimation {
        id: dismissAnim
        running: false
        
        NumberAnimation { 
            target: root
            property: "dismissProgress"
            to: 1.0
            duration: 250
            easing.type: Easing.InOutQuad
        }
        
        ScriptAction {
            script: {
                // Actually dismiss the group after animation
                root.dismissGroup()
            }
        }
    }
}
