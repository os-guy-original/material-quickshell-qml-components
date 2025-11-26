import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Components
import "../icons" as Icon

Item {
    id: root
    
    property var model: []
    property int currentIndex: 0
    property string currentValue: model.length > currentIndex ? model[currentIndex] : ""
    property string displayRole: ""
    property bool filled: false
    
    signal activated(int index, string value)
    
    implicitWidth: 200
    implicitHeight: 40
    
    Rectangle {
        id: background
        anchors.fill: parent
        radius: 8
        color: filled ? 
            Components.ColorPalette.surfaceContainerHighest : 
            Components.ColorPalette.surfaceVariant
        border.width: 0
        
        opacity: mouseArea.containsMouse ? 0.8 : 1.0
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8
        
        Text {
            Layout.fillWidth: true
            text: root.currentValue
            color: Components.ColorPalette.onSurface
            font.pixelSize: 14
            elide: Text.ElideRight
        }
        
        Icon.Icon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            name: root.expanded ? "expand_less" : "expand_more"
            size: 20
            color: Components.ColorPalette.onSurfaceVariant
            
            Behavior on rotation {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
    }
    
    property bool expanded: false
    
    function toggle() {
        expanded = !expanded
    }
    
    function close() {
        expanded = false
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        propagateComposedEvents: false
        onClicked: root.toggle()
    }
    
    // Dropdown menu - using parent to escape clipping
    Rectangle {
        id: dropdown
        visible: root.expanded
        parent: root.parent
        y: root.y + root.height + 4
        x: root.x
        width: root.width
        height: visible ? Math.min(dropdownColumn.height, 300) : 0
        radius: 8
        color: Components.ColorPalette.surfaceContainerHighest
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.1)
        z: 10000
        
        clip: true
        
        Column {
            id: dropdownColumn
            width: parent.width
            
            Repeater {
                model: root.model
                
                delegate: Item {
                    width: parent.width
                    height: 36
                    
                    Rectangle {
                        anchors.fill: parent
                        color: index === root.currentIndex ? 
                               Components.ColorPalette.primaryContainer : 
                               "transparent"
                        opacity: itemMouseArea.containsMouse ? 0.7 : 1.0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                    
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: index === root.currentIndex ? 
                               Components.ColorPalette.onPrimaryContainer : 
                               Components.ColorPalette.onSurface
                        font.pixelSize: 14
                    }
                    
                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = index
                            root.activated(index, modelData)
                            root.close()
                        }
                    }
                }
            }
        }
        
        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }
    
    // Close dropdown when clicking outside
    MouseArea {
        enabled: root.expanded
        anchors.fill: parent
        anchors.margins: -10000
        z: dropdown.z - 1
        onClicked: root.close()
    }
}
