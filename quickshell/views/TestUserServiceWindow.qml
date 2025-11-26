import QtQuick 2.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/layout" as Layout
import "../resources/components/typography" as Type
import "../resources/components/actions" as Actions
import "../shell/services/UserService" as UserSvc

FloatingWindow {
    id: testWindow
    title: "User Service Test"
    visible: true
    implicitWidth: 500
    implicitHeight: 600
    minimumSize: Qt.size(400, 500)
    
    Rectangle {
        anchors.fill: parent
        color: Components.ColorPalette.background
        
        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16
            
            // Header
            Row {
                width: parent.width
                spacing: 16
                
                Type.Label {
                    text: "User Service Test"
                    pixelSize: 24
                    bold: true
                    color: Components.ColorPalette.onBackground
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: 1; height: 1 }
                
                Actions.Button {
                    text: "Refresh"
                    outlined: true
                    onClicked: UserSvc.UserService.refresh()
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Actions.Button {
                    text: "Close"
                    kind: "cancel"
                    outlined: true
                    onClicked: testWindow.visible = false
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Components.ColorPalette.outline
            }
            
            // Status
            Row {
                spacing: 8
                
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: UserSvc.UserService.loaded ? Components.ColorPalette.primary : Components.ColorPalette.error
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Type.Label {
                    text: UserSvc.UserService.loaded ? "Loaded" : "Loading..."
                    pixelSize: 14
                    color: Components.ColorPalette.onSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Type.Label {
                    text: UserSvc.UserService.error !== "" ? "Error: " + UserSvc.UserService.error : ""
                    pixelSize: 12
                    color: Components.ColorPalette.error
                    visible: UserSvc.UserService.error !== ""
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Avatar preview
            Column {
                width: parent.width
                spacing: 12
                
                Type.Label {
                    text: "Avatar"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Row {
                    spacing: 16
                    
                    Rectangle {
                        width: 80
                        height: 80
                        radius: 40
                        color: Components.ColorPalette.surfaceVariant
                        
                        Layout.RoundedFrame {
                            anchors.fill: parent
                            circular: true
                            source: UserSvc.UserService.avatarUrl
                            visible: UserSvc.UserService.avatarUrl !== ""
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "\uE7FD"  // account_circle
                            font.family: "Material Icons"
                            font.pixelSize: 80
                            color: Components.ColorPalette.onSurfaceVariant
                            visible: UserSvc.UserService.avatarUrl === ""
                        }
                    }
                    
                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Type.Label {
                            text: UserSvc.UserService.avatarPath !== "" ? "Found" : "Not found"
                            pixelSize: 14
                            color: UserSvc.UserService.avatarPath !== "" ? Components.ColorPalette.primary : Components.ColorPalette.error
                        }
                        
                        Type.Label {
                            text: UserSvc.UserService.avatarPath || "No avatar file"
                            pixelSize: 11
                            color: Components.ColorPalette.onSurfaceVariant
                            width: 300
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Components.ColorPalette.outline
            }
            
            // User info list
            Column {
                width: parent.width
                spacing: 8
                
                Type.Label {
                    text: "User Information"
                    pixelSize: 16
                    bold: true
                    color: Components.ColorPalette.onBackground
                }
                
                Repeater {
                    model: [
                        { label: "Username", value: UserSvc.UserService.username },
                        { label: "Full Name", value: UserSvc.UserService.fullName },
                        { label: "Home Directory", value: UserSvc.UserService.home },
                        { label: "Shell", value: UserSvc.UserService.shell },
                        { label: "UID", value: UserSvc.UserService.uid.toString() },
                        { label: "GID", value: UserSvc.UserService.gid.toString() },
                        { label: "Avatar URL", value: UserSvc.UserService.avatarUrl }
                    ]
                    
                    delegate: Layout.SettingsTile {
                        width: parent.width
                        title: modelData.label
                        subtitle: modelData.value || "(empty)"
                        clickable: false
                        groupRole: {
                            if (index === 0) return "top"
                            if (index === 6) return "bottom"
                            return "middle"
                        }
                    }
                }
            }
            
            Item {
                width: 1
                height: 20
            }
            
            // Debug info
            Layout.Container {
                width: parent.width
                padding: 12
                
                Column {
                    width: parent.width
                    spacing: 4
                    
                    Type.Label {
                        text: "Debug Info"
                        pixelSize: 12
                        bold: true
                        color: Components.ColorPalette.onSurfaceVariant
                    }
                    
                    Type.Label {
                        text: "Service loaded: " + UserSvc.UserService.loaded
                        pixelSize: 10
                        color: Components.ColorPalette.onSurfaceVariant
                    }
                    
                    Type.Label {
                        text: "Has error: " + (UserSvc.UserService.error !== "")
                        pixelSize: 10
                        color: Components.ColorPalette.onSurfaceVariant
                    }
                }
            }
        }
    }
}
