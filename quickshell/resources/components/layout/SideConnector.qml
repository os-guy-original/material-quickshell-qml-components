import QtQuick 2.15
import "../" as Components

// Reusable side connector component
// Creates a square with an arc cut out to smooth transitions between surfaces
// Automatically positions itself based on the position property
//
// POSITION NAMING: {opening-direction}-{connector-position}
// - Horizontal opening (left/right panels): connectors go above/below
//   Format: "horizontal-above-left", "horizontal-above-right", "horizontal-below-left", "horizontal-below-right"
// - Vertical opening (top/bottom panels): connectors go on sides, named by panel edge
//   Format: "vertical-top-left", "vertical-top-right", "vertical-bottom-left", "vertical-bottom-right"
//
// EXAMPLES:
// - Right panel (opens horizontally): "horizontal-above-left" and "horizontal-below-left"
// - Left panel (opens horizontally): "horizontal-above-right" and "horizontal-below-right"
// - Top panel (opens vertically from top): "vertical-top-left" and "vertical-top-right"
// - Bottom panel (opens vertically from bottom): "vertical-bottom-left" and "vertical-bottom-right"
Item {
    id: root
    
    // Public properties
    property int radius: 16
    property string position: "horizontal-above-left"
    property color fillColor: parent && parent.color ? parent.color : Components.ColorPalette.surface
    
    // Auto-position based on position property
    x: {
        // Horizontal opening: connectors on left/right side
        if (position.startsWith("horizontal-")) {
            return position.endsWith("-left") ? 0 : parent.width - radius
        }
        // Vertical opening: connectors stick out from panel edge
        if (position.startsWith("vertical-")) {
            return position.endsWith("-left") ? -radius : parent.width
        }
        return 0
    }
    
    y: {
        // Horizontal opening: connectors stick out above/below
        if (position.startsWith("horizontal-")) {
            return position.includes("-above-") ? -radius : parent.height
        }
        // Vertical opening: connectors on top/bottom of panel
        if (position.startsWith("vertical-")) {
            return position.includes("-top-") ? 0 : parent.height - radius
        }
        return 0
    }
    
    width: radius
    height: radius

Canvas {
    id: canvas
    anchors.fill: parent
    
    onPaint: {
        drawConnector()
    }
    
    Connections {
        target: root
        function onRadiusChanged() { canvas.requestPaint() }
        function onPositionChanged() { canvas.requestPaint() }
        function onFillColorChanged() { canvas.requestPaint() }
    }
    
    function drawConnector() {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = fillColor
        ctx.beginPath()
        
        // HORIZONTAL OPENING (left/right panels - connectors above/below)
        // Right panel: above-left and below-left
        if (position === "horizontal-above-left") {
            // Above right panel, left side - arc cuts TOP-right (radius, 0)
            ctx.moveTo(0, radius)
            ctx.lineTo(0, 0)
            ctx.lineTo(radius, 0)
            ctx.arc(radius, 0, radius, Math.PI, Math.PI * 0.5, true)
        } else if (position === "horizontal-below-left") {
            // Below right panel, left side - arc cuts BOTTOM-right (radius, radius)
            ctx.moveTo(0, 0)
            ctx.lineTo(0, radius)
            ctx.lineTo(radius, radius)
            ctx.arc(radius, radius, radius, Math.PI, Math.PI * 1.5, false)
        }
        // Left panel: above-right and below-right
        else if (position === "horizontal-above-right") {
            // Above left panel, right side - arc cuts TOP-left (0, 0)
            ctx.moveTo(radius, radius)
            ctx.lineTo(radius, 0)
            ctx.lineTo(0, 0)
            ctx.arc(0, 0, radius, 0, Math.PI / 2, false)
        } else if (position === "horizontal-below-right") {
            // Below left panel, right side - arc cuts BOTTOM-left (0, radius)
            ctx.moveTo(radius, 0)
            ctx.lineTo(radius, radius)
            ctx.lineTo(0, radius)
            ctx.arc(0, radius, radius, 0, -Math.PI / 2, true)
        }
        // VERTICAL OPENING (top/bottom panels - connectors on sides)
        // Top panel: left and right connectors
        else if (position === "vertical-top-left") {
            // Top panel, left side - arc cuts BOTTOM-left (0, radius)
            ctx.moveTo(radius, 0)
            ctx.lineTo(radius, radius)
            ctx.lineTo(0, radius)
            ctx.arc(0, radius, radius, 0, -Math.PI / 2, true)
        } else if (position === "vertical-top-right") {
            // Top panel, right side - arc cuts BOTTOM-right (radius, radius)
            ctx.moveTo(0, 0)
            ctx.lineTo(0, radius)
            ctx.lineTo(radius, radius)
            ctx.arc(radius, radius, radius, Math.PI, Math.PI * 1.5, false)
        }
        // Bottom panel: left and right connectors
        else if (position === "vertical-bottom-left") {
            // Bottom panel, left side - arc cuts TOP-left (0, 0)
            ctx.moveTo(radius, radius)
            ctx.lineTo(radius, 0)
            ctx.lineTo(0, 0)
            ctx.arc(0, 0, radius, 0, Math.PI * 0.5, false)
        } else if (position === "vertical-bottom-right") {
            // Bottom panel, right side - arc cuts TOP-right (radius, 0)
            ctx.moveTo(0, radius)
            ctx.lineTo(0, 0)
            ctx.lineTo(radius, 0)
            ctx.arc(radius, 0, radius, Math.PI, Math.PI * 0.5, true)
        }
        
        ctx.closePath()
        ctx.fill()
    }
    
    Component.onCompleted: requestPaint()
    }
}
