import QtQuick 2.15
import Quickshell.Services.Mpris

Item {
    id: root
    
    // Map of player identity -> player state
    property var playerStates: ({})
    
    signal playerStateChanged(var player)
    
    // Get tracked position for a player
    function getPosition(player) {
        if (!player) return 0
        var state = playerStates[player.identity]
        return state ? state.position : 0
    }
    
    // Get if we're currently seeking for a player
    function isSeeking(player) {
        if (!player) return false
        var state = playerStates[player.identity]
        return state ? state.seeking : false
    }
    
    // Set seeking state
    function setSeeking(player, seeking) {
        if (!player) return
        var state = playerStates[player.identity] || createPlayerState(player)
        state.seeking = seeking
        playerStates[player.identity] = state
    }
    
    // Manually set position (when user seeks)
    function setPosition(player, position) {
        if (!player) return
        var state = playerStates[player.identity] || createPlayerState(player)
        state.position = position
        state.lastUpdateTime = Date.now()
        playerStates[player.identity] = state
        playerStateChanged(player)
    }
    
    // Create initial state for a player
    function createPlayerState(player) {
        return {
            position: player.position || 0,
            lastUpdateTime: Date.now(),
            lastTrackTitle: player.trackTitle || "",
            lastTrackId: player.trackId || "",
            seeking: false
        }
    }
    
    // Update position for a player
    function updatePosition(player) {
        if (!player) return
        
        var identity = player.identity || "unknown"
        var state = playerStates[identity]
        if (!state) {
            state = createPlayerState(player)
            playerStates[identity] = state
        }
        
        // Don't update if we're seeking
        if (state.seeking) return
        
        var currentTrackTitle = player.trackTitle || ""
        var currentTrackId = player.trackId || ""
        
        // Check if track changed
        if (currentTrackTitle !== state.lastTrackTitle || currentTrackId !== state.lastTrackId) {
            state.position = 0
            state.lastTrackTitle = currentTrackTitle
            state.lastTrackId = currentTrackId
            state.lastUpdateTime = Date.now()
            state.seeking = false  // Reset seeking state on track change
            
            // Force update by creating new object
            var newStates = {}
            for (var key in playerStates) {
                newStates[key] = playerStates[key]
            }
            newStates[identity] = state
            playerStates = newStates
            
            playerStateChanged(player)
            return
        }
        
        // Update position from player
        var newPosition = player.position || 0
        state.position = newPosition
        state.lastUpdateTime = Date.now()
        
        // Force update by creating new object
        var newStates = {}
        for (var key in playerStates) {
            newStates[key] = playerStates[key]
        }
        newStates[identity] = state
        playerStates = newStates
        
        playerStateChanged(player)
    }
    
    // Timer to update all player positions
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            var players = Mpris.players.values
            for (var i = 0; i < players.length; i++) {
                var player = players[i]
                if (player) {
                    updatePosition(player)
                }
            }
        }
    }
    

}
