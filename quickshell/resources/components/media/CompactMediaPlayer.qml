import QtQuick 2.15
import Quickshell.Services.Mpris
import ".." as Components
import "../typography" as Type
import "../progress" as Progress
import "../feedback" as Feedback
import "../actions" as Actions
import "../layout" as Layout
import "../../../shell/services"
import "../../../shell/utils/mpris.js" as MprisUtils

Item {
    id: root
    width: parent.width
    height: headerRow.height + (isExpanded ? mediaContent.contentHeight + 8 : 0)
    visible: Mpris.players.values.length > 0
    
    property real currentPlayerIndex: 0
    property var player: Mpris.players.values.length > Math.round(currentPlayerIndex) ? Mpris.players.values[Math.round(currentPlayerIndex)] : null
    
    Behavior on currentPlayerIndex {
        NumberAnimation { 
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    property bool isExpanded: true

    property real swipeOffset: 0
    property int cardSpacing: 12
    property bool isSwipeAnimating: false
    
    Behavior on swipeOffset {
        enabled: root.isSwipeAnimating
        NumberAnimation { 
            id: swipeAnimation
            duration: 150
            easing.type: Easing.OutCubic
            onRunningChanged: {
                if (!running && root.isSwipeAnimating) {
                    root.isSwipeAnimating = false
                }
            }
        }
    }
    
    Behavior on height {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    
    // Header with label and expand/collapse button
    Item {
        id: headerRow
        width: parent.width
        height: 32
        
        Type.Label {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Current Media"
            pixelSize: 12
            bold: true
            color: Components.ColorPalette.onSurface
        }
        
        Actions.Expander {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            expanded: root.isExpanded
            onToggled: function(isExpanded) {
                root.isExpanded = isExpanded
            }
        }
    }
    
    // Media player content container
    Item {
        id: mediaContent
        anchors.top: headerRow.bottom
        anchors.topMargin: 8
        width: parent.width
        height: root.isExpanded ? contentHeight : 0
        clip: true
        opacity: root.isExpanded ? 1 : 0
        
        property int contentHeight: 160
        
        Behavior on height {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }
        
        // Cards container that slides
        Item {
            id: cardsContainer
            width: parent.width * Math.max(1, Mpris.players.values.length) + root.cardSpacing * Math.max(0, Mpris.players.values.length - 1)
            height: parent.height
            x: -root.currentPlayerIndex * (mediaContent.width + root.cardSpacing) + root.swipeOffset
            
            // Generate a card for each player
            Repeater {
                model: Mpris.players.values.length
                
                Item {
                    id: playerCard
                    width: mediaContent.width
                    height: mediaContent.height
                    x: index * (width + root.cardSpacing)
                    
                    property var cardPlayer: Mpris.players.values[index]
                    property string currentTrackUrl: cardPlayer ? (cardPlayer.trackArtUrl || "") : ""
                    property bool isBrowser: cardPlayer ? MprisUtils.isBrowser(cardPlayer.identity) : false
                    
                    property color cardAccentColor: Components.ColorPalette.primary
                    property color cardOnAccentColor: Components.ColorPalette.onPrimary
                    
                    Behavior on cardAccentColor {
                        ColorAnimation { duration: 400; easing.type: Easing.InOutCubic }
                    }
                    
                    Behavior on cardOnAccentColor {
                        ColorAnimation { duration: 400; easing.type: Easing.InOutCubic }
                    }
                    
                    property bool isCardDragging: false
                    property real cardDisplayPosition: 0
                    property real cardLastKnownPosition: 0
                    property real cardLastUpdateTime: 0
                    property real cardLastSeekTime: 0
                    
                    Component.onCompleted: {
                        if (cardPlayer) {
                            var pos = cardPlayer.position || 0
                            cardLastKnownPosition = pos
                            cardLastUpdateTime = Date.now()
                            cardDisplayPosition = pos
                        }
                        
                        if (currentTrackUrl) {
                            extractCardColor()
                        }
                    }
                    
                    onCurrentTrackUrlChanged: {
                        if (currentTrackUrl) {
                            extractCardColor()
                        }
                    }
                    
                    function extractCardColor() {
                        if (!currentTrackUrl) {
                            // Use default colors
                            playerCard.cardAccentColor = Components.ColorPalette.primary
                            playerCard.cardOnAccentColor = Components.ColorPalette.onPrimary
                            return
                        }
                        
                        var cached = ColorExtractorService.cache[currentTrackUrl]
                        if (cached && cached.primary) {
                            playerCard.cardAccentColor = cached.primary
                            playerCard.cardOnAccentColor = cached.onPrimary || Components.ColorPalette.onPrimary
                        } else {
                            // Use default colors while extracting
                            playerCard.cardAccentColor = Components.ColorPalette.primary
                            playerCard.cardOnAccentColor = Components.ColorPalette.onPrimary
                            ColorExtractorService.extractColor(currentTrackUrl)
                        }
                    }
                    
                    Connections {
                        target: ColorExtractorService
                        function onColorExtracted(imageUrl, extractedColors) {
                            if (currentTrackUrl === imageUrl) {
                                if (extractedColors && extractedColors.primary) {
                                    playerCard.cardAccentColor = extractedColors.primary
                                    playerCard.cardOnAccentColor = extractedColors.onPrimary || Components.ColorPalette.onPrimary
                                } else {
                                    // Extraction failed, use default colors
                                    playerCard.cardAccentColor = Components.ColorPalette.primary
                                    playerCard.cardOnAccentColor = Components.ColorPalette.onPrimary
                                }
                            }
                        }
                    }
                    
                    Connections {
                        target: cardPlayer
                        function onPositionChanged() {
                            if (!isCardDragging && cardPlayer) {
                                var now = Date.now()
                                var newPos = cardPlayer.position || 0
                                // Ignore position updates for 500ms after seeking to avoid jumps
                                if (now - cardLastSeekTime > 500) {
                                    // Only accept position updates that move forward or are significantly different (>2s backwards = likely a real seek)
                                    if (newPos >= cardDisplayPosition || Math.abs(newPos - cardDisplayPosition) > 2) {
                                        cardLastKnownPosition = newPos
                                        cardLastUpdateTime = now
                                        cardDisplayPosition = newPos
                                    }
                                }
                            }
                        }
                        function onTrackTitleChanged() {
                            cardLastKnownPosition = 0
                            cardLastUpdateTime = Date.now()
                            cardDisplayPosition = 0
                            cardLastSeekTime = 0
                        }
                    }
                    
                    Timer {
                        interval: 500  // Reduced from 100ms to 500ms to save CPU
                        running: cardPlayer && cardPlayer.isPlaying && !isCardDragging
                        repeat: true
                        onTriggered: {
                            if (!isCardDragging && cardPlayer && cardPlayer.isPlaying) {
                                var elapsed = (Date.now() - cardLastUpdateTime) / 1000
                                var calculatedPos = cardLastKnownPosition + elapsed
                                if (calculatedPos <= cardPlayer.length) {
                                    cardDisplayPosition = calculatedPos
                                }
                            }
                        }
                    }
                    
                    // Card content
                    Item {
                        anchors.fill: parent
                            
                            // Background with album art using RoundedFrame
                            Layout.RoundedFrame {
                                anchors.fill: parent
                                cornerRadius: 16
                                source: cardPlayer ? (cardPlayer.trackArtUrl || "") : ""
                                fillMode: "crop"
                                fillColor: Components.ColorPalette.surfaceVariant
                                enableCrossfade: true
                                crossfadeDuration: 600
                                
                                // Darkening overlay
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: 0.5
                                    radius: 16
                                }
                            }
                            
                            // Track title
                            Type.Label {
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        text: cardPlayer ? (cardPlayer.trackTitle || "No media playing") : "No media playing"
                        pixelSize: 14
                        bold: true
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                    }
                    
                    // Play button
                    Rectangle {
                        id: cardPlayButton
                        width: 40
                        height: 40
                        radius: cardPlayer && cardPlayer.isPlaying ? 10 : 20
                        color: playerCard.cardAccentColor
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 16
                        layer.enabled: true
                        layer.smooth: true
                        z: 100
                        
                        Behavior on radius {
                            NumberAnimation { duration: 150; easing.type: Easing.InOutCubic }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: cardPlayer && cardPlayer.isPlaying ? "⏸" : "▶"
                            font.pixelSize: 20
                            color: playerCard.cardOnAccentColor
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (cardPlayer) cardPlayer.togglePlaying()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                    
                    // Progress bar for this card
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: cardPlayButton.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: cardPlayButton.verticalCenter
                        spacing: 4
                        z: 100
                        
                        Type.Label {
                            text: playerCard.isBrowser ? "Progress Not Supported For Browsers" : (function() {
                                if (!cardPlayer) return "0:00 - 0:00"
                                
                                var currentPos = playerCard.isCardDragging ? (cardProgressBar.progress * cardPlayer.length) : playerCard.cardDisplayPosition
                                var totalLen = cardPlayer.length || 0
                                
                                if (totalLen > 0 && currentPos > totalLen) {
                                    return formatTime(totalLen) + " - " + formatTime(totalLen)
                                }
                                
                                return formatTime(currentPos) + " - " + formatTime(totalLen)
                            })()
                            pixelSize: 10
                            color: "#FFFFFF"
                            opacity: 0.8
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                        
                        Progress.InteractiveWavyProgressBar {
                            id: cardProgressBar
                            width: parent.width
                            height: 20
                            progress: cardPlayer ? (playerCard.cardDisplayPosition / cardPlayer.length) : 0
                            amplitude: 8
                            wavelength: 24
                            progressColor: playerCard.cardAccentColor
                            trackColor: Qt.rgba(playerCard.cardAccentColor.r, playerCard.cardAccentColor.g, playerCard.cardAccentColor.b, 0.3)
                            visible: !playerCard.isBrowser
                            onIsDraggingChanged: {
                                playerCard.isCardDragging = isDragging
                            }
                            onSeeked: function(position) {
                                if (!cardPlayer || !cardPlayer.canSeek) return
                                var newPos = position * cardPlayer.length
                                var now = Date.now()
                                cardPlayer.position = newPos
                                playerCard.cardLastKnownPosition = newPos
                                playerCard.cardLastUpdateTime = now
                                playerCard.cardLastSeekTime = now
                                playerCard.cardDisplayPosition = newPos
                            }
                        }
                    }
                    }
                }
            }
        }
        
        // Player indicator dots
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            spacing: 6
            visible: Mpris.players.values.length > 1
            z: 100
            
            Repeater {
                model: Mpris.players.values.length
                
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: "#FFFFFF"
                    opacity: index === Math.round(root.currentPlayerIndex) ? 1.0 : 0.4
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }
            }
        }
        
        // Swipe MouseArea covering top area (only enabled when multiple players)
        MouseArea {
            id: swipeMouseArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 70
            enabled: Mpris.players.values.length > 1
            
            property real startX: 0
            property real startY: 0
            property bool isDragging: false
            
            onPressed: function(mouse) {
                startX = mouse.x
                startY = mouse.y
                isDragging = false
                root.isSwipeAnimating = false
            }
            
            onPositionChanged: function(mouse) {
                var deltaX = Math.abs(mouse.x - startX)
                var deltaY = Math.abs(mouse.y - startY)
                
                if (!isDragging && deltaX > 15 && deltaX > deltaY * 2) {
                    isDragging = true
                }
                
                if (isDragging) {
                    root.swipeOffset = mouse.x - startX
                }
            }
            
            onReleased: function(mouse) {
                if (!isDragging) {
                    return
                }
                
                var shouldSwitch = Math.abs(root.swipeOffset) > 80
                var playerCount = Mpris.players.values.length
                
                isDragging = false
                
                // Change player index - the Behavior will animate it
                if (shouldSwitch && playerCount > 1) {
                    if (mouse.x < startX) {
                        root.currentPlayerIndex = (root.currentPlayerIndex + 1) % playerCount
                    } else {
                        root.currentPlayerIndex = (root.currentPlayerIndex - 1 + playerCount) % playerCount
                    }
                }
                
                // Enable animation and reset swipe offset
                root.isSwipeAnimating = true
                root.swipeOffset = 0
            }
            
            onCanceled: {
                root.isSwipeAnimating = true
                root.swipeOffset = 0
                isDragging = false
            }
        }
    }
    

    

    

    
    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
