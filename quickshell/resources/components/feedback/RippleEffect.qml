import QtQuick 2.15
import ".." as Components

Item {
    id: root
    anchors.fill: parent
    
    property color rippleColor: Components.ColorPalette.onPrimary
    property int rippleDuration: 600
    property var activeRipple: null
    
    function trigger(x, y) {
        var ripple = rippleComponent.createObject(root, {
            "centerX": x,
            "centerY": y,
            "isHold": false
        })
    }
    
    function startHold(x, y) {
        if (activeRipple) activeRipple.destroy()
        activeRipple = rippleComponent.createObject(root, {
            "centerX": x,
            "centerY": y,
            "isHold": true
        })
    }
    
    function endHold() {
        if (activeRipple) {
            activeRipple.fadeOut()
            activeRipple = null
        }
    }
    
    Component {
        id: rippleComponent
        
        Rectangle {
            id: ripple
            property real centerX: 0
            property real centerY: 0
            property bool isHold: false
            
            width: Math.max(root.width, root.height) * 2.5
            height: width
            radius: width / 2
            x: centerX - width / 2
            y: centerY - height / 2
            color: root.rippleColor
            scale: 0
            opacity: 0
            
            function fadeOut() {
                fadeAnimation.start()
            }
            
            NumberAnimation {
                id: fadeAnimation
                target: ripple
                property: "opacity"
                to: 0
                duration: 200
                onFinished: ripple.destroy()
            }
            
            ParallelAnimation {
                running: true
                
                NumberAnimation {
                    target: ripple
                    property: "scale"
                    from: 0
                    to: 1
                    duration: isHold ? 400 : root.rippleDuration
                    easing.type: Easing.InOutQuad
                }
                
                NumberAnimation {
                    target: ripple
                    property: "opacity"
                    from: 0.24
                    to: isHold ? 0.12 : 0
                    duration: isHold ? 400 : root.rippleDuration
                    easing.type: Easing.InOutQuad
                }
                
                onFinished: if (!isHold) ripple.destroy()
            }
        }
    }
}
