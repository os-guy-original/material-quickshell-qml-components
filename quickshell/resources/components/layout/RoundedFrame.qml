import QtQuick 2.15

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
  // Image fill mode: "crop" (aspect fill) or "fit" (aspect fit)
  property string fillMode: "crop"
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
  
  // Crossfade animation support
  property bool enableCrossfade: false
  property int crossfadeDuration: 300
  property string _prevSource: ""
  property string _currentSource: ""
  
  onSourceChanged: {
    if (enableCrossfade && _currentSource && source && source !== _currentSource) {
      _prevSource = _currentSource
      prevCanvas.imageItem.source = _currentSource
      prevLayer.opacity = 1
      currentLayer.opacity = 0
    }
    _currentSource = source ? source.toString() : ""
  }
  
  Component.onCompleted: {
    _currentSource = source ? source.toString() : ""
  }
  
  // Previous image layer (for crossfade out)
  Item {
    id: prevLayer
    anchors.fill: parent
    anchors.margins: root.padding
    visible: root.enableCrossfade && !!root._prevSource
    opacity: 1
    clip: true
    
    Canvas {
      id: prevCanvas
      anchors.fill: parent
      opacity: prevLayer.opacity
      
      property var imageItem: Image {
        source: root._prevSource
        asynchronous: true
        cache: true
        visible: false
        onStatusChanged: {
          if (status === Image.Ready) {
            prevCanvas.loadImage(source)
            prevCanvas.requestPaint()
          }
        }
      }
      
      onPaint: {
        var ctx = getContext("2d")
        ctx.imageSmoothingEnabled = true
        ctx.imageSmoothingQuality = "high"
        ctx.save()
        ctx.clearRect(0, 0, width, height)
        
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
        
        if (isImageLoaded(root._prevSource)) {
          var img = imageItem
          var imgRatio = img.sourceSize.width / img.sourceSize.height
          var frameRatio = width / height
          
          var drawX = 0
          var drawY = 0
          var drawW = width
          var drawH = height
          
          if (root.fillMode === "fit") {
            if (imgRatio > frameRatio) {
              drawH = width / imgRatio
              drawY = (height - drawH) / 2
            } else {
              drawW = height * imgRatio
              drawX = (width - drawW) / 2
            }
          } else {
            if (imgRatio > frameRatio) {
              drawW = height * imgRatio
              drawX = (width - drawW) / 2
            } else {
              drawH = width / imgRatio
              drawY = (height - drawH) / 2
            }
          }
          
          ctx.drawImage(root._prevSource, drawX, drawY, drawW, drawH)
        }
        
        ctx.restore()
      }
    }
    
    Behavior on opacity {
      NumberAnimation { 
        duration: root.crossfadeDuration
        easing.type: Easing.InOutCubic
        onRunningChanged: {
          if (!running && prevLayer.opacity === 0) {
            root._prevSource = ""
          }
        }
      }
    }
  }
  
  // Current image layer
  Item {
    id: currentLayer
    anchors.fill: parent
    anchors.margins: root.padding
    visible: !!root.source
    opacity: 1
    clip: true
    
    // Use layer rendering for better quality
    layer.enabled: true
    layer.smooth: true
    layer.textureSize: Qt.size(width * 2, height * 2)
    
    Canvas {
      id: imgCanvas
      anchors.fill: parent
      opacity: currentLayer.opacity
      antialiasing: true
      renderStrategy: Canvas.Cooperative
      renderTarget: Canvas.FramebufferObject
      
      property var imageItem: Image {
        source: root.source
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
        antialiasing: true
        visible: false
        onStatusChanged: {
          if (status === Image.Ready) {
            try {
              imgCanvas.loadImage(source)
              imgCanvas.requestPaint()
              if (root.enableCrossfade && root._prevSource) {
                fadeInTimer.start()
              } else {
                currentLayer.opacity = 1
              }
            } catch (e) {
              console.warn("RoundedFrame: Error loading image:", source, e)
            }
          } else if (status === Image.Error) {
            console.warn("RoundedFrame: Failed to load image:", source)
          }
        }
      }
      
      Timer {
        id: fadeInTimer
        interval: 50
        onTriggered: {
          currentLayer.opacity = 1
          prevLayer.opacity = 0
        }
      }
      
      onPaint: {
      var ctx = getContext("2d")
      ctx.imageSmoothingEnabled = true
      ctx.imageSmoothingQuality = "high"
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
        var img = imageItem
        var imgRatio = img.sourceSize.width / img.sourceSize.height
        var frameRatio = width / height
        
        var drawX = 0
        var drawY = 0
        var drawW = width
        var drawH = height
        
        if (root.fillMode === "fit") {
          // Aspect fit - show entire image, may have letterboxing
          if (imgRatio > frameRatio) {
            // Image is wider - fit to width
            drawH = width / imgRatio
            drawY = (height - drawH) / 2
          } else {
            // Image is taller - fit to height
            drawW = height * imgRatio
            drawX = (width - drawW) / 2
          }
        } else {
          // Aspect fill (crop) - fill entire frame
          if (imgRatio > frameRatio) {
            // Image is wider - fit to height and crop sides
            drawW = height * imgRatio
            drawX = (width - drawW) / 2
          } else {
            // Image is taller - fit to width and crop top/bottom
            drawH = width / imgRatio
            drawY = (height - drawH) / 2
          }
        }
        
        ctx.drawImage(root.source, drawX, drawY, drawW, drawH)
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
    
    Behavior on opacity {
      NumberAnimation { 
        duration: root.crossfadeDuration
        easing.type: Easing.InOutCubic
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
