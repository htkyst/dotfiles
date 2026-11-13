import QtQuick

Item {
    id: root
    // All three PNGs use the same 1536 x 1024 coordinate system.
    property real progress: 0
    property real bendY: 0
    property int direction: 1
    property bool turning: false
    property int pageCount: 8
    property int currentPage: 1
    signal closeRequested()
    signal pickerRequested()

    function cancelTurn() {
        landing.stop();
        turning = false;
        progress = 0;
        bendY = 0;
    }

    function openPage(page) {
        cancelTurn();
        currentPage = clamp(Math.round(page), 1, pageCount);
    }

    // Reserve space above the book for the lifted edge (and below for dragging).
    readonly property real bookScale: Math.max(0.01, Math.min(Math.max(1, width - 112) / 1536, (height - 30) / 1280))
    readonly property real bookX: (width - 112 - 1536 * bookScale) / 2
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
            if (landing.to === 1) root.currentPage = root.clamp(root.currentPage + root.direction, 1, root.pageCount);
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
                if (root.currentPage + root.direction < 1 || root.currentPage + root.direction > root.pageCount) {
                    mouse.accepted = false;
                    return;
                }
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
            : "ページ " + root.currentPage + " / " + root.pageCount + "  ·  左右をドラッグしてめくる  ·  しおりでページ一覧"
        color: "#cdbb98"
        font.pixelSize: 13
    }

    // Reserve a dedicated rail to the right of the full book image.
    Item {
        id: bookmark
        objectName: "bookmark"
        width: 64
        height: 192
        x: root.bookX + 1536 * root.bookScale + 24
        y: Math.max(48, (root.height - height) / 2)
        Image {
            anchors.fill: parent
            source: "assets/siori.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Text {
            anchors.top: parent.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ページ一覧"
            color: "#e3c995"
            font.pixelSize: 12
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.cancelTurn();
                root.pickerRequested();
            }
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
