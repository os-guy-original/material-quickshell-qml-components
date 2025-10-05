import QtQuick 2.15
import "../../colors.js" as Palette

/*
  RoundedFrame
  - Masks its contents (images, colors, arbitrary children) into a rounded/circular frame.
  - Usage options:
    - Set `source` to show a remote/local image (cropped with aspect fill).
    - Set `fillColor` to show a solid color clipped to the frame.
    - Or place arbitrary children inside; they will be clipped by the mask.
  - Corner size:
    - `cornerRadius`: default Material-style radius.
    - `circular: true` to make it a perfect circle (radius = min(width,height)/2).
*/
Item {
  id: root
  width: 96
  height: 96

  // Material You default radius (tunable). Common defaults: 12 or 16.
  // Pick 12 as a balanced default; callers can override.
  property real cornerRadius: 12
  // If true, force a perfect circle regardless of cornerRadius
  property bool circular: false
  // Optional image to display inside the frame (cropped)
  property url source: ""
  // Optional fill color if you want a solid framed color background
  property color fillColor: "transparent"
  // Expose a way to set an overlay/border if desired later
  property color borderColor: "transparent"
  property real borderWidth: 0
  // Optional inner padding for children/content
  property real padding: 0
  // Apply stricter clipping adjustments (pixel-aligned radius, larger inset, no smoothing)
  property bool hardClip: true

  // Effective radius used by mask
  property real _effectiveRadius: circular ? Math.min(width, height) / 2 : cornerRadius

  // Default content slot (children placed in this component)
  default property alias contentData: slot.data
  
  // Background fill
  Rectangle {
    anchors.fill: parent
    anchors.margins: root.padding
    radius: root._effectiveRadius
    color: (root.fillColor && root.fillColor !== "transparent") ? root.fillColor : "transparent"
    visible: color !== "transparent"
    antialiasing: true
  }
  
  // Image with Canvas-based clipping mask
  Canvas {
    id: imgCanvas
    anchors.fill: parent
    anchors.margins: root.padding
    visible: !!root.source
    
    property var imageItem: Image {
      source: root.source
      asynchronous: true
      cache: true
      visible: false
      onStatusChanged: {
        if (status === Image.Ready) {
          imgCanvas.loadImage(source)
          imgCanvas.requestPaint()
        }
      }
    }
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.save()
      ctx.clearRect(0, 0, width, height)
      
      // Create clipping path
      var rad = root._effectiveRadius
      if (root.circular) {
        var r = Math.min(width, height) / 2
        ctx.beginPath()
        ctx.arc(width / 2, height / 2, r, 0, Math.PI * 2)
      } else {
        ctx.beginPath()
        ctx.moveTo(rad, 0)
        ctx.lineTo(width - rad, 0)
        ctx.arcTo(width, 0, width, rad, rad)
        ctx.lineTo(width, height - rad)
        ctx.arcTo(width, height, width - rad, height, rad)
        ctx.lineTo(rad, height)
        ctx.arcTo(0, height, 0, height - rad, rad)
        ctx.lineTo(0, rad)
        ctx.arcTo(0, 0, rad, 0, rad)
        ctx.closePath()
      }
      ctx.clip()
      
      // Draw the image if loaded
      if (isImageLoaded(root.source)) {
        // Calculate aspect-fill positioning
        var imgW = width
        var imgH = height
        ctx.drawImage(root.source, 0, 0, imgW, imgH)
      }
      
      ctx.restore()
    }
    
    onImageLoaded: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Connections {
      target: root
      function on_EffectiveRadiusChanged() { imgCanvas.requestPaint() }
      function onCircularChanged() { imgCanvas.requestPaint() }
      function onSourceChanged() {
        if (root.source) {
          imgCanvas.loadImage(root.source)
          imgCanvas.requestPaint()
        }
      }
    }
  }

  // Default content slot for arbitrary children
  Item {
    id: slot
    anchors.fill: parent
    anchors.margins: root.padding
  }

  // Optional border drawn on top (crisp edge)
  Rectangle {
    anchors.fill: parent
    color: "transparent"
    border.color: root.borderColor
    border.width: root.borderWidth
    radius: root._effectiveRadius
    visible: root.borderWidth > 0 && root.borderColor !== "transparent"
    antialiasing: true
  }
}
