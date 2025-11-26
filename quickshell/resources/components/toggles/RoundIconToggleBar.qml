import QtQuick 2.15
import "../layout" as Layout

// A horizontal grouping container for multiple RoundIconToggle items,
// wrapped in PillContainer as requested.
Item {
    id: root
    property int spacing: 10
    property int padding: 8
    default property alias content: row.data

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Layout.PillContainer {
        id: pill
        padding: root.padding

        Row {
            id: row
            spacing: root.spacing
        }
    }
}


