import QtQuick 2.15
import Quickshell
import Quickshell.Wayland

// Shell mode entrypoint: spawns our custom Wayland layer-shell widgets (bar, etc.)
QtObject {
  id: shell

  function start() {
    var comp = Qt.createComponent("widgets/Bar.qml")
    if (comp.status === Component.Ready) {
      var bar = comp.createObject(null)
      if (!bar) console.log("Shell: failed to instantiate Bar:", comp.errorString())
    } else {
      console.log("Shell: failed to create Bar component:", comp.errorString())
    }
  }
}


