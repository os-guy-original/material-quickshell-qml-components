import QtQuick 2.15
import ".." as Components

Item {
    id: root
    property real progress: 0.0
    property bool interactive: true
    property color trackColor: Components.ColorPalette.isDarkMode ? Components.ColorPalette.surfaceVariant : Qt.darker(Components.ColorPalette.surfaceVariant, 1.15)
    property color progressColor: Components.ColorPalette.primary
    property real amplitude: 8
    property real wavelength: 32
    property real strokeWidth: 4
    property string knobShape: "circle"
    property real knobSize: 12
    
    signal seeked(real position)
    
    implicitWidth: 240
    implicitHeight: Math.max(2 * amplitude + knobSize + strokeWidth, knobSize + strokeWidth)
    clip: false
    
    property bool isDragging: false
    property real effectiveAmplitude: isDragging ? 0 : amplitude
    property real internalProgress: progress
    
    Behavior on effectiveAmplitude {
        NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
    }
    
    Behavior on internalProgress {
        enabled: !isDragging
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    onProgressChanged: {
        if (!isDragging) {
            internalProgress = progress
        }
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        visible: root.visible && root.opacity > 0
        
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()
            
            var w = width
            var h = height
            var mid = h / 2
            var pad = (root.knobShape !== 'none') ? root.knobSize / 2 : 0
            var startX = pad
            var endX = w - pad
            var drawW = Math.max(1, endX - startX)
            var amp = Math.max(0, Math.min(root.effectiveAmplitude, (h - (root.knobSize + root.strokeWidth)) / 2))
            
            function yOf(x) { return mid + amp * Math.sin((x / root.wavelength) * Math.PI * 2) }
            
            ctx.lineWidth = strokeWidth
            ctx.lineCap = 'round'
            ctx.lineJoin = 'round'
            
            // Track
            ctx.strokeStyle = trackColor
            ctx.beginPath()
            ctx.moveTo(startX, yOf(startX))
            for (var x = startX + 1; x <= endX; x += 1) {
                ctx.lineTo(x, yOf(x))
            }
            ctx.stroke()
            
            // Progress
            var clamped = Math.max(0, Math.min(1, isNaN(root.internalProgress) ? 0 : root.internalProgress))
            var pw = startX + clamped * drawW
            
            // Draw progress line
            if (pw > startX + 1) {
                ctx.strokeStyle = progressColor
                ctx.beginPath()
                ctx.moveTo(startX, yOf(startX))
                for (var x2 = startX + 1; x2 <= pw; x2 += 1) {
                    ctx.lineTo(x2, yOf(x2))
                }
                ctx.stroke()
            }
            
            // Knob - draw at progress position following the wave
            if (root.knobShape !== 'none') {
                var kx = startX + clamped * drawW  // Position based on progress
                var ky = yOf(kx)  // Follow the wave curve
                var s = knobSize
                ctx.fillStyle = progressColor
                ctx.save()
                ctx.translate(kx, ky)
                if (root.knobShape === 'diamond') {
                    ctx.rotate(Math.PI / 4)
                    ctx.fillRect(-s/2, -s/2, s, s)
                } else {
                    ctx.beginPath()
                    ctx.arc(0, 0, s/2, 0, Math.PI * 2)
                    ctx.fill()
                }
                ctx.restore()
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        
        property real dragProgress: 0.0
        property real pressX: 0
        property bool hasDragged: false
        
        onPressed: function(mouse) {
            pressX = mouse.x
            hasDragged = false
            var pad = (root.knobShape !== 'none') ? root.knobSize / 2 : 0
            var startX = pad
            var endX = width - pad
            var drawW = Math.max(1, endX - startX)
            var targetProgress = Math.max(0, Math.min(1, (mouse.x - startX) / drawW))
            dragProgress = targetProgress
            // Update immediately with animation enabled
            root.internalProgress = targetProgress
        }
        
        onPositionChanged: function(mouse) {
            if (pressed) {
                var pad = (root.knobShape !== 'none') ? root.knobSize / 2 : 0
                var startX = pad
                var endX = width - pad
                var drawW = Math.max(1, endX - startX)
                var newProgress = Math.max(0, Math.min(1, (mouse.x - startX) / drawW))
                dragProgress = newProgress
                
                // Detect if user has dragged more than 3 pixels
                if (!hasDragged && Math.abs(mouse.x - pressX) > 3) {
                    hasDragged = true
                    root.isDragging = true
                }
                
                root.internalProgress = newProgress
            }
        }
        
        onReleased: {
            root.isDragging = false
            if (!hasDragged) {
                root.internalProgress = dragProgress
            }
            root.seeked(dragProgress)
        }
    }
    
    // Throttle canvas repaints to reduce CPU usage
    property bool _paintScheduled: false
    
    function _schedulePaint() {
        if (!_paintScheduled) {
            _paintScheduled = true
            Qt.callLater(function() {
                canvas.requestPaint()
                _paintScheduled = false
            })
        }
    }
    
    onInternalProgressChanged: _schedulePaint()
    onEffectiveAmplitudeChanged: _schedulePaint()
    onTrackColorChanged: _schedulePaint()
    onProgressColorChanged: _schedulePaint()
}
