import QtQuick 2.15
import QtQml 2.15
import "../../colors.js" as Palette
import "./MenuRegistry.js" as MenuRegistry

/*
  Simple HamburgerMenu - Clean implementation
  
  Item format:
  - { label, icon?, trailingIcon?, trailingText?, enabled?, selected?, onTriggered? }
  - { divider: true }
  - { section: [items...] } - auto-adds dividers between sections
*/

Item {
    id: root
    anchors.fill: parent
    z: 999

    property bool open: false
    property var items: []
    property int menuX: 0
    property int menuY: 0
    
    signal closed()

    // Convert items to sections format
    function getSections(arr) {
        var sections = []
        if (!arr || !arr.length) return sections
        
        var currentSection = []
        for (var i = 0; i < arr.length; i++) {
            var item = arr[i]
            if (item.section && Array.isArray(item.section)) {
                if (currentSection.length > 0) {
                    sections.push(currentSection)
                    currentSection = []
                }
                sections.push(item.section)
            } else if (item.divider) {
                if (currentSection.length > 0) {
                    sections.push(currentSection)
                    currentSection = []
                }
            } else {
                currentSection.push(item)
            }
        }
        if (currentSection.length > 0) {
            sections.push(currentSection)
        }
        return sections
    }

    // Calculate menu size
    function calculateSize() {
        var sections = getSections(items)
        var maxWidth = 160
        var totalHeight = 16 // top+bottom padding
        
        for (var s = 0; s < sections.length; s++) {
            var section = sections[s]
            for (var i = 0; i < section.length; i++) {
                var item = section[i]
                totalHeight += 40 // row height
                // Estimate width
                var w = 24 + (item.label ? item.label.length * 8 : 0) + 24
                if (item.icon) w += 32
                if (item.trailingText) w += 40
                if (item.trailingIcon) w += 24
                if (w > maxWidth) maxWidth = w
            }
            totalHeight += 16 // padding inside section
            if (s < sections.length - 1) {
                totalHeight += 4 // spacing between sections
            }
        }
        
        return { width: Math.min(maxWidth, 320), height: totalHeight }
    }

    property bool menuClosing: false

    onOpenChanged: {
        if (open) {
            menuClosing = false
            MenuRegistry.requestOpen(root)
            var size = calculateSize()
            menu.width = size.width
            menu.height = size.height
            menu.visible = true
            menu.opacity = 1
        } else {
            menuClosing = true
            menu.opacity = 0
        }
    }

    function openAt(x, y) {
        menuX = x
        menuY = y
        open = true
    }

    function openAtItem(item) {
        if (!item || !item.mapToItem) {
            openAt(0, 0)
            return
        }
        var p = item.mapToItem(root, 0, item.height)
        openAt(p.x, p.y)
    }

    function close() {
        open = false
        closed()
    }

    // Click away
    MouseArea {
        anchors.fill: parent
        visible: root.open
        onClicked: root.close()
        hoverEnabled: true
    }

    // Menu panel (transparent container)
    Item {
        id: menu
        visible: false
        opacity: 0
        x: Math.max(0, Math.min(menuX, root.width - width))
        y: Math.max(0, Math.min(menuY, root.height - height))
        
        Behavior on opacity { 
            NumberAnimation { 
                duration: 160
                easing.type: Easing.OutCubic
                onRunningChanged: {
                    if (!running && menu.opacity === 0 && root.menuClosing) {
                        menu.visible = false
                        root.menuClosing = false
                        MenuRegistry.notifyClosed(root)
                    }
                }
            }
        }
        Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: (root.open || root.menuClosing) ? root.getSections(root.items) : []
                
                delegate: Rectangle {
                    width: menu.width - 16
                    height: sectionColumn.implicitHeight + 16
                    color: Qt.darker(Palette.palette().surfaceVariant, 1.12)
                    radius: 12
                    clip: true

                    Column {
                        id: sectionColumn
                        x: 8
                        y: 8
                        width: parent.width - 16
                        spacing: 0

                        Repeater {
                            model: modelData
                            
                            delegate: Item {
                                width: sectionColumn.width
                                height: 40

                                property bool isSelected: !!(modelData && modelData.selected === true)
                                property bool isEnabled: !(modelData && modelData.enabled === false)
                                property bool hovered: false

                                // Selected/hover background (extends beyond item to fill section width)
                                Rectangle {
                                    x: -8
                                    y: 0
                                    width: sectionColumn.parent.width
                                    height: parent.height
                                    radius: 0
                                    color: parent.isSelected ? Palette.palette().secondaryContainer :
                                           Palette.isDarkMode() ? Qt.lighter(Palette.palette().surfaceVariant, 1.18) :
                                           Qt.darker(Palette.palette().surfaceVariant, 1.08)
                                    opacity: parent.isSelected ? 1.0 : (parent.hovered ? 1.0 : 0.0)
                                    Behavior on opacity { NumberAnimation { duration: 120 } }
                                }

                                // Leading icon
                                Text {
                                    id: leadingIcon
                                    visible: !!(modelData && modelData.icon)
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (modelData && modelData.icon) ? modelData.icon : ""
                                    color: parent.isSelected ? Palette.palette().onSecondaryContainer : 
                                           Palette.palette().onSurfaceVariant
                                    font.pixelSize: 20
                                    font.family: "Material Icons"
                                    opacity: parent.isEnabled ? 1.0 : 0.38
                                }

                                // Label
                                Text {
                                    id: label
                                    anchors.left: leadingIcon.visible ? leadingIcon.right : parent.left
                                    anchors.leftMargin: leadingIcon.visible ? 12 : 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (modelData && modelData.label) ? modelData.label : ""
                                    color: parent.isSelected ? Palette.palette().onSecondaryContainer : 
                                           Palette.palette().onSurface
                                    font.pixelSize: 15
                                    font.weight: parent.isSelected ? Font.Medium : Font.Normal
                                    opacity: parent.isEnabled ? 1.0 : 0.38
                                }

                                // Trailing icon
                                Text {
                                    id: trailingIcon
                                    visible: !!(modelData && modelData.trailingIcon)
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData && modelData.trailingIcon ? modelData.trailingIcon : ""
                                    color: Palette.palette().onSurfaceVariant
                                    font.pixelSize: 20
                                    font.family: "Material Icons"
                                    opacity: parent.isEnabled ? 1.0 : 0.38
                                }

                                // Trailing text (keyboard shortcut)
                                Rectangle {
                                    id: trailingText
                                    visible: !!(modelData && modelData.trailingText)
                                    anchors.right: trailingIcon.visible ? trailingIcon.left : parent.right
                                    anchors.rightMargin: trailingIcon.visible ? 12 : 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: shortcutLabel.width + 12
                                    height: 22
                                    radius: 6
                                    color: Palette.isDarkMode() ? Qt.lighter(Palette.palette().surfaceVariant, 1.15) :
                                           Qt.darker(Palette.palette().surfaceVariant, 1.05)
                                    opacity: parent.isEnabled ? 0.9 : 0.38
                                    
                                    Text {
                                        id: shortcutLabel
                                        anchors.centerIn: parent
                                        text: (modelData && modelData.trailingText) ? modelData.trailingText : ""
                                        color: Palette.palette().onSurfaceVariant
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        font.family: "monospace"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: parent.isEnabled
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    
                                    onEntered: parent.hovered = true
                                    onExited: parent.hovered = false
                                    
                                    onClicked: {
                                        if (modelData && modelData.onTriggered) {
                                            modelData.onTriggered()
                                            root.close()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
