import QtQuick 2.15
import "../../components" as Components

/**
 * CornerSticker - Creates decorative corner pieces that make components look "stuck" to edges
 * 
 * This component automatically inherits color and animations from its target,
 * creating seamless corner fills when a component is anchored to screen edges.
 * 
 * Usage:
 *   Rectangle {
 *       id: myPanel
 *       anchors.left: parent.left
 *       color: "blue"
 *       radius: 16
 *       
 *       CornerSticker {
 *           target: myPanel
 *           corners: CornerSticker.TopLeft | CornerSticker.BottomLeft
 *       }
 *   }
 */
Item {
    id: root
    
    // Enums for corner positions
    enum Corner {
        None = 0,
        TopLeft = 1,
        TopRight = 2,
        BottomLeft = 4,
        BottomRight = 8,
        Top = 3,        // TopLeft | TopRight
        Bottom = 12,    // BottomLeft | BottomRight
        Left = 5,       // TopLeft | BottomLeft
        Right = 10,     // TopRight | BottomRight
        All = 15        // All corners
    }
    
    // Required: target component to stick to
    property Item target: parent
    
    // Which corners to show (use Corner enum flags)
    property int corners: CornerSticker.Corner.All
    
    // Auto-detect or manually set (Canvas doesn't have color property, so must be set explicitly)
    property color stickerColor: Components.ColorPalette.surface
    property real cornerRadius: target && target.radius !== undefined ? target.radius : 16
    property real stickerSize: cornerRadius // Size of the corner piece
    
    // Offset from target edges (usually 0)
    property real offsetX: 0
    property real offsetY: 0
    
    // Auto-inherit animations from target
    property bool inheritAnimations: true
    
    anchors.fill: target
    z: target ? target.z - 1 : -1 // Render behind target
    
    // Top-left corner
    Canvas {
        id: topLeftCorner
        visible: corners & 1 // CornerSticker.Corner.TopLeft
        width: stickerSize
        height: stickerSize
        x: -stickerSize + offsetX
        y: -stickerSize + offsetY
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = stickerColor
            ctx.beginPath()
            ctx.moveTo(0, stickerSize)
            ctx.lineTo(0, 0)
            ctx.lineTo(stickerSize, 0)
            ctx.arcTo(stickerSize, stickerSize, 0, stickerSize, cornerRadius)
            ctx.closePath()
            ctx.fill()
        }
        
        Connections {
            target: root
            function onStickerColorChanged() { topLeftCorner.requestPaint() }
            function onCornerRadiusChanged() { topLeftCorner.requestPaint() }
        }
        
        Component.onCompleted: requestPaint()
        
        Behavior on opacity {
            enabled: inheritAnimations && target && target.Behavior
            NumberAnimation { duration: 200 }
        }
    }
    
    // Top-right corner
    Canvas {
        id: topRightCorner
        visible: corners & 2 // CornerSticker.Corner.TopRight
        width: stickerSize
        height: stickerSize
        x: root.width - offsetX
        y: -stickerSize + offsetY
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = stickerColor
            ctx.beginPath()
            ctx.moveTo(stickerSize, stickerSize)
            ctx.lineTo(stickerSize, 0)
            ctx.lineTo(0, 0)
            ctx.arcTo(0, stickerSize, stickerSize, stickerSize, cornerRadius)
            ctx.closePath()
            ctx.fill()
        }
        
        Connections {
            target: root
            function onStickerColorChanged() { topRightCorner.requestPaint() }
            function onCornerRadiusChanged() { topRightCorner.requestPaint() }
        }
        
        Component.onCompleted: requestPaint()
        
        Behavior on opacity {
            enabled: inheritAnimations && target && target.Behavior
            NumberAnimation { duration: 200 }
        }
    }
    
    // Bottom-left corner
    Canvas {
        id: bottomLeftCorner
        visible: corners & 4 // CornerSticker.Corner.BottomLeft
        width: stickerSize
        height: stickerSize
        x: -stickerSize + offsetX
        y: root.height - offsetY
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = stickerColor
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, stickerSize)
            ctx.lineTo(stickerSize, stickerSize)
            ctx.arcTo(stickerSize, 0, 0, 0, cornerRadius)
            ctx.closePath()
            ctx.fill()
        }
        
        Connections {
            target: root
            function onStickerColorChanged() { bottomLeftCorner.requestPaint() }
            function onCornerRadiusChanged() { bottomLeftCorner.requestPaint() }
        }
        
        Component.onCompleted: requestPaint()
        
        Behavior on opacity {
            enabled: inheritAnimations && target && target.Behavior
            NumberAnimation { duration: 200 }
        }
    }
    
    // Bottom-right corner
    Canvas {
        id: bottomRightCorner
        visible: corners & 8 // CornerSticker.Corner.BottomRight
        width: stickerSize
        height: stickerSize
        x: root.width - offsetX
        y: root.height - offsetY
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = stickerColor
            ctx.beginPath()
            ctx.moveTo(stickerSize, 0)
            ctx.lineTo(stickerSize, stickerSize)
            ctx.lineTo(0, stickerSize)
            ctx.arcTo(0, 0, stickerSize, 0, cornerRadius)
            ctx.closePath()
            ctx.fill()
        }
        
        Connections {
            target: root
            function onStickerColorChanged() { bottomRightCorner.requestPaint() }
            function onCornerRadiusChanged() { bottomRightCorner.requestPaint() }
        }
        
        Component.onCompleted: requestPaint()
        
        Behavior on opacity {
            enabled: inheritAnimations && target && target.Behavior
            NumberAnimation { duration: 200 }
        }
    }
}
