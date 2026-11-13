import QtQuick

Item {
    id: root
    // All three PNGs use the same 1536 x 1024 coordinate system.
    property real progress: 0
    property real bendY: 0
    property int direction: 1
    property bool turning: false
    // Signed spread indices preserve unlimited turning in both directions.
    property int currentSpread: 0
    property bool hasBookmark: false
    property int bookmarkSpread: 0
    property real bookmarkX: 1100
    property real bookmarkY: 250
    signal closeRequested()

    function placeBookmark(x, y) {
        const px = (x - bookX) / bookScale;
        const py = (y - bookY) / bookScale;
        // Stay inside the paper, excluding the binding and cover.
        if (turning || py < 95 || py > 900
                || !((px >= 210 && px <= 730) || (px >= 810 && px <= 1330)))
            return false;
        bookmarkSpread = currentSpread;
        bookmarkX = px;
        bookmarkY = py;
        hasBookmark = true;
        return true;
    }

    function openBookmark() {
        if (!hasBookmark) return;
        landing.stop();
        turning = false;
        progress = 0;
        bendY = 0;
        currentSpread = bookmarkSpread;
    }
    // Reserve space above the book for the lifted edge (and below for dragging).
    readonly property real bookScale: Math.max(0.01, Math.min(width / 1536, (height - 30) / 1280))
    readonly property real bookX: (width - 1536 * bookScale) / 2
    readonly property real bookY: (height - 30 - 1280 * bookScale) / 2 + 160 * bookScale

    function clamp(value, low, high) { return Math.max(low, Math.min(high, value)); }

    function settle() {
        landing.to = progress >= 0.5 ? 1 : 0;
        landing.duration = 180 + 260 * Math.abs(landing.to - progress);
        landing.start();
    }

    Image {
        x: root.bookX; y: root.bookY
        width: 1536 * root.bookScale; height: 1024 * root.bookScale
        source: "assets/book.png"
        smooth: true
    }

    // Image textures are uploaded once. Keep their original, full-canvas UVs.
    Image {
        id: rightTexture
        source: "assets/page-right.png"
        visible: false
        smooth: true
    }
    Image {
        id: leftTexture
        source: "assets/page-left.png"
        visible: false
        smooth: true
    }

    ShaderEffect {
        id: sheet
        objectName: "pageShader"
        x: root.bookX; y: root.bookY - 160 * root.bookScale
        width: 1536 * root.bookScale; height: 1280 * root.bookScale
        visible: root.turning && rightTexture.status === Image.Ready && leftTexture.status === Image.Ready
        property var rightPage: rightTexture
        property var leftPage: leftTexture
        property real progress: root.progress
        property real direction: root.direction
        property real bendY: root.bendY
        fragmentShader: "shaders/page.frag.qsb"
        onStatusChanged: {
            if (status === ShaderEffect.Error) console.error("Book shader:", log);
        }
    }

    NumberAnimation {
        id: landing
        target: root
        property: "progress"
        easing.type: Easing.InOutCubic
        onFinished: {
            if (landing.to === 1) root.currentSpread += root.direction;
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
            root.progress = root.clamp(startProgress + root.direction * (startX - mouse.x) / (1220 * root.bookScale), 0, 1);
            root.bendY = root.clamp(startBend + (mouse.y - startY) / root.bookScale, -100, 100);
        }
        onReleased: root.settle()
        onCanceled: root.settle()
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: sheet.status === ShaderEffect.Error
            ? "シェーダーを読み込めません。READMEの再ビルド手順を確認してください。"
            : "見開き " + root.currentSpread + "  ·  左右をドラッグしてめくる  ·  しおりをページへドラッグ"
        color: "#cdbb98"
        font.pixelSize: 13
    }

    // Park the bookmark outside the paper on other spreads, so it remains
    // clickable even after turning many pages. Coordinates stay bound on resize.
    Item {
        id: bookmark
        objectName: "bookmark"
        width: Math.max(32, 64 * root.bookScale)
        height: width * 3
        readonly property bool onSavedPage: root.hasBookmark && !root.turning
            && root.currentSpread === root.bookmarkSpread
        x: bookmarkMouse.moving ? bookmarkMouse.dragX
            : onSavedPage ? root.bookX + root.bookmarkX * root.bookScale - width / 2
            : Math.min(root.width - width - 16, root.bookX + 1400 * root.bookScale)
        y: bookmarkMouse.moving ? bookmarkMouse.dragY
            : onSavedPage ? root.bookY + root.bookmarkY * root.bookScale - height / 2
            : Math.max(48, root.bookY - height / 2)

        Image {
            anchors.fill: parent
            source: "assets/siori.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Text {
            anchors.top: parent.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.hasBookmark ? "見開き " + root.bookmarkSpread
                + (root.bookmarkX < 768 ? "・左" : "・右") : "しおり"
            color: "#e3c995"
            font.pixelSize: 12
        }
        MouseArea {
            id: bookmarkMouse
            anchors.fill: parent
            preventStealing: true
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            property bool moving: false
            property real pressX: 0
            property real pressY: 0
            property real offsetX: 0
            property real offsetY: 0
            property real dragX: 0
            property real dragY: 0
            onPressed: mouse => {
                const p = mapToItem(root, mouse.x, mouse.y);
                pressX = p.x; pressY = p.y;
                offsetX = mouse.x; offsetY = mouse.y;
                dragX = bookmark.x; dragY = bookmark.y;
                moving = false;
            }
            onPositionChanged: mouse => {
                if (!pressed) return;
                const p = mapToItem(root, mouse.x, mouse.y);
                if (Math.hypot(p.x - pressX, p.y - pressY) > 6) moving = true;
                if (moving) {
                    dragX = root.clamp(p.x - offsetX, 0, root.width - bookmark.width);
                    dragY = root.clamp(p.y - offsetY, 0, root.height - bookmark.height);
                }
            }
            onReleased: mouse => {
                if (moving) {
                    const p = mapToItem(root, mouse.x, mouse.y);
                    root.placeBookmark(p.x, p.y);
                } else {
                    root.openBookmark();
                }
                moving = false;
            }
            onCanceled: moving = false
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        width: 36; height: 36
        radius: 18
        color: closeMouse.containsMouse ? "#67503a" : "#3d3023"
        Text { anchors.centerIn: parent; text: "×"; color: "#e3c995"; font.pixelSize: 24 }
        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested()
        }
    }
}
