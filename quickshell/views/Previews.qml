import QtQuick 2.15
import Quickshell
import Quickshell.Services.SystemTray
import QtQml.Models 2.15
import "../resources/components" as Components
import "../resources/components/DialogService.js" as DialogService
import "../resources/components/layout" as Layout
import "../resources/components/typography" as Type
import "../resources/components/navigation" as Nav
import "../resources/components/actions" as Actions
import "../resources/components/toggles" as Toggles
import "../resources/components/inputs" as Inputs
import "../resources/components/feedback" as Feedback
import "../resources/components/system" as SystemComp
import "../resources/components/dialogs" as Dialogs
import "../resources/components/icons"
import "../resources/components/progress" as P
import "../resources/components/inputs/chips" as InputChips
import "../resources/components/search" as Search
import "../resources/components/Menu" as MenuComp
// Removed SystemTray import

FloatingWindow {
  id: previewWindow
  title: "Quickshell Previews"
  visible: true
  implicitWidth: 640
  implicitHeight: 420
  minimumSize: Qt.size(480, 360)

  Rectangle { anchors.fill: parent; color: Components.ColorPalette.isDarkMode ? Components.ColorPalette.background : Qt.darker(Components.ColorPalette.background, 1.08) }

  Nav.HeaderBar {
    id: bar
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    title: "Previews"
    titleAlignment: "center"
    onCloseRequested: previewWindow.visible = false
    z: 10
  }

  Layout.Container {
    id: area
    anchors.top: bar.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 16
  Column {
      spacing: 12
      Type.Label { text: "Preview Area"; color: Components.ColorPalette.onSurface; pixelSize: 18; bold: true; bottomMargin: 2 }

      // Transparent header demo
      Nav.HeaderBar { title: "Transparent Header"; titleAlignment: "center"; onCloseRequested: console.log("Header close clicked") }

      // Buttons and toggles
      Column {
        spacing: 12
        // Actions row
        Row {
          spacing: 12
          Actions.Button { text: "Primary" }
          Actions.Button { text: "Outlined"; outlined: true }
          Actions.Button { text: "Tonal"; tonal: true }
          Actions.Button { text: "Text"; textButton: true }
          Actions.Button { text: "Cancel"; outlined: true; kind: "cancel" }
          Actions.Button { text: "Danger"; kind: "danger" }
          Actions.Button {
            id: openTestDialogBtn
            text: "Test Dialog"
            tonal: true
            onClicked: {
              DialogService.show({ title: "Test Dialog", text: "Components preview.", primaryText: "Close", secondaryText: "", dismissible: true, clearContent: true, preferredWidth: 420 })
              var qml = 'import QtQuick 2.15; import "../resources/components/inputs" as I; import "../resources/components/actions" as A; import "../resources/components/feedback" as F; Column { spacing: 12; width: 360; I.TextField { placeholderText: "Name"; filled: true } I.Switch { id: s; } Row { spacing: 8; A.Button { text: "A" } A.Button { text: "B"; outlined: true } } F.ProgressBar { value: 0.42 } }'
              Qt.createQmlObject(qml, previewDialogHost.contentContainer)
            }
          }
        }
        // Animated Buttons (MD3E) - corners morph from pill to sharp when pressed
        Type.Label { text: "Animated Buttons (MD3E)"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; topMargin: 8 }
        Row {
          spacing: 12
          Actions.AnimatedButton { text: "Primary" }
          Actions.AnimatedButton { text: "Outlined"; outlined: true }
          Actions.AnimatedButton { text: "Tonal"; tonal: true }
          Actions.AnimatedButton { text: "Text"; textButton: true }
          Actions.AnimatedButton { text: "Cancel"; outlined: true; kind: "cancel" }
          Actions.AnimatedButton { text: "Danger"; kind: "danger" }
        }
        // Grouped Animated Buttons - press to expand
        Type.Label { text: "Grouped Animated Buttons"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; topMargin: 8 }
        Row {
          spacing: 8
          Actions.AnimatedGroupedButton {
            id: groupBtn1
            text: "Option A"
            siblingButton: groupBtn2
            onClicked: console.log("Option A clicked")
          }
          Actions.AnimatedGroupedButton {
            id: groupBtn2
            text: "Option B"
            tonal: true
            siblingButton: groupBtn1
            onClicked: console.log("Option B clicked")
          }
        }
        // Test windows - wrapped in Flow for better layout
        Flow {
          spacing: 8
          width: area.width - 32
          Actions.Button {
            id: openSearchTestBtn
            text: "Search Test"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestSearchWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestSearchWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: openConnTestBtn
            text: "Connectivity"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestConnectivityWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestConnectivityWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: openSettingsTestBtn
            text: "Settings"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestSettingsWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestSettingsWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: openInverseCornerTestBtn
            text: "Inverse Corners"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("InverseCornerTest.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create InverseCornerTest:", comp.errorString())
            }
          }
          Actions.Button {
            id: openSidePanelTestBtn
            text: "Side Panel"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("SidePanelDemo.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create SidePanelDemo:", comp.errorString())
            }
          }
          Actions.Button {
            id: openUserServiceTestBtn
            text: "User Service"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestUserServiceWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestUserServiceWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: openAppIconServiceTestBtn
            text: "App Icons"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestAppIconService.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestAppIconService:", comp.errorString())
            }
          }
          Actions.Button {
            id: openKeypressWatcherTestBtn
            text: "Keypress Watcher"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestKeypressWatcher.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestKeypressWatcher:", comp.errorString())
            }
          }
          Actions.Button {
            id: openMediaCardTestBtn
            text: "Media Card"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestMediaCard.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestMediaCard:", comp.errorString())
            }
          }
          Actions.Button {
            id: openHamburgerMenuTestBtn
            text: "Hamburger Menu"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("HamburgerMenuPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create HamburgerMenuPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openNavigationRailTestBtn
            text: "Navigation Rail"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("NavigationRailPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create NavigationRailPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openNavigationDrawerTestBtn
            text: "Navigation Drawer"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("NavigationDrawerPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create NavigationDrawerPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openTabsTestBtn
            text: "Tabs"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TabsPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TabsPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openToastTestBtn
            text: "Toast"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("ToastPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create ToastPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openCarouselTestBtn
            text: "Carousel"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("CarouselPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create CarouselPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openDatePickerTestBtn
            text: "Date Picker"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("DatePickerPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create DatePickerPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openTimePickerTestBtn
            text: "Time Picker"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TimePickerPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TimePickerPreview:", comp.errorString())
            }
          }
          Actions.Button {
            id: openExpressiveLoadingTestBtn
            text: "Expressive Loading"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("ExpressiveLoadingPreview.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create ExpressiveLoadingPreview:", comp.errorString())
            }
          }
        }
        Row {
          spacing: 12
          Actions.Button {
            id: dlgBtn
            text: "Open Dialog"
            tonal: true
            onClicked: {
              DialogService.show({ title: "Material Dialog", text: "This is a sample dialog.", primaryText: "OK", secondaryText: "Cancel", dismissible: false, clearContent: true })
            }
          }
          Actions.Button {
            id: heroDlgBtn
            text: "Hero Dialog"
            tonal: true
            onClicked: heroDialog.open = true
          }
          Actions.Button {
            id: menuPreviewBtn
            text: "Open Menu"
            outlined: true
            onClicked: testMenu.openAtItem(menuPreviewBtn)
          }
        }
        // Quick toggles — wrap when narrow
        Flow {
          spacing: 10
          width: area.width - 32
          Repeater {
            model: [
              { title: "AKU-Student", on: true, icon: "wifi" },
              { title: "Flashlight", on: false, icon: "flashlight" }
            ]
            delegate: Toggles.QuickToggle { title: modelData.title; subtitleOn: "On"; subtitleOff: "Off"; checked: modelData.on; iconName: modelData.icon }
          }
        }
        // Split buttons preview
        Row {
          spacing: 12
          Actions.SplitButton {
            id: splitRight
            text: "$ 7.49"
            showIcon: true
            orientation: "right"
            menuItems: [
              { label: "Buy now", onTriggered: function(){ console.log("Buy now") } },
              { label: "Add to wishlist", onTriggered: function(){ console.log("Wishlist") } }
            ]
          }
          Actions.SplitButton {
            id: splitLeft
            text: "Create"
            orientation: "left"
            menuItems: [
              { label: "New file", onTriggered: function(){ console.log("New file") } },
              { label: "New folder", onTriggered: function(){ console.log("New folder") } }
            ]
          }
          Actions.SplitButton { text: "Download"; orientation: "right" }
        }
        // Switcher demo inside a pill container
        Layout.PillContainer {
          padding: 6
          Row {
            spacing: 8
            Text { text: "WS:"; color: Components.ColorPalette.onSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
            Nav.IndexSwitcher { id: ws; count: 5; currentIndex: 1; anchors.verticalCenter: parent.verticalCenter }
          }
        }
        // Tab buttons demo with sliding indicator
        Layout.PillContainer {
          padding: 10
          Item {
            id: tabBar
            width: tabRow.implicitWidth
            height: tabRow.implicitHeight + 6
            property int currentIndex: 0
            function setTab(i) {
              if (i === currentIndex) return
              animateIndicatorTo(i)
              currentIndex = i
            }
            Row {
              id: tabRow
              spacing: 16
              Nav.TabButton { id: tab0; indicatorColor: "transparent"; iconName: "home";   label: "Home";   active: tabBar.currentIndex === 0; onClicked: tabBar.setTab(0) }
              Nav.TabButton { id: tab1; indicatorColor: "transparent"; iconName: "search"; label: "Search"; active: tabBar.currentIndex === 1; onClicked: tabBar.setTab(1) }
              Nav.TabButton { id: tab2; indicatorColor: "transparent"; iconName: "person"; label: "Profile"; active: tabBar.currentIndex === 2; onClicked: tabBar.setTab(2) }
            }
            Rectangle {
              id: movingIndicator
              y: tabRow.y + tabRow.height + 2
              height: 3
              radius: 1
              color: Components.ColorPalette.primary
              width: tab0.width
              x: tab0.x
            }
            SequentialAnimation {
              id: indicatorAnim
              running: false
              ParallelAnimation {
                id: phase1
                NumberAnimation { id: phase1X; target: movingIndicator; property: "x"; duration: 90; easing.type: Easing.OutCubic }
                NumberAnimation { id: phase1W; target: movingIndicator; property: "width"; duration: 90; easing.type: Easing.OutCubic }
              }
              ParallelAnimation {
                id: phase2
                NumberAnimation { id: phase2X; target: movingIndicator; property: "x"; duration: 90; easing.type: Easing.OutCubic }
                NumberAnimation { id: phase2W; target: movingIndicator; property: "width"; duration: 90; easing.type: Easing.OutCubic }
              }
            }
            function animateIndicatorTo(index) {
              var target = [tab0, tab1, tab2][index]
              var fromX = movingIndicator.x
              var fromW = movingIndicator.width
              var toX = target.x
              var toW = target.width
              var fromRight = fromX + fromW
              var toRight = toX + toW
              // First expand toward the target side, then slide/shrink to final
              indicatorAnim.stop()
              if (toX >= fromX) {
                // Move right: keep left edge, expand width to target right edge
                phase1X.to = Math.round(fromX)
                phase1W.to = Math.round(toRight - fromX)
              } else {
                // Move left: set left edge to target, expand width while keeping right edge
                phase1X.to = Math.round(toX)
                phase1W.to = Math.round(fromRight - toX)
              }
              phase2X.to = Math.round(toX)
              phase2W.to = Math.round(toW)
              indicatorAnim.start()
            }
            Component.onCompleted: animateIndicatorTo(0)
          }
        }
        // Bottom Navigation Bar demo
        Column {
          spacing: 12
          Type.Label { text: "Bottom Navigation Bar (with labels)"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; topMargin: 8 }
          Nav.BottomNavigationBar {
            id: bottomNav
            width: Math.min(480, area.width - 32)
            selectedIndex: 0
            showLabels: true
            items: [
              { icon: "\uE88A", label: "Home", onTriggered: function(){ console.log("Home") } },
              { icon: "\uE8B6", label: "Search", onTriggered: function(){ console.log("Search") } },
              { icon: "\uE02E", label: "Library", onTriggered: function(){ console.log("Library") } },
              { icon: "\uE7FD", label: "Profile", onTriggered: function(){ console.log("Profile") } }
            ]
          }
          Type.Label { text: "Bottom Navigation Bar (no labels)"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; topMargin: 8 }
          Nav.BottomNavigationBar {
            id: bottomNavNoLabels
            width: Math.min(480, area.width - 32)
            selectedIndex: 1
            showLabels: false
            items: [
              { icon: "\uE88A", label: "Home", onTriggered: function(){ console.log("Home") } },
              { icon: "\uE8B6", label: "Search", onTriggered: function(){ console.log("Search") } },
              { icon: "\uE02E", label: "Library", onTriggered: function(){ console.log("Library") } },
              { icon: "\uE7FD", label: "Profile", onTriggered: function(){ console.log("Profile") } }
            ]
          }
        }
      }

      // System Tray preview
      Column {
        spacing: 6
        Type.Label { text: "System Tray"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true; bottomMargin: 2 }
        Layout.PillContainer {
          padding: 6
          // Icon-only tray inside pill container
          SystemComp.SystemTrayView {
            id: trayView
            parentWindow: previewWindow
            iconSize: 22
          }
        }
      }

      Row { spacing: 12
        Actions.Button { text: "Disabled"; enabled: false }
        Actions.Button { text: "Busy"; busy: true }
      }

      // Round icon toggles & icon buttons demo
      Row {
        spacing: 12
          Toggles.RoundIconToggleBar {
          spacing: 12
          padding: 8
            Toggles.RoundIconToggle { iconName: "wifi"; checked: true }
            Toggles.RoundIconToggle { iconName: "bluetooth" }
            Toggles.RoundIconToggle { iconName: "flashlight" }
        }
        Row {
          spacing: 8
          Actions.IconButton { iconName: "home" }
          Actions.IconButton { iconName: "search" }
          Actions.IconButton { iconName: "person" }
          Nav.HamburgerMenuButton { diameter: 40; onClicked: console.log("Hamburger clicked") }
        }
      }

      // Progress bars
      Feedback.ProgressBar { value: 0.35 }
      Feedback.ProgressBar { indeterminate: true }

      Row { spacing: 12
        Column {
          spacing: 8
          // Progress demo using top-level imported alias P
          P.WavyProgressBar { progress: 0.40; amplitude: 10; wavelength: 36; strokeWidth: 4; knobShape: "circle"; width: 260 }
          P.WavyProgressBarSplit { progress: 0.55; amplitude: 7; wavelength: 40; strokeWidth: 4; width: 260 }
          P.WavyProgressBarSplit { progress: 0.30; amplitude: 6; wavelength: 28; strokeWidth: 3; endTipLength: 8; width: 260 }
          P.LinearProgressBarLine { progress: 0.75; thickness: 4; width: 260 }
          P.LinearProgressBarKnob { progress: 0.90; heightPixels: 16; knobShape: "circle"; width: 260 }
          P.LinearProgressBarKnob { progress: 0.92; heightPixels: 16; knobShape: "diamond"; width: 260 }
        }
        Layout.ListContainer {
          width: 220
          Layout.ListItem { text: "List item 1" }
          Layout.ListItem { text: "List item 2" }
          Layout.ListItem { text: "List item 3" }
        }
      }

      // Settings tiles preview
      Column {
        spacing: 2
        Type.Label { text: "Settings Tiles"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true; bottomMargin: 2 }
        Column {
          spacing: 2
          Layout.SettingsTile { title: "Test item A"; subtitle: "Subtitle"; groupRole: "top"; clickable: true; onClicked: console.log("tile A") }
          Layout.SettingsTile { title: "Test item B"; subtitle: "Longer subtitle for testing"; groupRole: "middle"; clickable: true }
          Layout.SettingsTile { title: "Test item C"; subtitle: "Disabled tile"; groupRole: "bottom"; clickable: false }
        }
      }

      Feedback.WaveformBar {
        id: demoWave
        samples: [0.2,0.4,0.6,0.5,0.8,0.3,0.7,0.5,0.4,0.6,0.3,0.2,0.5,0.7]
        progress: 0.45
        barColor: Components.ColorPalette.surfaceVariant
        playedColor: Components.ColorPalette.primary
        width: previewWindow.width - 64
        height: 28
      }

      // Switches and checkboxes
      Row {
        spacing: 12
        height: 32
        Type.Label { text: "Switch"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
        Inputs.Switch { id: a }
        Inputs.Switch { id: b; checked: true }
        Inputs.Switch { id: c; enabled: false }
      }
      Row {
        spacing: 12
        height: 28
        Type.Label { text: "Checkbox"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
        Inputs.Checkbox { text: "Option A" }
        Inputs.Checkbox { text: "Option B"; checked: true }
        Inputs.Checkbox { text: "Disabled (inactive)"; enabled: false }
        Inputs.Checkbox { text: "Disabled (active)"; checked: true; enabled: false }
      }

      // Radio buttons
      Column {
        // Add section spacing so adjacent groups don't visually collide
        spacing: 8
        // Wrap if they would overlap; use RadioGroup flow adoption for stable layout
        Inputs.RadioGroup {
          id: standaloneRG
          // Size to contents; avoid binding to parent width so it doesn't grow on resize
          wrap: true
          spacing: 4
          Inputs.RadioButton { text: "Standalone" }
          Inputs.RadioButton { text: "Checked"; checked: true }
          Inputs.RadioButton { text: "Disabled"; enabled: false }
          Inputs.RadioButton { text: "Dense"; dense: true }
          Inputs.RadioButton { text: "Disabled Checked"; enabled: false; checked: true }
        }
        // Grouped radios with dialog selector demo
        Row {
          spacing: 8
          Inputs.RadioGroup {
            id: rg1
            width: Math.min(420, area.width - 200)
            currentValue: "b"
            orientation: "horizontal"
            spacing: 4
            wrap: true
            Inputs.RadioButton { text: "Option A"; value: "a"; labelWrap: true; labelMaxWidth: 120 }
            Inputs.RadioButton { text: "Option B with a longer label that should wrap nicely"; value: "b"; labelWrap: true; labelMaxWidth: 160 }
            Inputs.RadioButton { text: "Option C"; value: "c" }
          }
          Actions.Button {
            id: openDialogBtn
            text: "Options"
            onClicked: {
              // Open dialog via service and safely clear previous content
              DialogService.show({ title: "Make a Selection", text: "Choose an option.", primaryText: "OK", secondaryText: "Cancel", dismissible: true, clearContent: true })
              var comp = Qt.createComponent("../resources/components/inputs/RadioGroup.qml")
              if (comp.status === Component.Ready) {
                var group = comp.createObject(previewDialogHost.contentContainer, {
                  wrap: true,
                  spacing: 4,
                  noWrapLabels: true,
                  fillLabelWidth: true,
                  fillWidth: true,
                  width: Qt.binding(function(){ return previewDialogHost.contentContainer.width })
                })
                var mk = function(txt, val){
                  var rbComp = Qt.createComponent("../resources/components/inputs/RadioButton.qml")
                  var rb = rbComp.createObject(group, { text: txt, value: val })
                  return rb
                }
                mk("Option A", "a")
                mk("Option B", "b")
                mk("Option C", "c")
                group.currentValue = rg1.currentValue
                group.changed.connect(function(v){ rg1.currentValue = v })
                // already parented to dialog content container
              }
            }
          }
          Actions.Button {
            id: openVerticalDialogBtn
            text: "List Options"
            outlined: true
            onClicked: {
              DialogService.show({ title: "Make a Selection", text: "Choose an option.", primaryText: "OK", secondaryText: "Cancel", dismissible: true, clearContent: true, preferredWidth: 360 })
              var comp = Qt.createComponent("../resources/components/inputs/RadioGroup.qml")
              if (comp.status === Component.Ready) {
                var group = comp.createObject(previewDialogHost.contentContainer, {
                  orientation: "vertical",
                  fillWidth: true,
                  spacing: 4,
                  noWrapLabels: true,
                  fillLabelWidth: true,
                  width: Qt.binding(function(){ return previewDialogHost.contentContainer.width })
                })
                var mk = function(txt, val){
                  var rbComp = Qt.createComponent("../resources/components/inputs/RadioButton.qml")
                  var rb = rbComp.createObject(group, { text: txt, value: val })
                  return rb
                }
                mk("Option A", "a")
                mk("Option B", "b")
                mk("Option C", "c")
                group.currentValue = rg1.currentValue
                group.changed.connect(function(v){ rg1.currentValue = v })
              }
            }
          }
          // time dialog opener moved to top row
            Text {
            id: selectionLabel
            anchors.verticalCenter: openDialogBtn.verticalCenter
            color: Components.ColorPalette.onSurface
              text: "Selection: " + rg1.currentValue
          }
        }
        // Error accent example
        Inputs.RadioGroup {
          id: rg2
          width: parent.width
          spacing: 4
          Inputs.RadioButton { text: "Safe"; value: "safe" }
          Inputs.RadioButton { text: "Danger"; value: "danger"; error: true }
          Inputs.RadioButton { text: "Cancel"; value: "cancel"; accent: Components.ColorPalette.onSurfaceVariant }
        }
        // Label on the left and vertical layout examples
        Inputs.RadioGroup {
          orientation: "vertical"
          spacing: 4
          Inputs.RadioButton { text: "Left Label"; labelPosition: "left" }
          Inputs.RadioButton { text: "Left + Dense with quite a long label to show wrapping"; labelPosition: "left"; dense: true; labelWrap: true; labelMaxWidth: 220 }
          Inputs.RadioButton { text: "Normal Right Label" }
        }
      }

      Row {
        spacing: 12
        height: 40
        Type.Label { text: "Segmented"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
        Actions.SegmentedControl { options: ["One","Two","Three"]; anchors.verticalCenter: parent.verticalCenter; onChanged: console.log("seg", index) }
        Loader {
          id: pillSegLoader
          anchors.verticalCenter: parent.verticalCenter
          source: "../resources/components/actions/SegmentedPill.qml"
          onLoaded: function(){ if (item) { item.options = ["Songs","Albums","Podcasts"]; } }
        }
      }

      Row {
        spacing: 12
        height: 40
        Type.Label { text: "Expander"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
        Actions.Expander { id: exp1; anchors.verticalCenter: parent.verticalCenter }
        Actions.Expander { id: exp2; hasBackground: false; anchors.verticalCenter: parent.verticalCenter }
        Actions.Expander { id: exp3; size: 32; iconSize: 18; direction: "horizontal"; anchors.verticalCenter: parent.verticalCenter }
        Type.Label { text: exp1.expanded ? "Expanded" : "Collapsed"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 12; verticalAlignment: Text.AlignVCenter; height: parent.height }
      }

      // Sliders
      Row {
        spacing: 12; height: 40
        Inputs.LinearSlider { id: prevSlider; value: 0.5; width: 320; anchors.verticalCenter: parent.verticalCenter }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(prevSlider.value * 100) + "%"
          color: Components.ColorPalette.onSurfaceVariant
          verticalAlignment: Text.AlignVCenter
          height: parent.height
        }
      }
      Row { spacing: 16; height: 80
        Inputs.CircularSlider { id: circ; value: 0.6; size: 80; anchors.verticalCenter: parent.verticalCenter }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(circ.value * 100) + "%"
          color: Components.ColorPalette.onSurfaceVariant
          verticalAlignment: Text.AlignVCenter
        }
      }
      // Split linear slider variants demo
      Column {
        spacing: 12
        Type.Label { text: "Split Linear Sliders"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true }
        // Standard slider
        Row {
          spacing: 12
          Item { width: (area.width - 64) / 3 - 8; height: 24
            Inputs.SplitLinearSlider { id: splitSlider; anchors.verticalCenter: parent.verticalCenter; width: parent.width; value: 0.35 }
          }
          // Centered slider
          Item { width: (area.width - 64) / 3 - 8; height: 24
            Inputs.CenteredSplitSlider { id: centeredSlider; anchors.verticalCenter: parent.verticalCenter; width: parent.width; value: 0.0 }
          }
          // Range slider
          Item { width: (area.width - 64) / 3 - 8; height: 24
            Inputs.RangeSplitSlider { id: rangeSlider; anchors.verticalCenter: parent.verticalCenter; width: parent.width; minValue: 0.25; maxValue: 0.75 }
          }
        }
        // Value labels
        Row {
          spacing: 12
          Type.Label { text: Math.round(splitSlider.value * 100) + "%"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; width: (area.width - 64) / 3 - 8; horizontalAlignment: Text.AlignHCenter }
          Type.Label { text: Math.round((centeredSlider.value - 0.5) * 200) + "%"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; width: (area.width - 64) / 3 - 8; horizontalAlignment: Text.AlignHCenter }
          Type.Label { text: Math.round(rangeSlider.minValue * 100) + "% - " + Math.round(rangeSlider.maxValue * 100) + "%"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 11; width: (area.width - 64) / 3 - 8; horizontalAlignment: Text.AlignHCenter }
        }
        // Type labels
        Row {
          spacing: 12
          Type.Label { text: "Standard"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 10; width: (area.width - 64) / 3 - 8; horizontalAlignment: Text.AlignHCenter }
          Type.Label { text: "Centered"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 10; width: (area.width - 64) / 3 - 8; horizontalAlignment: Text.AlignHCenter }
          Type.Label { text: "Range"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 10; width: (area.width - 64) / 3 - 8; horizontalAlignment: Text.AlignHCenter }
        }
      }

      // Text fields
      Inputs.TextField { placeholderText: "Filled"; filled: true }
      Inputs.TextField { placeholderText: "Error"; error: true; errorText: "Invalid value" }
      // Removed submenu test field per request
      // Rectangular text fields demo
      Column {
        spacing: 6
        Type.Label { text: "Rect Text Fields"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true }
        // Use the requested test layout
        Row { spacing: 16
          Type.Label { text: "\uF233"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 18 } // person icon placeholder
          Column { spacing: 12; width: area.width - 96
            Inputs.RectTextField {
              id: rectFirst
              labelText: "First name"
              placeholderText: "Odette"
              rectRadius: 0
              width: parent.width
              onTextChanged: {
                error = text.length > 20
                errorText = error ? "Max 20 characters" : ""
              }
            }
            Inputs.RectTextField {
              id: rectLast
              labelText: "Last name"
              placeholderText: "D'Ambricourt"
              rectRadius: 0
              width: parent.width
              onTextChanged: {
                error = text.length > 20
                errorText = error ? "Max 20 characters" : ""
              }
            }
          }
        }
      }
      // Test areas for length validation on multiple field types (<= 20 chars)
      Column {
        spacing: 8
        Type.Label { text: "Validation Tests (<= 20 chars)"; color: Components.ColorPalette.onSurface; pixelSize: 14; bold: true }
        Row { spacing: 12
      Inputs.TextField {
        id: tfA
        labelText: "Test A"
        placeholderText: "Type up to 20 chars"
        width: 320
        onTextChanged: { error = text.length > 20; errorText = error ? "Max 20 characters" : "" }
      }
      Inputs.TextField {
        id: tfB
        labelText: "Test B"
        placeholderText: "Type up to 20 chars"
        width: 320
        filled: true
        onTextChanged: { error = text.length > 20; errorText = error ? "Max 20 characters" : "" }
      }
      Inputs.UnderlineTextField {
        id: tfC
        placeholderText: "Underline variant"
        width: 320
        showHelper: error
        helperText: error ? "Max 20 characters" : ""
        onTextChanged: { error = text.length > 20 }
      }
      Inputs.RectTextField {
        id: tfD
        labelText: "Rect variant"
        placeholderText: "Up to 20 chars"
        width: 320
        onTextChanged: { error = text.length > 20; errorText = error ? "Max 20 characters" : "" }
      }
        }
      }
      Column {
        spacing: 8
        Type.Label { text: "Filled Text Fields"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true; bottomMargin: 4 }
        Inputs.UnderlineTextField { labelText: "Label"; helperText: "Supporting text"; showHelper: true }
        Inputs.UnderlineTextField { labelText: "Label"; showTrailingIcon: true; onTrailingIconClicked: text = "" }
        Inputs.UnderlineTextField { labelText: "Label"; showLeadingIcon: true }
        Inputs.UnderlineTextField { labelText: "Label"; showLeadingIcon: true; showTrailingIcon: true; onTrailingIconClicked: text = "" }
        Inputs.UnderlineTextField { labelText: "Label"; multiline: true; width: 400 }
      }

      // Animated Password Field
      Column {
        spacing: 8
        Type.Label { text: "Animated Password Field"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true }
        Loader {
          id: animPasswordLoader
          width: 400
          height: 56
          source: "../shell/lockscreen/AnimatedPasswordField.qml"
          onLoaded: {
            item.accepted.connect(function() {
              console.log("Password entered:", item.text)
              passwordResultText.text = "Password: " + item.text
              item.clear()
            })
          }
        }
        Type.Label {
          id: passwordResultText
          text: "Type a password and press Enter"
          color: Components.ColorPalette.onSurfaceVariant
          pixelSize: 12
        }
      }

      // Search component preview (pill style)
      Item { width: area.width - 64; height: searchDemo.implicitHeight
        Search.Search {
          id: searchDemo
          anchors.left: parent.left
          anchors.right: undefined
          placeholderText: "Search"
          rightActions: [ { iconName: "microphone", onTriggered: function(){ console.log("voice") } } ]
          onSubmitted: function(txt){ console.log("search submitted:", txt) }
        }
      }

      // Floating Action Button (FAB) previews
      Column {
        spacing: 12
        width: area.width - 64
        // 1) Normal FAB
        Item { width: parent.width; height: 80
          Actions.FAB { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 12; text: ""; autoExtendOnHover: false }
        }
        // 2) Extended FAB
        Item { width: parent.width; height: 80
          Actions.FAB { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 12; text: "Compose"; autoExtendOnHover: true }
        }
        // 3) Normal FAB (with menu)
        Item { width: parent.width; height: 160
          Actions.FAB {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 12
            autoExtendOnHover: false
            menuItems: [
              { icon: "home", label: "Document", onTriggered: function(){ console.log("doc") } },
              { icon: "search", label: "Message", onTriggered: function(){ console.log("message") } },
              { icon: "person", label: "Folder", onTriggered: function(){ console.log("folder") } }
            ]
          }
          // Tooltip demo — anchors to this item at an offset
          Feedback.Tooltip { id: tip1; anchors.fill: parent }
          Item { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 12; width: btn1.implicitWidth; height: btn1.implicitHeight
            Actions.Button { id: btn1; text: "Show tooltip"; outlined: true }
            MouseArea { anchors.fill: parent; onPressed: function(e){
              tip1.title = "FAB menu"
              tip1.text = "This section has a FAB with a menu."
              tip1.actions = [ { label: "OK" } ]
              var p = mapToItem(btn1, e.x, e.y)
              tip1.openFromEvent(btn1, p.x, p.y)
              e.accepted = true
            } }
          }
        }
        // 4) Extended FAB (with menu)
        Item { width: parent.width; height: 160
          Actions.FAB {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 12
            text: "Create"
            autoExtendOnHover: true
            menuItems: [
              { icon: "home", label: "Document", onTriggered: function(){ console.log("doc") } },
              { icon: "search", label: "Message", onTriggered: function(){ console.log("message") } },
              { icon: "person", label: "Folder", onTriggered: function(){ console.log("folder") } }
            ]
          }
          Feedback.Tooltip { id: tip2; anchors.fill: parent }
          Item { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 12; width: btn2.implicitWidth; height: btn2.implicitHeight
            Actions.Button { id: btn2; text: "Show tooltip (custom)"; tonal: true }
            MouseArea { anchors.fill: parent; onPressed: function(e){
              tip2.title = "Extended FAB"
              tip2.text = "Expands on hover. Two actions below."
              tip2.actions = [ { label: "Close" }, { label: "Details" } ]
              var p = mapToItem(btn2, e.x, e.y)
              tip2.openFromEvent(btn2, p.x, p.y)
              e.accepted = true
            } }
          }
        }
      }

      // Toolbar previews
      Column {
        spacing: 12
        width: area.width - 64
        Type.Label { text: "Toolbar"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true; bottomMargin: 2 }
        Row {
          spacing: 20
          Item { 
            width: 200
            height: 60
            Actions.Toolbar {
              orientation: "left"
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              actions: [
                { icon: "content_copy", onTriggered: function(){ console.log("Copy") } },
                { icon: "content_cut", onTriggered: function(){ console.log("Cut") } },
                { icon: "content_paste", onTriggered: function(){ console.log("Paste") } }
              ]
            }
          }
          Item { 
            width: 200
            height: 60
            Actions.Toolbar {
              orientation: "right"
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              actions: [
                { icon: "undo", onTriggered: function(){ console.log("Undo") } },
                { icon: "redo", onTriggered: function(){ console.log("Redo") } },
                { icon: "refresh", onTriggered: function(){ console.log("Refresh") } }
              ]
            }
          }
        }
        Row {
          spacing: 20
          Item { 
            width: 60
            height: 200
            Actions.Toolbar {
              orientation: "up"
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
              actions: [
                { icon: "arrow_upward", onTriggered: function(){ console.log("Up") } },
                { icon: "arrow_downward", onTriggered: function(){ console.log("Down") } },
                { icon: "close", onTriggered: function(){ console.log("Close") } }
              ]
            }
          }
          Item { 
            width: 60
            height: 200
            Actions.Toolbar {
              orientation: "down"
              anchors.top: parent.top
              anchors.horizontalCenter: parent.horizontalCenter
              actions: [
                { icon: "volume_up", onTriggered: function(){ console.log("Vol+") } },
                { icon: "volume_down", onTriggered: function(){ console.log("Vol-") } },
                { icon: "volume_off", onTriggered: function(){ console.log("Mute") } }
              ]
            }
          }
        }
      }

      // Tooltip hover-delay demo
      Item { width: area.width - 64; height: 80
        Actions.IconButton { id: infoBtn; iconName: "info"; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; onClicked: console.log("info clicked") }
        Feedback.Tooltip { id: hoverTip; anchors.fill: parent }
        Timer { id: hoverTimer; interval: 600; repeat: false; onTriggered: {
          hoverTip.title = "Info";
          hoverTip.text = "This tooltip appears after hover delay.";
          hoverTip.actions = [ { label: "Got it" } ];
          // Use last hover position mapped to the info button
          var p = hoverMA.mapToItem(infoBtn, hoverMA._lastX, hoverMA._lastY)
          hoverTip.openFromEvent(infoBtn, p.x, p.y)
        } }
        MouseArea {
          id: hoverMA
          anchors.fill: infoBtn
          hoverEnabled: true
          acceptedButtons: Qt.NoButton
          property real _lastX: 0
          property real _lastY: 0
          onEntered: hoverTimer.restart()
          onExited: { hoverTimer.stop(); hoverTip.close() }
          onPositionChanged: function(e){ _lastX = e.x; _lastY = e.y }
        }
      }

      // Additional list sample
      Layout.ListContainer {
        width: previewWindow.width - 64
        Row { spacing: 8; Text { text: "List item 1"; color: Components.ColorPalette.onSurface } }
        Row { spacing: 8; Text { text: "List item 2"; color: Components.ColorPalette.onSurface } }
        Row { spacing: 8; Text { text: "List item 3"; color: Components.ColorPalette.onSurface } }
      }

      // RoundedFrame preview (size + corner radius)
      Column {
        spacing: 8
        Type.Label { text: "RoundedFrame Preview"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true }
        Row {
          spacing: 16
          // Preview frame
          Layout.RoundedFrame {
            id: rfPrev
            width: Math.round(40 + rfSize.value * (220 - 40))
            height: width
            cornerRadius: Math.round(0 + rfRadius.value * (60 - 0))
            circular: rfCircle.checked
            source: "https://picsum.photos/seed/rounded-demo/800"
            borderColor: Components.ColorPalette.outline
            borderWidth: rfBorder.checked ? 1 : 0
          }
          // Controls
          Column {
            spacing: 6
            Row { spacing: 8; height: 28
              Type.Label { text: "Size:"; color: Components.ColorPalette.onSurfaceVariant; height: parent.height; verticalAlignment: Text.AlignVCenter }
              Inputs.LinearSlider { id: rfSize; value: 0.5; width: 220; anchors.verticalCenter: parent.verticalCenter }
              Type.Label { text: Math.round(40 + rfSize.value * (220 - 40)) + "px"; color: Components.ColorPalette.onSurfaceVariant; height: parent.height; verticalAlignment: Text.AlignVCenter }
            }
            Row { spacing: 8; height: 28
              Type.Label { text: "Radius:"; color: Components.ColorPalette.onSurfaceVariant; height: parent.height; verticalAlignment: Text.AlignVCenter }
              Inputs.LinearSlider { id: rfRadius; value: 0.2; width: 220; enabled: !rfCircle.checked; anchors.verticalCenter: parent.verticalCenter }
              Type.Label { text: Math.round(0 + rfRadius.value * (60 - 0)) + "px"; color: Components.ColorPalette.onSurfaceVariant; height: parent.height; verticalAlignment: Text.AlignVCenter }
            }
            Row { spacing: 8; height: 28
              Type.Label { text: "Circle:"; color: Components.ColorPalette.onSurfaceVariant; height: parent.height; verticalAlignment: Text.AlignVCenter }
              Inputs.Switch { id: rfCircle; anchors.verticalCenter: parent.verticalCenter }
            }
            Row { spacing: 8; height: 28
              Type.Label { text: "Border:"; color: Components.ColorPalette.onSurfaceVariant; height: parent.height; verticalAlignment: Text.AlignVCenter }
              Inputs.Switch { id: rfBorder; checked: true; anchors.verticalCenter: parent.verticalCenter }
            }
          }
        }
      }

      // Messages list with dividers and avatars
      Column {
        spacing: 6
        Type.Label { text: "Messages"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true }
        Layout.ListContainer {
          width: previewWindow.width - 64
          // Row 1
          Item {
            width: parent.width; height: 60
            Layout.Avatar { id: av1; size: 40; source: "https://picsum.photos/seed/a/100"; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
            Column {
              anchors.left: av1.right
              anchors.leftMargin: 10
              anchors.right: parent.right
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2
              Type.Label { text: "Brunch this weekend?"; pixelSize: 14; bold: true; color: Components.ColorPalette.onSurface; maxLines: 1; elide: Text.ElideRight }
              Type.Label { text: "Alejandro Ortega – I’ll be in your neighborhood…"; pixelSize: 12; color: Components.ColorPalette.onSurfaceVariant; maxLines: 1; elide: Text.ElideRight }
            }
          }
          Layout.Divider { orientation: "horizontal"; thickness: 1; lineColor: Components.ColorPalette.outline; insetStart: 58; width: parent.width }
          // Row 2
          Item {
            width: parent.width; height: 60
            Layout.Avatar { id: av2; size: 40; source: "https://picsum.photos/seed/b/100"; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
            Column {
              anchors.left: av2.right
              anchors.leftMargin: 10
              anchors.right: parent.right
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2
              Type.Label { text: "Good healthy lunch idea"; pixelSize: 14; bold: true; color: Components.ColorPalette.onSurface; maxLines: 1; elide: Text.ElideRight }
              Type.Label { text: "My coworker just sent this recipe to me and I…"; pixelSize: 12; color: Components.ColorPalette.onSurfaceVariant; maxLines: 1; elide: Text.ElideRight }
            }
          }
          Layout.Divider { orientation: "horizontal"; thickness: 1; lineColor: Components.ColorPalette.outline; insetStart: 58; width: parent.width }
          // Row 3
          Item {
            width: parent.width; height: 60
            Layout.Avatar { id: av3; size: 40; source: "https://picsum.photos/seed/c/100"; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
            Column {
              anchors.left: av3.right
              anchors.leftMargin: 10
              anchors.right: parent.right
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2
              Type.Label { text: "Graduación de Inés"; pixelSize: 14; bold: true; color: Components.ColorPalette.onSurface; maxLines: 1; elide: Text.ElideRight }
              Type.Label { text: "Hola hija mía, aqui tienes unas fotos preciosas…"; pixelSize: 12; color: Components.ColorPalette.onSurfaceVariant; maxLines: 1; elide: Text.ElideRight }
            }
          }
        }
      }

      // Filter Chips area
      Column {
        spacing: 8
        Type.Label { text: "Filter Chips"; color: Components.ColorPalette.onSurface; pixelSize: 16; bold: true }
        Row { spacing: 8
          InputChips.FilterChip { text: "Music" }
          InputChips.FilterChip { text: "Sports"; checked: true }
          InputChips.FilterChip { text: "News" }
          InputChips.FilterChip { text: "Tech" }
        }
        Type.Label { text: "Pill Variant"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 13; topMargin: 4 }
        Row { spacing: 8
          InputChips.FilterChip { text: "Music"; pill: true }
          InputChips.FilterChip { text: "Sports"; checked: true; pill: true }
          InputChips.FilterChip { text: "News"; pill: true }
          InputChips.FilterChip { text: "Tech"; pill: true }
        }
        Type.Label { text: "No Border"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 13; topMargin: 4 }
        Row { spacing: 8
          InputChips.FilterChip { text: "Music"; noBorder: true }
          InputChips.FilterChip { text: "Sports"; checked: true; noBorder: true }
          InputChips.FilterChip { text: "News"; noBorder: true }
          InputChips.FilterChip { text: "Tech"; noBorder: true }
        }
        Type.Label { text: "Primary When Selected"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 13; topMargin: 4 }
        Row { spacing: 8
          InputChips.FilterChip { text: "Music"; primaryWhenSelected: true }
          InputChips.FilterChip { text: "Sports"; checked: true; primaryWhenSelected: true }
          InputChips.FilterChip { text: "News"; primaryWhenSelected: true }
          InputChips.FilterChip { text: "Tech"; primaryWhenSelected: true }
        }
        Type.Label { text: "Combined: Pill + Primary"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 13; topMargin: 4 }
        Row { spacing: 8
          InputChips.FilterChip { text: "Music"; pill: true; primaryWhenSelected: true }
          InputChips.FilterChip { text: "Sports"; checked: true; pill: true; primaryWhenSelected: true }
          InputChips.FilterChip { text: "News"; pill: true; primaryWhenSelected: true }
          InputChips.FilterChip { text: "Tech"; pill: true; primaryWhenSelected: true }
        }
        Type.Label { text: "Segmented Style"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 13; topMargin: 4 }
        Row { spacing: 3
          InputChips.SegmentedFilterChip { text: "Music"; isFirst: true }
          InputChips.SegmentedFilterChip { text: "Sports"; checked: true }
          InputChips.SegmentedFilterChip { text: "News" }
          InputChips.SegmentedFilterChip { text: "Tech"; isLast: true }
        }
        Type.Label { text: "Custom Symbols"; color: Components.ColorPalette.onSurfaceVariant; pixelSize: 13; topMargin: 4 }
        Row { spacing: 8
          InputChips.FilterChip { text: "Favorite"; symbol: "★"; checked: true }
          InputChips.FilterChip { text: "Home"; symbol: "🏠" }
          InputChips.FilterChip { text: "Alert"; symbol: "⚠"; primaryWhenSelected: true }
          InputChips.FilterChip { text: "Music"; symbol: "♪"; pill: true; checked: true }
        }
      }

      // Loaders
      Row { spacing: 8; height: 32
        Feedback.CircularLoader { size: 24 }
        Feedback.CircularLoader { size: 36; color: Components.ColorPalette.secondary }
        Feedback.CircularLoader { size: 28; color: Components.ColorPalette.tertiary; strokeWidth: 4 }
      }

      // Circular progress demo
      Row { spacing: 16
        P.CircularProgressContainer { size: 80; progress: 0.65; centerText: "65%" }
        P.CircularProgressContainer { size: 64; progress: 0.3; progressColor: Components.ColorPalette.secondary; centerText: "30%" }
      }

      // Notification card demo
      Column {
        id: notifColumn
        spacing: 2
        onChildrenChanged: notifColumn.requestRoleRefresh()
        Timer { id: roleRefreshTimer; interval: 0; repeat: false; onTriggered: notifColumn.refreshNotifRoles() }
        Timer { id: roleRefreshEndTimer; interval: 240; repeat: false; onTriggered: notifColumn.refreshNotifRoles() }
        Row { spacing: 8
          Actions.Button { text: "Spawn"; tonal: true; onClicked: { notifColumn.spawnNotif() } }
        }
        Feedback.NotificationCard { id: notifA; title: "New message"; body: "You have a new message from Alex."; groupRole: "top"; onDismissed: { notifColumn.requestRoleRefresh() } }
        Feedback.NotificationCard { id: notifB; title: "System"; body: ""; showActions: false; groupRole: "bottom"; onDismissed: { notifColumn.requestRoleRefresh() } }

        function requestRoleRefresh() {
          roleRefreshTimer.restart()
          roleRefreshEndTimer.restart()
        }
        function refreshNotifRoles() {
          var cards = []
          for (var i = 0; i < notifColumn.children.length; i++) {
            var ch = notifColumn.children[i]
            if (ch && ch.isNotificationCard === true && ch.visible) cards.push(ch)
          }
          cards.sort(function(a, b) { return a.y - b.y })
          if (cards.length === 0) return
          if (cards.length === 1) { cards[0].groupRole = 'single'; return }
          for (var j = 0; j < cards.length; j++) {
            if (j === 0) cards[j].groupRole = 'top'
            else if (j === cards.length - 1) cards[j].groupRole = 'bottom'
            else cards[j].groupRole = 'middle'
          }
        }
        function spawnNotif() {
          var qml = 'import QtQuick 2.15; import "../resources/components/feedback" as Feedback; Feedback.NotificationCard { title: "Spawned"; body: "Another notification"; onDismissed: { parent.requestRoleRefresh() } }'
          Qt.createQmlObject(qml, notifColumn)
          notifColumn.requestRoleRefresh()
        }
      }


    }
  }

  // Dialog host for DialogService button above
  Dialogs.Dialog { id: previewDialogHost }
  
  // Hero dialog
  Dialogs.HeroDialog {
    id: heroDialog
    heroIcon: "restart"
    heroLabel: "Restart System"
    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
    primaryText: "Restart"
    secondaryText: "Cancel"
    onAccepted: console.log("Hero dialog accepted")
    onRejected: console.log("Hero dialog rejected")
  }

  // Animated test menu overlay
  MenuComp.HamburgerMenu {
    id: testMenu
    anchors.fill: parent
    items: [
      { label: "File",
        submenu: [
          { label: "New", onTriggered: function(){ console.log("New clicked") } },
          { label: "Open", onTriggered: function(){ console.log("Open clicked") } },
          { label: "Recent",
            submenu: [
              { label: "project-a" },
              { label: "project-b" },
              { label: "project-c" }
            ]
          },
          { label: "Exit", onTriggered: function(){ console.log("Exit clicked") } }
        ]
      },
      { label: "Edit",
        submenu: [
          { label: "Undo" },
          { label: "Redo" },
          { label: "Preferences" }
        ]
      },
      { label: "Help",
        submenu: [
          { label: "About" },
          { label: "Check for updates" }
        ]
      }
    ]
  }

  // SystemTrayView overlay handling removed

}
