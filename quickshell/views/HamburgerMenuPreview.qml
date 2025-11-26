import QtQuick 2.15
import QtQuick.Window 2.15
import "../resources/components" as Components
import "../resources/components/actions" as Actions

Window {
    id: window
    visible: true
    width: 800
    height: 600
    title: "Hamburger Menu Preview"
    color: Components.ColorPalette.surface

    // State management for interactive selection
    property string selectedItem3: "Item 3"
    property string selectedView: "Current View"
    property string selectedListView: "List View"

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Hamburger Menu Overhaul Demo"
            font.pixelSize: 24
            font.weight: Font.Bold
            color: Components.ColorPalette.onSurface
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            // Example 1: Simple menu with icons
            Actions.SplitButton {
                id: simpleButton
                text: "Simple Menu"
                showIcon: true
                menuItems: [
                    { label: "Refresh", icon: "refresh", onTriggered: function(){ console.log("Refresh clicked") } },
                    { label: "Settings", icon: "settings", onTriggered: function(){ console.log("Settings clicked") } },
                    { label: "Help", icon: "help", onTriggered: function(){ console.log("Help clicked") } },
                    { label: "More", icon: "more_horiz", onTriggered: function(){ console.log("More clicked") } }
                ]
            }

            // Example 2: Menu with sections and dividers
            Actions.SplitButton {
                id: sectionsButton
                text: "Sections"
                menuItems: [
                    { section: [
                        { label: "Cut", icon: "content_cut", trailingText: "⌘X", onTriggered: function(){ console.log("Cut") } },
                        { label: "Copy", icon: "content_copy", trailingText: "⌘C", onTriggered: function(){ console.log("Copy") } },
                        { label: "Paste", icon: "content_paste", trailingText: "⌘V", onTriggered: function(){ console.log("Paste") } }
                    ]},
                    { section: [
                        { label: "Select All", icon: "select_all", trailingText: "⌘A", onTriggered: function(){ console.log("Select All") } }
                    ]}
                ]
            }

            // Example 3: Menu with switchable selection
            Actions.SplitButton {
                id: advancedButton
                text: "Switchable"
                property int selectedIndex: 2
                menuItems: [
                    { label: "Item 1", icon: "visibility", selected: advancedButton.selectedIndex === 0, onTriggered: function(){ advancedButton.selectedIndex = 0 } },
                    { label: "Item 2", icon: "content_copy", trailingText: "⌘C", selected: advancedButton.selectedIndex === 1, onTriggered: function(){ advancedButton.selectedIndex = 1 } },
                    { label: "Item 3", icon: "check", selected: advancedButton.selectedIndex === 2, onTriggered: function(){ advancedButton.selectedIndex = 2 } },
                    { divider: true },
                    { label: "Item 4", icon: "person", selected: advancedButton.selectedIndex === 3, onTriggered: function(){ advancedButton.selectedIndex = 3 } },
                    { label: "Item 5", icon: "settings", selected: advancedButton.selectedIndex === 4, onTriggered: function(){ advancedButton.selectedIndex = 4 } }
                ]
            }

            // Example 4: Menu with disabled items
            Actions.SplitButton {
                id: disabledButton
                text: "Disabled Items"
                menuItems: [
                    { label: "Enabled Item", icon: "check_circle", onTriggered: function(){ console.log("Enabled") } },
                    { label: "Disabled Item", icon: "cancel", enabled: false, onTriggered: function(){ console.log("This won't fire") } },
                    { divider: true },
                    { label: "Another Enabled", icon: "star", onTriggered: function(){ console.log("Star") } }
                ]
            }
        }

        // Example 5: Full-featured menu
        Actions.SplitButton {
            id: fullButton
            text: "Full Featured Menu"
            showIcon: true
            anchors.horizontalCenter: parent.horizontalCenter
            menuItems: [
                { section: [
                    { label: "New File", icon: "insert_drive_file", trailingText: "⌘N", onTriggered: function(){ console.log("New File") } },
                    { label: "Open File", icon: "folder_open", trailingText: "⌘O", onTriggered: function(){ console.log("Open File") } },
                    { label: "Save", icon: "save", trailingText: "⌘S", onTriggered: function(){ console.log("Save") } }
                ]},
                { section: [
                    { label: "Undo", icon: "undo", trailingText: "⌘Z", onTriggered: function(){ console.log("Undo") } },
                    { label: "Redo", icon: "redo", trailingText: "⌘⇧Z", onTriggered: function(){ console.log("Redo") } }
                ]},
                { section: [
                    { label: "Current View", icon: "visibility", selected: true, onTriggered: function(){ console.log("Current View") } },
                    { label: "Switch View", icon: "swap_horiz", submenu: [
                        { label: "Grid View", icon: "grid_view", onTriggered: function(){ console.log("Grid") } },
                        { label: "List View", icon: "view_list", selected: true, onTriggered: function(){ console.log("List") } },
                        { label: "Compact View", icon: "view_compact", onTriggered: function(){ console.log("Compact") } }
                    ]}
                ]},
                { section: [
                    { label: "Settings", icon: "settings", submenu: [
                        { label: "General", icon: "tune", onTriggered: function(){ console.log("General") } },
                        { label: "Appearance", icon: "palette", onTriggered: function(){ console.log("Appearance") } },
                        { label: "Advanced", icon: "build", enabled: false, onTriggered: function(){ console.log("Advanced") } }
                    ]},
                    { label: "Help", icon: "help", trailingText: "F1", onTriggered: function(){ console.log("Help") } }
                ]}
            ]
        }

        Text {
            text: "Click the dropdown arrows to see the new menu styles!"
            font.pixelSize: 14
            color: Components.ColorPalette.onSurfaceVariant
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
