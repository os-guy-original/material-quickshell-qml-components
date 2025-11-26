import QtQuick 2.15
import "../../colors.js" as Palette
import ".." as Components
import "../icons" as Icon

Item {
    id: root

    property date selectedDate: new Date()
    property date displayedMonth: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    
    // View modes: "calendar", "month", "year"
    property string viewMode: "calendar"
    property int yearGridStart: Math.floor(displayedMonth.getFullYear() / 12) * 12
    property bool transparentBackground: false
    property bool showButtons: true
    
    signal dateChanged(date newDate)
    signal accepted()
    signal cancelled()

    width: 320
    height: 360 - (showButtons ? 0 : 48)

    function pad2(n) { return n < 10 ? "0" + n : "" + n }
    
    function formatDate(d) {
        var month = pad2(d.getMonth() + 1)
        var day = pad2(d.getDate())
        var year = d.getFullYear()
        return month + "/" + day + "/" + year
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay()
    }

    function isSameDay(d1, d2) {
        return d1.getFullYear() === d2.getFullYear() &&
               d1.getMonth() === d2.getMonth() &&
               d1.getDate() === d2.getDate()
    }

    function isToday(d) {
        return isSameDay(d, new Date())
    }

    function prevMonth() {
        var newMonth = displayedMonth.getMonth() - 1
        var newYear = displayedMonth.getFullYear()
        if (newMonth < 0) {
            newMonth = 11
            newYear--
        }
        displayedMonth = new Date(newYear, newMonth, 1)
    }

    function nextMonth() {
        var newMonth = displayedMonth.getMonth() + 1
        var newYear = displayedMonth.getFullYear()
        if (newMonth > 11) {
            newMonth = 0
            newYear++
        }
        displayedMonth = new Date(newYear, newMonth, 1)
    }

    function prevYear() {
        displayedMonth = new Date(displayedMonth.getFullYear() - 1, displayedMonth.getMonth(), 1)
    }

    function nextYear() {
        displayedMonth = new Date(displayedMonth.getFullYear() + 1, displayedMonth.getMonth(), 1)
    }

    function prevYearPage() {
        yearGridStart -= 12
    }

    function nextYearPage() {
        yearGridStart += 12
    }

    function selectDate(day) {
        selectedDate = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth(), day)
        dateChanged(selectedDate)
    }

    function selectMonth(month) {
        displayedMonth = new Date(displayedMonth.getFullYear(), month, 1)
        viewMode = "calendar"
    }

    function selectYear(year) {
        displayedMonth = new Date(year, displayedMonth.getMonth(), 1)
        viewMode = "month"
    }

    readonly property var monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    readonly property var monthNamesFull: ["January", "February", "March", "April", "May", "June", 
                                            "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["S", "M", "T", "W", "T", "F", "S"]

    // Calendar container
    Rectangle {
        id: calendarContainer
        anchors.fill: parent
        color: transparentBackground ? "transparent" : Palette.palette().surfaceContainerHighest
        radius: transparentBackground ? 0 : 16

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Navigation header
            Item {
                width: parent.width
                height: 40

                // Calendar mode header
                Row {
                    anchors.fill: parent
                    spacing: 0
                    visible: viewMode === "calendar"
                    opacity: viewMode === "calendar" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    // Month navigation
                    Item {
                        width: parent.width * 0.5
                        height: parent.height

                        Row {
                            anchors.centerIn: parent
                            spacing: 2

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: monthPrevMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                                Icon.Icon { anchors.centerIn: parent; name: "chevron_left"; size: 18; color: Palette.palette().onSurfaceVariant }
                                MouseArea { id: monthPrevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: prevMonth() }
                            }

                            Rectangle {
                                width: monthBtnText.implicitWidth + 22; height: 28; radius: 14
                                color: monthBtnMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                                Text { id: monthBtnText; anchors.centerIn: parent; text: monthNames[displayedMonth.getMonth()]; color: Palette.palette().onSurfaceVariant; font.pixelSize: 14 }
                                MouseArea { id: monthBtnMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: viewMode = "month" }
                            }

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: monthNextMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                                Icon.Icon { anchors.centerIn: parent; name: "chevron_right"; size: 18; color: Palette.palette().onSurfaceVariant }
                                MouseArea { id: monthNextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nextMonth() }
                            }
                        }
                    }

                    // Year navigation
                    Item {
                        width: parent.width * 0.5
                        height: parent.height

                        Row {
                            anchors.centerIn: parent
                            spacing: 2

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: yearPrevMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                                Icon.Icon { anchors.centerIn: parent; name: "chevron_left"; size: 18; color: Palette.palette().onSurfaceVariant }
                                MouseArea { id: yearPrevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: prevYear() }
                            }

                            Rectangle {
                                width: yearBtnText.implicitWidth + 22; height: 28; radius: 14
                                color: yearBtnMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                                Text { id: yearBtnText; anchors.centerIn: parent; text: displayedMonth.getFullYear(); color: Palette.palette().onSurfaceVariant; font.pixelSize: 14 }
                                MouseArea { id: yearBtnMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { yearGridStart = Math.floor(displayedMonth.getFullYear() / 12) * 12; viewMode = "year" } }
                            }

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: yearNextMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                                Icon.Icon { anchors.centerIn: parent; name: "chevron_right"; size: 18; color: Palette.palette().onSurfaceVariant }
                                MouseArea { id: yearNextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nextYear() }
                            }
                        }
                    }
                }

                // Month selection mode header
                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    visible: viewMode === "month"
                    opacity: viewMode === "month" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: monthYearPrevMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                        Icon.Icon { anchors.centerIn: parent; name: "chevron_left"; size: 18; color: Palette.palette().onSurfaceVariant }
                        MouseArea { id: monthYearPrevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: prevYear() }
                    }

                    Rectangle {
                        width: monthYearText.implicitWidth + 22; height: 28; radius: 14
                        color: Palette.palette().primaryContainer
                        Text { id: monthYearText; anchors.centerIn: parent; text: displayedMonth.getFullYear(); color: Palette.palette().onPrimaryContainer; font.pixelSize: 14; font.bold: true }
                        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { yearGridStart = Math.floor(displayedMonth.getFullYear() / 12) * 12; viewMode = "year" } }
                    }

                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: monthYearNextMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                        Icon.Icon { anchors.centerIn: parent; name: "chevron_right"; size: 18; color: Palette.palette().onSurfaceVariant }
                        MouseArea { id: monthYearNextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nextYear() }
                    }
                }

                // Year selection mode header
                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    visible: viewMode === "year"
                    opacity: viewMode === "year" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: yearPagePrevMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                        Icon.Icon { anchors.centerIn: parent; name: "chevron_left"; size: 18; color: Palette.palette().onSurfaceVariant }
                        MouseArea { id: yearPagePrevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: prevYearPage() }
                    }

                    Rectangle {
                        width: yearRangeText.implicitWidth + 22; height: 28; radius: 14
                        color: Palette.palette().primaryContainer
                        Text { id: yearRangeText; anchors.centerIn: parent; text: yearGridStart + " – " + (yearGridStart + 11); color: Palette.palette().onPrimaryContainer; font.pixelSize: 14; font.bold: true }
                    }

                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: yearPageNextMA.containsMouse ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent"
                        Icon.Icon { anchors.centerIn: parent; name: "chevron_right"; size: 18; color: Palette.palette().onSurfaceVariant }
                        MouseArea { id: yearPageNextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: nextYearPage() }
                    }
                }
            }

            // Content area with crossfade
            Item {
                width: parent.width
                height: 32 + 36 * 6  // Day header + 6 rows

                // Calendar view
                Item {
                    anchors.fill: parent
                    visible: viewMode === "calendar"
                    opacity: viewMode === "calendar" ? 1 : 0
                    scale: viewMode === "calendar" ? 1 : 0.95
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Column {
                        anchors.fill: parent
                        spacing: 0

                        // Day names header
                        Row {
                            width: parent.width
                            height: 32

                            Repeater {
                                model: dayNames
                                delegate: Item {
                                    width: parent.width / 7
                                    height: 32
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: Palette.palette().onSurface
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // Calendar grid
                        Grid {
                            id: calendarGrid
                            width: parent.width
                            columns: 7
                            rows: 6
                            
                            property int daysCount: daysInMonth(displayedMonth.getFullYear(), displayedMonth.getMonth())
                            property int firstDay: firstDayOfMonth(displayedMonth.getFullYear(), displayedMonth.getMonth())
                            property int prevMonthDays: displayedMonth.getMonth() === 0 
                                ? daysInMonth(displayedMonth.getFullYear() - 1, 11)
                                : daysInMonth(displayedMonth.getFullYear(), displayedMonth.getMonth() - 1)

                            Repeater {
                                model: 42

                                delegate: Item {
                                    width: calendarGrid.width / 7
                                    height: 36

                                    property int dayNumber: {
                                        var idx = index
                                        var first = calendarGrid.firstDay
                                        var days = calendarGrid.daysCount
                                        var prevDays = calendarGrid.prevMonthDays
                                        
                                        if (idx < first) return prevDays - first + idx + 1
                                        else if (idx < first + days) return idx - first + 1
                                        else return idx - first - days + 1
                                    }

                                    property bool isCurrentMonthDay: {
                                        var idx = index
                                        var first = calendarGrid.firstDay
                                        var days = calendarGrid.daysCount
                                        return idx >= first && idx < first + days
                                    }

                                    property date cellDate: {
                                        var idx = index
                                        var first = calendarGrid.firstDay
                                        var days = calendarGrid.daysCount
                                        var year = displayedMonth.getFullYear()
                                        var month = displayedMonth.getMonth()
                                        
                                        if (idx < first) {
                                            return month === 0 ? new Date(year - 1, 11, dayNumber) : new Date(year, month - 1, dayNumber)
                                        } else if (idx < first + days) {
                                            return new Date(year, month, dayNumber)
                                        } else {
                                            return month === 11 ? new Date(year + 1, 0, dayNumber) : new Date(year, month + 1, dayNumber)
                                        }
                                    }

                                    property bool isSelected: isSameDay(cellDate, selectedDate)
                                    property bool isTodayCell: isToday(cellDate)
                                    property bool isHovered: dayMA.containsMouse

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 32; height: 32; radius: 16
                                        color: isSelected ? Palette.palette().primary : (isHovered && isCurrentMonthDay ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent")
                                        border.width: isTodayCell && !isSelected ? 1 : 0
                                        border.color: Palette.palette().primary
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: dayNumber
                                        color: isSelected ? Palette.palette().onPrimary : (!isCurrentMonthDay ? Palette.palette().onSurfaceVariant : Palette.palette().onSurface)
                                        font.pixelSize: 14
                                        opacity: isCurrentMonthDay ? 1.0 : 0.5
                                    }

                                    MouseArea {
                                        id: dayMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (isCurrentMonthDay) {
                                                selectDate(dayNumber)
                                            } else {
                                                selectedDate = cellDate
                                                displayedMonth = new Date(cellDate.getFullYear(), cellDate.getMonth(), 1)
                                                dateChanged(selectedDate)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Month selection grid (4x3)
                Item {
                    anchors.fill: parent
                    visible: viewMode === "month"
                    opacity: viewMode === "month" ? 1 : 0
                    scale: viewMode === "month" ? 1 : 0.95
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Grid {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height - 16
                        columns: 4
                        rows: 3
                        
                        property int currentMonth: (new Date()).getMonth()
                        property int currentYear: (new Date()).getFullYear()

                        Repeater {
                            model: 12

                            delegate: Item {
                                width: parent.width / 4
                                height: parent.height / 3

                                property bool isSelected: index === displayedMonth.getMonth()
                                property bool isCurrentMonth: index === parent.currentMonth && displayedMonth.getFullYear() === parent.currentYear
                                property bool isHovered: monthItemMA.containsMouse

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 64; height: 40; radius: 20
                                    color: isSelected ? Palette.palette().primary : (isHovered ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent")
                                    border.width: isCurrentMonth && !isSelected ? 1 : 0
                                    border.color: Palette.palette().primary
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: monthNames[index]
                                    color: isSelected ? Palette.palette().onPrimary : Palette.palette().onSurface
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: monthItemMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: selectMonth(index)
                                }
                            }
                        }
                    }
                }

                // Year selection grid (4x3)
                Item {
                    anchors.fill: parent
                    visible: viewMode === "year"
                    opacity: viewMode === "year" ? 1 : 0
                    scale: viewMode === "year" ? 1 : 0.95
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Grid {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height - 16
                        columns: 4
                        rows: 3
                        
                        property int currentYear: (new Date()).getFullYear()

                        Repeater {
                            model: 12

                            delegate: Item {
                                width: parent.width / 4
                                height: parent.height / 3

                                property int yearValue: yearGridStart + index
                                property bool isSelected: yearValue === displayedMonth.getFullYear()
                                property bool isCurrentYear: yearValue === parent.currentYear
                                property bool isHovered: yearItemMA.containsMouse

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 64; height: 40; radius: 20
                                    color: isSelected ? Palette.palette().primary : (isHovered ? Qt.rgba(Palette.palette().onSurface.r, Palette.palette().onSurface.g, Palette.palette().onSurface.b, 0.08) : "transparent")
                                    border.width: isCurrentYear && !isSelected ? 1 : 0
                                    border.color: Palette.palette().primary
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: yearValue
                                    color: isSelected ? Palette.palette().onPrimary : Palette.palette().onSurface
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: yearItemMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: selectYear(yearValue)
                                }
                            }
                        }
                    }
                }
            }

            // Action buttons row
            Item {
                visible: showButtons
                width: parent.width
                height: showButtons ? 40 : 0

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: cancelText.implicitWidth + 24; height: 36; radius: 18
                        color: cancelMA.containsMouse ? Qt.rgba(Palette.palette().primary.r, Palette.palette().primary.g, Palette.palette().primary.b, 0.08) : "transparent"
                        Text { id: cancelText; anchors.centerIn: parent; text: "Cancel"; color: Palette.palette().primary; font.pixelSize: 14 }
                        MouseArea { id: cancelMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: cancelled() }
                    }

                    Rectangle {
                        width: okText.implicitWidth + 24; height: 36; radius: 18
                        color: okMA.containsMouse ? Qt.rgba(Palette.palette().primary.r, Palette.palette().primary.g, Palette.palette().primary.b, 0.08) : "transparent"
                        Text { id: okText; anchors.centerIn: parent; text: "OK"; color: Palette.palette().primary; font.pixelSize: 14 }
                        MouseArea { id: okMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: accepted() }
                    }
                }
            }
        }
    }
}
