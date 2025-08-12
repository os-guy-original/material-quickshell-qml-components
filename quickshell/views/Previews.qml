import QtQuick 2.15
import Quickshell
import Quickshell.Services.SystemTray
import QtQml.Models 2.15
import "../resources/colors.js" as Palette
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

  Rectangle { anchors.fill: parent; color: Palette.palette().background }

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
      Type.Label { text: "Preview Area"; color: Palette.palette().onSurface; pixelSize: 18; bold: true; bottomMargin: 2 }

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
            id: openTimeDialogBtnTop
            text: "Select Time"
            onClicked: {
              DialogService.show({ title: "Select Time", text: "Choose an hour and minute.", primaryText: "OK", secondaryText: "Cancel", dismissible: true, clearContent: true, preferredWidth: 360 })
              var comp = Qt.createComponent("../resources/components/inputs/TimePicker.qml")
              if (comp.status === Component.Ready) {
                var picker = comp.createObject(previewDialogHost.contentContainer, { minuteStep: 5 })
                previewDialogHost._onAccepted = function(){ console.log("Selected time:", picker.hour + ":" + (picker.minute < 10 ? ("0"+picker.minute) : picker.minute)) }
              }
            }
          }
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
          Actions.Button {
            id: openSearchTestBtn
            text: "Open Search Test"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestSearchWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestSearchWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: openConnTestBtn
            text: "Connectivity Test"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestConnectivityWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestConnectivityWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: openSettingsTestBtn
            text: "Settings Test"
            outlined: true
            onClicked: {
              var comp = Qt.createComponent("TestSettingsWindow.qml")
              if (comp.status === Component.Ready) comp.createObject(previewWindow)
              else console.log("Failed to create TestSettingsWindow:", comp.errorString())
            }
          }
          Actions.Button {
            id: dlgBtn
            text: "Open Dialog"
            tonal: true
            onClicked: {
              DialogService.show({ title: "Material Dialog", text: "This is a sample dialog.", primaryText: "OK", secondaryText: "Cancel", dismissible: false, clearContent: true })
            }
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
            Text { text: "WS:"; color: Palette.palette().onSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
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
              color: Palette.palette().primary
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
      }

      // System Tray preview
      Column {
        spacing: 6
        Type.Label { text: "System Tray"; color: Palette.palette().onSurface; pixelSize: 16; bold: true; bottomMargin: 2 }
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
        Type.Label { text: "Settings Tiles"; color: Palette.palette().onSurface; pixelSize: 16; bold: true; bottomMargin: 2 }
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
        barColor: Palette.palette().surfaceVariant
        playedColor: Palette.palette().primary
        width: previewWindow.width - 64
        height: 28
      }

      // Switches and checkboxes
      Row {
        spacing: 12
        height: 32
        Type.Label { text: "Switch"; color: Palette.palette().onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
        Inputs.Switch { id: a }
        Inputs.Switch { id: b; checked: true }
        Inputs.Switch { id: c; enabled: false }
      }
      Row {
        spacing: 12
        height: 28
        Type.Label { text: "Checkbox"; color: Palette.palette().onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
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
            color: Palette.palette().onSurface
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
          Inputs.RadioButton { text: "Cancel"; value: "cancel"; accent: Palette.palette().onSurfaceVariant }
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
        Type.Label { text: "Segmented"; color: Palette.palette().onSurface; pixelSize: 14; bold: true; verticalAlignment: Text.AlignVCenter; height: parent.height }
        Actions.SegmentedControl { options: ["One","Two","Three"]; anchors.verticalCenter: parent.verticalCenter; onChanged: console.log("seg", index) }
        Loader {
          id: pillSegLoader
          anchors.verticalCenter: parent.verticalCenter
          source: "../resources/components/actions/SegmentedPill.qml"
          onLoaded: function(){ if (item) { item.options = ["Songs","Albums","Podcasts"]; } }
        }
      }

      // Sliders
      Row {
        spacing: 12; height: 40
        Inputs.LinearSlider { id: prevSlider; value: 0.5; width: 320; anchors.verticalCenter: parent.verticalCenter }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(prevSlider.value * 100) + "%"
          color: Palette.palette().onSurfaceVariant
          verticalAlignment: Text.AlignVCenter
          height: parent.height
        }
      }
      Row { spacing: 16; height: 80
        Inputs.CircularSlider { id: circ; value: 0.6; size: 80; anchors.verticalCenter: parent.verticalCenter }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(circ.value * 100) + "%"
          color: Palette.palette().onSurfaceVariant
          verticalAlignment: Text.AlignVCenter
        }
      }
      // New split linear slider demo
      Column {
        spacing: 6
        Type.Label { text: "Split Linear Slider"; color: Palette.palette().onSurface; pixelSize: 14; bold: true }
        Item { width: area.width - 64; height: 24
          Inputs.SplitLinearSlider { id: splitSlider; anchors.verticalCenter: parent.verticalCenter; width: parent.width; value: 0.35 }
        }
      }

      // Text fields
      Inputs.TextField { placeholderText: "Filled"; filled: true }
      Inputs.TextField { placeholderText: "Error"; error: true; errorText: "Invalid value" }
      // Removed submenu test field per request
      // Rectangular text fields demo
      Column {
        spacing: 6
        Type.Label { text: "Rect Text Fields"; color: Palette.palette().onSurface; pixelSize: 14; bold: true }
        // Use the requested test layout
        Row { spacing: 16
          Type.Label { text: "\uF233"; color: Palette.palette().onSurfaceVariant; pixelSize: 18 } // person icon placeholder
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
        Type.Label { text: "Validation Tests (<= 20 chars)"; color: Palette.palette().onSurface; pixelSize: 14; bold: true }
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
      Inputs.UnderlineTextField { placeholderText: "Email"; showLeadingIcon: true; leadingIcon: "" }
      Inputs.UnderlineTextField { placeholderText: "Dense"; dense: true; helperText: "Helper text"; showHelper: true }

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
        Row { spacing: 8; Text { text: "List item 1"; color: Palette.palette().onSurface } }
        Row { spacing: 8; Text { text: "List item 2"; color: Palette.palette().onSurface } }
        Row { spacing: 8; Text { text: "List item 3"; color: Palette.palette().onSurface } }
      }

      // Messages list with dividers and avatars
      Column {
        spacing: 6
        Type.Label { text: "Messages"; color: Palette.palette().onSurface; pixelSize: 16; bold: true }
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
              Type.Label { text: "Brunch this weekend?"; pixelSize: 14; bold: true; color: Palette.palette().onSurface; maxLines: 1; elide: Text.ElideRight }
              Type.Label { text: "Alejandro Ortega – I’ll be in your neighborhood…"; pixelSize: 12; color: Palette.palette().onSurfaceVariant; maxLines: 1; elide: Text.ElideRight }
            }
          }
          Layout.Divider { orientation: "horizontal"; thickness: 1; lineColor: Palette.palette().outline; insetStart: 58; width: parent.width }
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
              Type.Label { text: "Good healthy lunch idea"; pixelSize: 14; bold: true; color: Palette.palette().onSurface; maxLines: 1; elide: Text.ElideRight }
              Type.Label { text: "My coworker just sent this recipe to me and I…"; pixelSize: 12; color: Palette.palette().onSurfaceVariant; maxLines: 1; elide: Text.ElideRight }
            }
          }
          Layout.Divider { orientation: "horizontal"; thickness: 1; lineColor: Palette.palette().outline; insetStart: 58; width: parent.width }
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
              Type.Label { text: "Graduación de Inés"; pixelSize: 14; bold: true; color: Palette.palette().onSurface; maxLines: 1; elide: Text.ElideRight }
              Type.Label { text: "Hola hija mía, aqui tienes unas fotos preciosas…"; pixelSize: 12; color: Palette.palette().onSurfaceVariant; maxLines: 1; elide: Text.ElideRight }
            }
          }
        }
      }

      // Filter Chips area
      Column {
        spacing: 8
        Type.Label { text: "Filter Chips"; color: Palette.palette().onSurface; pixelSize: 16; bold: true }
        Row { spacing: 8
          InputChips.FilterChip { text: "Music" }
          InputChips.FilterChip { text: "Sports"; checked: true }
          InputChips.FilterChip { text: "News" }
          InputChips.FilterChip { text: "Tech" }
        }
      }

      // Loaders
      Row { spacing: 8; height: 32
        Feedback.CircularLoader { size: 24 }
        Feedback.CircularLoader { size: 36; color: Palette.palette().secondary }
        Feedback.CircularLoader { size: 28; color: Palette.palette().tertiary; strokeWidth: 4 }
      }

      // Circular progress demo
      Row { spacing: 16
        P.CircularProgressContainer { size: 80; progress: 0.65; centerText: "65%" }
        P.CircularProgressContainer { size: 64; progress: 0.3; progressColor: Palette.palette().secondary; centerText: "30%" }
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
