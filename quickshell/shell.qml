//@ pragma UseQApplication
import QtQuick 2.15
import QtQuick.Layouts 1.15
import Quickshell
import "resources/colors.js" as Palette
import "resources/components/DialogService.js" as DialogService
import "shell/Shell.qml" as AppShell

FloatingWindow {
    id: window
    implicitWidth: 1
    implicitHeight: 1
    visible: false
    title: "Quickshell"
    minimumSize: Qt.size(480, 320)

    // Keep shell window hidden; LayerDialog/Preview windows handle UI
    Rectangle { anchors.fill: parent; color: "transparent"; visible: false }

        Component.onCompleted: {
            var comp = Qt.createComponent("views/LayerDialog.qml")
            if (comp.status === Component.Ready) {
                var dlg = comp.createObject(window)
                dlg.titleText = "Start Mode"
                dlg.bodyText = "Open preview window, start normal UI, or run Shell mode?"
                dlg.primaryText = "Normal"
                dlg.secondaryText = "Preview"
                dlg.tertiaryText = "Shell"
                dlg.dismissible = false
                dlg.accepted.connect(function(){
                    console.log("LayerDialog accepted -> Starting normally")
                })
                dlg.rejected.connect(function(){
                    console.log("LayerDialog rejected -> Opening Previews")
                    var p = Qt.createComponent("views/Previews.qml")
                    if (p.status === Component.Ready) {
                        var obj = p.createObject(window)
                        if (!obj) {
                            console.log("Failed to instantiate Previews.qml object:", p.errorString())
                        }
                    } else {
                        console.log("Failed to create Previews component:", p.errorString())
                    }
                })
                dlg.tertiarySelected.connect(function(){
                    console.log("LayerDialog tertiary -> Starting Shell mode")
                    var s = Qt.createComponent("shell/Shell.qml")
                    if (s.status === Component.Ready) {
                        var obj = s.createObject(window)
                        if (obj && obj.start) obj.start()
                        else console.log("Shell: created but no start()")
                    } else {
                        console.log("Failed to create Shell component:", s.errorString())
                    }
                })
                dlg.visible = true
            } else {
                console.log("Failed to create LayerDialog:", comp.errorString())
            }
        }

    // Shell only asks the start question now; all previews live in views/Previews.qml
}


