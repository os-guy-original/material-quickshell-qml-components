import QtQuick 2.15
import Quickshell
import "../resources/components" as Components
import "../resources/components/actions" as Actions
import "../resources/components/feedback" as Feedback
import "../resources/components/inputs" as Inputs
import "../resources/components/layout" as Layout

// Compatibility wrapper that opens the new Demo window.
// Use QtObject to avoid creating a visual item under the hidden shell window.
QtObject {
  Component.onCompleted: {
    var comp = Qt.createComponent("Demo/DemoWindow.qml")
    if (comp.status === Component.Ready) {
      var obj = comp.createObject(null)
      if (!obj) {
        console.log("Failed to instantiate DemoWindow")
      }
    } else {
      console.log("Failed to create DemoWindow component:", comp.errorString())
    }
  }
}


