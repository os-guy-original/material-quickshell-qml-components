import QtQuick 2.15

MouseArea {
    property bool isHovered: false
    
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    
    onEntered: isHovered = true
    onExited: isHovered = false
}
