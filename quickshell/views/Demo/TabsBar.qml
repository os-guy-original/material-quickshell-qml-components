import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../resources/components/navigation" as Nav

RowLayout {
  id: root
  property int index: 0
  spacing: 4
  Layout.fillWidth: true

  Nav.TabButton {
    label: "Home"
    iconName: "home"
    active: root.index === 0
    onClicked: root.index = 0
  }
  Nav.TabButton {
    label: "Search"
    iconName: "search"
    active: root.index === 1
    onClicked: root.index = 1
  }
  Nav.TabButton {
    label: "Profile"
    iconName: "person"
    active: root.index === 2
    onClicked: root.index = 2
  }
  Item { Layout.fillWidth: true }
}


