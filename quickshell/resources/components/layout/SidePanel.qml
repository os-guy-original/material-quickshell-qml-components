import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland as Hypr
import "../" as Components
import "../layout" as Layout
import "../../../shell/services" as Services

// Animated side panel that sticks to screen edges with SideConnector
PanelWindow {
    id: sidePanel
    visible: false
    color: "transparent"
    Hypr.HyprlandWindow.opacity: Services.OpacityService.barOpacity
    
    // Configuration properties
    property string edge: "right"  // "left", "right", "top", "bottom"
    property real panelWidth: 400  // Panel width (0 = auto-calculate based on edge)
    property real panelHeight: 0  // Panel height (0 = auto-calculate based on edge)
    property real cornerRadius: 24
    property real margin: 16
    property Component contentComponent: null
    property color panelColor: Components.ColorPalette.surface
    
    // Animation properties
    property real animationDuration: 300
    property int animationEasing: Easing.OutCubic
    
    // Internal state
    property bool isHorizontal: edge === "left" || edge === "right"
    
    // Backwards compatibility
    property real panelSize: isHorizontal ? panelWidth : panelHeight
    
    // Effective margin
    property real effectiveMargin: margin
    
    // Window dimensions - full screen to allow sliding animation
    implicitWidth: screen.width
    implicitHeight: screen.height
    
    // Anchoring
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-sidepanel"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0
    
    // Public methods
    function show() {
        visible = true
    }
    
    function hide() {
        visible = false
    }
    
    function toggle() {
        console.log("SidePanel.toggle() called, current visible:", visible, "-> new visible:", !visible)
        visible = !visible
    }
    
    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: sidePanel.hide()
        
        Rectangle {
            id: panelContent
            
            // Position based on edge - stick to edge with effectiveMargin
            x: {
                if (edge === "left") return effectiveMargin
                if (edge === "right") return parent.width - width - effectiveMargin
                if (edge === "top" || edge === "bottom") return (parent.width - width) / 2
                return effectiveMargin
            }
            y: {
                if (edge === "top") return 0
                if (edge === "bottom") return parent.height - height
                if (edge === "left" || edge === "right") return 0
                return 0
            }
            
            // Size - support both width and height for all edges
            width: {
                if (panelWidth > 0) return panelWidth
                // Auto-calculate width if not specified
                if (edge === "left" || edge === "right") return 400  // Default for side panels
                if (edge === "top" || edge === "bottom") return parent.width - effectiveMargin * 2  // Full width for top/bottom
                return 400
            }
            height: {
                if (panelHeight > 0) return panelHeight
                // Auto-calculate height if not specified
                if (edge === "top" || edge === "bottom") return 300  // Default for top/bottom panels
                if (edge === "left" || edge === "right") return parent.height - effectiveMargin * 2  // Full height for side panels
                return 300
            } 
            
            color: "transparent"  // Make transparent - Canvas will draw the colored shape
            radius: 0
            antialiasing: true
            
            // Canvas for selective corner rounding
            Canvas {
                id: roundedCanvas
                anchors.fill: parent
                visible: true  // Always visible to draw the panel
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.fillStyle = panelColor
                    ctx.beginPath()
                    
                    var w = width
                    var h = height
                    var r = cornerRadius
                    
                    if (edge === "left") {
                        // Round right corners only
                        ctx.moveTo(0, 0)
                        ctx.lineTo(w - r, 0)
                        ctx.arcTo(w, 0, w, r, r)
                        ctx.lineTo(w, h - r)
                        ctx.arcTo(w, h, w - r, h, r)
                        ctx.lineTo(0, h)
                    } else if (edge === "right") {
                        // Round left corners only
                        ctx.moveTo(w, 0)
                        ctx.lineTo(r, 0)
                        ctx.arcTo(0, 0, 0, r, r)
                        ctx.lineTo(0, h - r)
                        ctx.arcTo(0, h, r, h, r)
                        ctx.lineTo(w, h)
                    } else if (edge === "top") {
                        // Round bottom corners only
                        ctx.moveTo(0, 0)
                        ctx.lineTo(w, 0)
                        ctx.lineTo(w, h - r)
                        ctx.arcTo(w, h, w - r, h, r)
                        ctx.lineTo(r, h)
                        ctx.arcTo(0, h, 0, h - r, r)
                    } else if (edge === "bottom") {
                        // Round top corners only
                        ctx.moveTo(0, h)
                        ctx.lineTo(0, r)
                        ctx.arcTo(0, 0, r, 0, r)
                        ctx.lineTo(w - r, 0)
                        ctx.arcTo(w, 0, w, r, r)
                        ctx.lineTo(w, h)
                    }
                    
                    ctx.closePath()
                    ctx.fill()
                }
                
                property bool _repaintScheduled: false
                
                function scheduleRepaint() {
                    if (!_repaintScheduled) {
                        _repaintScheduled = true
                        Qt.callLater(function() {
                            requestPaint()
                            _repaintScheduled = false
                        })
                    }
                }
                
                Connections {
                    target: sidePanel
                    function onCornerRadiusChanged() { roundedCanvas.scheduleRepaint() }
                    function onPanelColorChanged() { roundedCanvas.scheduleRepaint() }
                    function onEdgeChanged() { roundedCanvas.scheduleRepaint() }
                    function onPanelWidthChanged() { roundedCanvas.scheduleRepaint() }
                    function onPanelHeightChanged() { roundedCanvas.scheduleRepaint() }
                }
                
                Component.onCompleted: requestPaint()
            }
            
            // Slide animation
            transform: Translate {
                id: slideTransform
                x: {
                    if (!isHorizontal) return 0
                    if (edge === "left") return sidePanel.visible ? 0 : -panelSize
                    if (edge === "right") return sidePanel.visible ? 0 : panelSize
                    return 0
                }
                y: {
                    if (isHorizontal) return 0
                    if (edge === "top") return sidePanel.visible ? 0 : -panelSize
                    if (edge === "bottom") return sidePanel.visible ? 0 : panelSize
                    return 0
                }
                
                Behavior on x {
                    NumberAnimation {
                        duration: animationDuration
                        easing.type: animationEasing
                    }
                }
                
                Behavior on y {
                    NumberAnimation {
                        duration: animationDuration
                        easing.type: animationEasing
                    }
                }
            }
            
            // Prevent clicks inside from closing
            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) { mouse.accepted = true }
            }
            
            // Content loader
            Loader {
                id: contentLoader
                anchors.fill: parent
                anchors.margins: 12
                sourceComponent: sidePanel.contentComponent
                clip: true
            }
            
            // SideConnectors for rounded corners on free edges
            // Left edge panel (opens horizontally) - connectors on LEFT side (free edge)
            Layout.SideConnector {
                visible: edge === "left"
                radius: cornerRadius
                position: "horizontal-above-left"
                fillColor: panelColor
            }
            
            Layout.SideConnector {
                visible: edge === "left"
                radius: cornerRadius
                position: "horizontal-below-left"
                fillColor: panelColor
            }
            
            // Right edge panel (opens horizontally) - connectors on RIGHT side (free edge)
            Layout.SideConnector {
                visible: edge === "right"
                radius: cornerRadius
                position: "horizontal-above-right"
                fillColor: panelColor
            }
            
            Layout.SideConnector {
                visible: edge === "right"
                radius: cornerRadius
                position: "horizontal-below-right"
                fillColor: panelColor
            }
            
            // Top edge panel (opens vertically from top) - connectors on sides
            Layout.SideConnector {
                visible: edge === "top"
                radius: cornerRadius
                position: "vertical-top-left"
                fillColor: panelColor
            }
            
            Layout.SideConnector {
                visible: edge === "top"
                radius: cornerRadius
                position: "vertical-top-right"
                fillColor: panelColor
            }
            
            // Bottom edge panel (opens vertically from bottom) - connectors on sides
            Layout.SideConnector {
                visible: edge === "bottom"
                radius: cornerRadius
                position: "vertical-bottom-left"
                fillColor: panelColor
            }
            
            Layout.SideConnector {
                visible: edge === "bottom"
                radius: cornerRadius
                position: "vertical-bottom-right"
                fillColor: panelColor
            }
        }
    }
}
