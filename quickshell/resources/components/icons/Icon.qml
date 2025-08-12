import QtQuick 2.15

Item {
    id: root
    property string name: ""
    property color color: "#FFFFFF"
    property int size: 24
    implicitWidth: size
    implicitHeight: size

    Canvas {
        id: c
        anchors.fill: parent
        onPaint: {
            var ctx = getContext('2d');
            ctx.reset();
            var w = width, h = height;
            ctx.strokeStyle = root.color; ctx.fillStyle = root.color; ctx.lineWidth = Math.max(1.5, Math.min(w,h) * 0.1);
            function circle(x,y,r){ ctx.beginPath(); ctx.arc(x,y,r,0,Math.PI*2); ctx.stroke(); }
            switch (root.name) {
                case 'home':
                    ctx.beginPath();
                    ctx.moveTo(w*0.18, h*0.55); ctx.lineTo(w*0.50, h*0.20); ctx.lineTo(w*0.82, h*0.55);
                    ctx.moveTo(w*0.26, h*0.55); ctx.lineTo(w*0.26, h*0.80); ctx.lineTo(w*0.74, h*0.80); ctx.lineTo(w*0.74, h*0.55);
                    ctx.stroke();
                    break;
                case 'search':
                    circle(w*0.45, h*0.45, Math.min(w,h)*0.22);
                    ctx.beginPath(); ctx.moveTo(w*0.62, h*0.62); ctx.lineTo(w*0.82, h*0.82); ctx.stroke();
                    break;
                case 'person':
                    circle(w*0.5, h*0.36, Math.min(w,h)*0.18);
                    ctx.beginPath(); ctx.moveTo(w*0.20, h*0.84); ctx.quadraticCurveTo(w*0.50, h*0.60, w*0.80, h*0.84); ctx.stroke();
                    break;
                case 'flashlight':
                    ctx.beginPath();
                    ctx.moveTo(w*0.40, h*0.18); ctx.lineTo(w*0.60, h*0.18); ctx.lineTo(w*0.55, h*0.40); ctx.lineTo(w*0.45, h*0.40); ctx.closePath(); ctx.stroke();
                    ctx.beginPath(); ctx.moveTo(w*0.45, h*0.40); ctx.lineTo(w*0.55, h*0.82); ctx.stroke();
                    break;
                case 'wifi':
                    ctx.beginPath(); ctx.arc(w*0.5, h*0.70, w*0.18, Math.PI, 0); ctx.stroke();
                    ctx.beginPath(); ctx.arc(w*0.5, h*0.58, w*0.30, Math.PI, 0); ctx.stroke();
                    ctx.beginPath(); ctx.arc(w*0.5, h*0.46, w*0.42, Math.PI, 0); ctx.stroke();
                    circle(w*0.5, h*0.78, w*0.04);
                    break;
                case 'bluetooth':
                    ctx.beginPath();
                    ctx.moveTo(w*0.40, h*0.20); ctx.lineTo(w*0.40, h*0.82);
                    ctx.moveTo(w*0.40, h*0.50); ctx.lineTo(w*0.65, h*0.30);
                    ctx.moveTo(w*0.40, h*0.50); ctx.lineTo(w*0.65, h*0.70);
                    ctx.stroke();
                    break;
                default:
                    // three dots
                    var r = Math.min(w,h)*0.10;
                    ctx.beginPath(); ctx.arc(w*0.30, h*0.5, r, 0, Math.PI*2); ctx.fill();
                    ctx.beginPath(); ctx.arc(w*0.50, h*0.5, r, 0, Math.PI*2); ctx.fill();
                    ctx.beginPath(); ctx.arc(w*0.70, h*0.5, r, 0, Math.PI*2); ctx.fill();
            }
        }
        onWidthChanged: requestPaint();
        onHeightChanged: requestPaint();
        onVisibleChanged: requestPaint();
    }

    onNameChanged: c.requestPaint();
    onColorChanged: c.requestPaint();
}


