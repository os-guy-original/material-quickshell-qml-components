import QtQuick 2.15
import QtQuick.Shapes 1.15
import ".." as Components

/**
 * Material Design 3 Expressive Loading Indicator
 * 
 * Shapes: Circle → Oval → SoftBurst → Pentagon → Dodecagon → Squircle
 * All shapes have smooth rounded corners.
 */
Item {
    id: root
    
    property real size: 48
    property color color: Components.ColorPalette.primary
    property bool running: true
    property bool filled: true
    
    property int morphDuration: 600
    property int rotationDuration: 3000
    property bool cycleColors: false
    
    // Fixed color sequence - using explicit colors to avoid dark color issues
    property var colorSequence: [
        "#6750A4",  // Primary purple
        "#7D5260",  // Tertiary
        "#625B71"   // Secondary
    ]
    
    implicitWidth: size
    implicitHeight: size
    
    QtObject {
        id: engine
        
        property real morphProgress: 0.0
        property int currentShape: 0
        property int targetShape: 1
        
        readonly property int vertexCount: 72
        readonly property int shapeCount: 6
        
        property var shapes: []
        
        Component.onCompleted: {
            shapes = [
                generateCircle(),
                generateOval(),
                generateSoftBurst(),
                generateRoundedPolygon(5, 0.40, 0.06),   // Pentagon
                generateRoundedPolygon(12, 0.42, 0.03), // Dodecagon (12-gon)
                generateSquircle()
            ]
        }
        
        // Perfect circle
        function generateCircle() {
            var verts = []
            var r = 0.42
            for (var i = 0; i < vertexCount; i++) {
                var angle = (i / vertexCount) * Math.PI * 2 - Math.PI / 2
                verts.push({
                    x: Math.cos(angle) * r,
                    y: Math.sin(angle) * r
                })
            }
            return verts
        }
        
        // Oval / Ellipse
        function generateOval() {
            var verts = []
            var rx = 0.44
            var ry = 0.28
            for (var i = 0; i < vertexCount; i++) {
                var angle = (i / vertexCount) * Math.PI * 2 - Math.PI / 2
                verts.push({
                    x: Math.cos(angle) * rx,
                    y: Math.sin(angle) * ry
                })
            }
            return verts
        }
        
        // Soft Burst - 8-pointed star with rounded tips
        function generateSoftBurst() {
            var verts = []
            var points = 8
            var outerR = 0.42
            var innerR = 0.28
            
            for (var i = 0; i < vertexCount; i++) {
                var t = i / vertexCount
                var angle = t * Math.PI * 2 - Math.PI / 2
                
                // Create smooth wave between inner and outer radius
                var wave = Math.cos(t * Math.PI * 2 * points)
                // Smooth the wave peaks using power function
                var smoothWave = Math.sign(wave) * Math.pow(Math.abs(wave), 0.6)
                
                var r = innerR + (outerR - innerR) * (smoothWave + 1) / 2
                
                verts.push({
                    x: Math.cos(angle) * r,
                    y: Math.sin(angle) * r
                })
            }
            return verts
        }
        
        // Generic rounded polygon - sharp corners smoothed with arcs
        function generateRoundedPolygon(sides, radius, cornerRadius) {
            var verts = []
            
            // Calculate corner positions
            var corners = []
            for (var i = 0; i < sides; i++) {
                var angle = (i / sides) * Math.PI * 2 - Math.PI / 2
                corners.push({
                    x: Math.cos(angle) * radius,
                    y: Math.sin(angle) * radius,
                    angle: angle
                })
            }
            
            var vertsPerSide = Math.floor(vertexCount / sides)
            
            for (var i = 0; i < sides; i++) {
                var curr = corners[i]
                var next = corners[(i + 1) % sides]
                
                // Direction from current to next corner
                var dx = next.x - curr.x
                var dy = next.y - curr.y
                var edgeLen = Math.sqrt(dx * dx + dy * dy)
                var dirX = dx / edgeLen
                var dirY = dy / edgeLen
                
                // Points where the rounded corner starts/ends
                var cornerCutoff = Math.min(cornerRadius, edgeLen * 0.4)
                
                // Start point (after previous corner's arc)
                var startX = curr.x + dirX * cornerCutoff
                var startY = curr.y + dirY * cornerCutoff
                
                // End point (before next corner's arc)
                var endX = next.x - dirX * cornerCutoff
                var endY = next.y - dirY * cornerCutoff
                
                for (var j = 0; j < vertsPerSide; j++) {
                    var t = j / vertsPerSide
                    
                    // Three phases: corner arc, straight edge, corner arc
                    var cornerPhase = 0.2  // 20% for each corner arc
                    
                    var px, py
                    
                    if (t < cornerPhase) {
                        // Arc around current corner
                        var arcT = t / cornerPhase
                        var prevCorner = corners[(i - 1 + sides) % sides]
                        var prevDx = curr.x - prevCorner.x
                        var prevDy = curr.y - prevCorner.y
                        var prevLen = Math.sqrt(prevDx * prevDx + prevDy * prevDy)
                        var prevDirX = prevDx / prevLen
                        var prevDirY = prevDy / prevLen
                        
                        var arcStartX = curr.x - prevDirX * cornerCutoff
                        var arcStartY = curr.y - prevDirY * cornerCutoff
                        
                        // Smooth arc using cosine interpolation
                        var smoothT = (1 - Math.cos(arcT * Math.PI)) / 2
                        px = arcStartX + (startX - arcStartX) * smoothT
                        py = arcStartY + (startY - arcStartY) * smoothT
                        
                        // Push slightly outward for rounder feel
                        var toCenterX = -curr.x
                        var toCenterY = -curr.y
                        var toCenterLen = Math.sqrt(toCenterX * toCenterX + toCenterY * toCenterY)
                        if (toCenterLen > 0.001) {
                            var pushOut = cornerRadius * 0.3 * Math.sin(arcT * Math.PI)
                            px -= (toCenterX / toCenterLen) * pushOut
                            py -= (toCenterY / toCenterLen) * pushOut
                        }
                        
                    } else if (t > 1 - cornerPhase) {
                        // Arc approaching next corner
                        var arcT = (t - (1 - cornerPhase)) / cornerPhase
                        var nextNext = corners[(i + 2) % sides]
                        var nextDx = nextNext.x - next.x
                        var nextDy = nextNext.y - next.y
                        var nextLen = Math.sqrt(nextDx * nextDx + nextDy * nextDy)
                        var nextDirX = nextDx / nextLen
                        var nextDirY = nextDy / nextLen
                        
                        var arcEndX = next.x + nextDirX * cornerCutoff
                        var arcEndY = next.y + nextDirY * cornerCutoff
                        
                        var smoothT = (1 - Math.cos(arcT * Math.PI)) / 2
                        px = endX + (arcEndX - endX) * smoothT
                        py = endY + (arcEndY - endY) * smoothT
                        
                        // Push slightly outward
                        var toCenterX = -next.x
                        var toCenterY = -next.y
                        var toCenterLen = Math.sqrt(toCenterX * toCenterX + toCenterY * toCenterY)
                        if (toCenterLen > 0.001) {
                            var pushOut = cornerRadius * 0.3 * Math.sin(arcT * Math.PI)
                            px -= (toCenterX / toCenterLen) * pushOut
                            py -= (toCenterY / toCenterLen) * pushOut
                        }
                        
                    } else {
                        // Straight edge
                        var edgeT = (t - cornerPhase) / (1 - 2 * cornerPhase)
                        px = startX + (endX - startX) * edgeT
                        py = startY + (endY - startY) * edgeT
                    }
                    
                    verts.push({ x: px, y: py })
                }
            }
            
            while (verts.length < vertexCount) verts.push(verts[verts.length - 1])
            return verts.slice(0, vertexCount)
        }
        
        // Squircle (superellipse)
        function generateSquircle() {
            var verts = []
            var r = 0.38
            var n = 4
            
            for (var i = 0; i < vertexCount; i++) {
                var angle = (i / vertexCount) * Math.PI * 2 - Math.PI / 2
                var c = Math.cos(angle)
                var s = Math.sin(angle)
                
                var signX = c >= 0 ? 1 : -1
                var signY = s >= 0 ? 1 : -1
                
                var x = signX * Math.pow(Math.abs(c), 2 / n) * r
                var y = signY * Math.pow(Math.abs(s), 2 / n) * r
                
                verts.push({ x: x, y: y })
            }
            return verts
        }
        
        function lerp(a, b, t) {
            return a + (b - a) * t
        }
        
        function getInterpolatedVertices() {
            if (shapes.length === 0) return generateCircle()
            
            var from = shapes[currentShape]
            var to = shapes[targetShape]
            var result = []
            
            for (var i = 0; i < vertexCount; i++) {
                result.push({
                    x: lerp(from[i].x, to[i].x, morphProgress),
                    y: lerp(from[i].y, to[i].y, morphProgress)
                })
            }
            return result
        }
        
        function advanceShape() {
            currentShape = targetShape
            targetShape = (targetShape + 1) % shapeCount
        }
    }
    
    // Color animation state
    QtObject {
        id: colorState
        property int currentIdx: 0
        property int targetIdx: 1
        property real colorProgress: 0.0
        
        function getCurrentColor() {
            if (!root.cycleColors) return root.color
            
            var colors = root.colorSequence
            if (colors.length === 0) return root.color
            
            var from = colors[currentIdx % colors.length]
            var to = colors[targetIdx % colors.length]
            
            // Interpolate RGB
            var fromColor = Qt.darker(from, 1.0)  // Just to get a color object
            var toColor = Qt.darker(to, 1.0)
            
            return Qt.rgba(
                fromColor.r + (toColor.r - fromColor.r) * colorProgress,
                fromColor.g + (toColor.g - fromColor.g) * colorProgress,
                fromColor.b + (toColor.b - fromColor.b) * colorProgress,
                1.0
            )
        }
        
        function advance() {
            currentIdx = targetIdx
            targetIdx = (targetIdx + 1) % root.colorSequence.length
        }
    }
    
    // Rendering
    Item {
        id: rotator
        anchors.centerIn: parent
        width: root.size
        height: root.size
        
        RotationAnimator on rotation {
            running: root.running
            from: 0
            to: 360
            duration: root.rotationDuration
            loops: Animation.Infinite
        }
        
        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true
            
            property var vertices: engine.getInterpolatedVertices()
            property color activeColor: root.cycleColors ? colorState.getCurrentColor() : root.color
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                
                var cx = width / 2
                var cy = height / 2
                var scale = Math.min(width, height)
                
                if (!vertices || vertices.length < 3) return
                
                ctx.save()
                ctx.translate(cx, cy)
                
                ctx.beginPath()
                
                var last = vertices[vertices.length - 1]
                var first = vertices[0]
                ctx.moveTo((last.x + first.x) / 2 * scale, (last.y + first.y) / 2 * scale)
                
                for (var i = 0; i < vertices.length; i++) {
                    var curr = vertices[i]
                    var next = vertices[(i + 1) % vertices.length]
                    
                    ctx.quadraticCurveTo(
                        curr.x * scale,
                        curr.y * scale,
                        (curr.x + next.x) / 2 * scale,
                        (curr.y + next.y) / 2 * scale
                    )
                }
                
                ctx.closePath()
                
                if (root.filled) {
                    ctx.fillStyle = activeColor
                    ctx.fill()
                } else {
                    ctx.strokeStyle = activeColor
                    ctx.lineWidth = 3
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.stroke()
                }
                
                ctx.restore()
            }
            
            Connections {
                target: engine
                function onMorphProgressChanged() {
                    canvas.vertices = engine.getInterpolatedVertices()
                    canvas.requestPaint()
                }
            }
            
            Connections {
                target: colorState
                function onColorProgressChanged() {
                    if (root.cycleColors) {
                        canvas.activeColor = colorState.getCurrentColor()
                        canvas.requestPaint()
                    }
                }
            }
        }
    }
    
    // Shape morph animation
    SequentialAnimation {
        id: morphAnim
        running: root.running
        loops: Animation.Infinite
        
        NumberAnimation {
            target: engine
            property: "morphProgress"
            from: 0.0
            to: 1.0
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.3
        }
        
        PauseAnimation { duration: 80 }
        
        ScriptAction {
            script: {
                engine.advanceShape()
                engine.morphProgress = 0.0
            }
        }
    }
    
    // Smooth color transition animation
    SequentialAnimation {
        running: root.running && root.cycleColors
        loops: Animation.Infinite
        
        NumberAnimation {
            target: colorState
            property: "colorProgress"
            from: 0.0
            to: 1.0
            duration: root.morphDuration * 2
            easing.type: Easing.InOutQuad
        }
        
        ScriptAction {
            script: {
                colorState.advance()
                colorState.colorProgress = 0.0
            }
        }
    }
    
    // Subtle breathing scale
    SequentialAnimation {
        running: root.running
        loops: Animation.Infinite
        
        NumberAnimation {
            target: rotator
            property: "scale"
            from: 1.0
            to: 1.06
            duration: root.morphDuration * 0.55
            easing.type: Easing.OutQuad
        }
        
        NumberAnimation {
            target: rotator
            property: "scale"
            from: 1.06
            to: 1.0
            duration: root.morphDuration * 0.45
            easing.type: Easing.InOutQuad
        }
    }
    
    Component.onCompleted: {
        canvas.vertices = engine.getInterpolatedVertices()
        canvas.requestPaint()
    }
    
    onColorChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    onFilledChanged: canvas.requestPaint()
}
