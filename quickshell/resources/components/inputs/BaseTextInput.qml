import QtQuick 2.15
import "../../colors.js" as Palette

// Common TextInput defaults for all input components
TextInput {
  id: base
  // Selection styling and behavior
  selectionColor: Qt.darker(Palette.palette().primary, 1.8)
  selectByMouse: true
  // Drag to select characters by default; double-click still selects word
  mouseSelectionMode: TextInput.SelectCharacters
}


