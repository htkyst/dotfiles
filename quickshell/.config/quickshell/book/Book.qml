import QtQuick
import "PageMesh.js" as Mesh

Item {
    id: root
    // All three PNGs use the same 1536 x 1024 coordinate system.
    property real progress: 0
    property real bendY: 0
    property int direction: 1
    property bool turning: false
    readonly property real bookScale: Math.max(0.01, Math.min(width / 1536, (height - 30) / 1024))
    readonly property real bookX: (width - 1536 * bookScale) / 2
    readonly property real bookY: (height - 30 - 1024 * bookScale) / 2

    function settle() {
        landing.to = progress >= 0.5 ? 1 : 0;
        landing.duration = 180 + 260 * Math.abs(landing.to - progress);
        landing.start();
    }

    onProgressChanged: sheet.requestPaint()
    onBendYChanged: sheet.requestPaint()
    onTurningChanged: sheet.requestPaint()

    Image {
        x: root.bookX; y: root.bookY
        width: 1536 * root.bookScale; height: 1024 * root.bookScale
        source: "assets/book.png"
        smooth: true
    }

    Canvas {
        id: sheet
        anchors.fill: parent
        renderTarget: Canvas.Image
        readonly property url rightPage: Qt.resolvedUrl("assets/page-right.png")
        readonly property url leftPage: Qt.resolvedUrl("assets/page-left.png")
        Component.onCompleted: {
            loadImage(rightPage);
            loadImage(leftPage);
        }
        onImageLoaded: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            if (!root.turning || !isImageLoaded(rightPage) || !isImageLoaded(leftPage))
                return;
            ctx.translate(root.bookX, root.bookY);
            ctx.scale(root.bookScale, root.bookScale);
            Mesh.paint(ctx, rightPage, leftPage, root.progress, root.direction, root.bendY);
        }
    }

    NumberAnimation {
        id: landing
        target: root
        property: "progress"
        easing.type: Easing.InOutCubic
        onFinished: {
            root.turning = false;
            root.progress = 0;
            root.bendY = 0;
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        property real startX: 0
        property real startY: 0
        property real startProgress: 0
        property real startBend: 0
        onPressed: mouse => {
            const px = (mouse.x - root.bookX) / root.bookScale;
            const py = (mouse.y - root.bookY) / root.bookScale;
            if (px < 161 || px > 1379 || py < 55 || py > 941) {
                mouse.accepted = false;
                return;
            }
            if (!root.turning) {
                root.direction = px >= 768 ? 1 : -1;
                root.progress = 0;
                root.bendY = 0;
            }
            landing.stop();
            startX = mouse.x;
            startY = mouse.y;
            startProgress = root.progress;
            startBend = root.bendY;
            root.turning = true;
        }
        onPositionChanged: mouse => {
            if (!pressed) return;
            root.progress = Mesh.clamp(startProgress + root.direction * (startX - mouse.x) / (1220 * root.bookScale), 0, 1);
            root.bendY = Mesh.clamp(startBend + (mouse.y - startY) / root.bookScale, -180, 180);
        }
        onReleased: root.settle()
        onCanceled: root.settle()
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "左右のページをドラッグしてめくる"
        color: "#cdbb98"
        font.pixelSize: 13
    }
}
