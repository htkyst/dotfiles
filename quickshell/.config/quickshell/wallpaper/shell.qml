import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool opened: false
    property var images: []
    property string message: ""
    readonly property string directory: Quickshell.env("WALLPAPER_DIR") || (Quickshell.env("HOME") + "/wallpaper")
    readonly property size thumbnailSize: Qt.size(768, 432)

    function imageUrl(path: string): string {
        return "file://" + path.split("/").map(encodeURIComponent).join("/")
    }

    // Keep decoded previews alive even while the panel is hidden. Bound the
    // preload window so large wallpaper folders do not exhaust memory.
    Instantiator {
        model: Math.min(root.images.length, 27)
        delegate: Image {
            required property int index
            readonly property int imageIndex: (Math.max(0, carousel.currentIndex) + index
                - Math.floor(Math.min(root.images.length, 27) / 2)
                + root.images.length) % Math.max(1, root.images.length)
            visible: false
            source: root.images.length ? root.imageUrl(root.images[imageIndex]) : ""
            asynchronous: true
            cache: true
            sourceSize: root.thumbnailSize
            fillMode: Image.PreserveAspectCrop
        }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            root.opened = !root.opened
            if (root.opened && !scan.running) {
                root.message = ""
                scan.running = true
            }
        }
    }

    Process {
        id: scan
        running: true
        command: ["find", "-L", root.directory, "-type", "f", "(", "-iname", "*.jpg",
                  "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname",
                  "*.webp", "-o", "-iname", "*.bmp", "-o", "-iname", "*.gif", ")", "-print0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = text.split("\u0000").filter(path => path.length > 0).sort()
                // Avoid rebuilding delegates and restarting image loads on every toggle.
                if (paths.length === root.images.length &&
                    paths.every((path, index) => path === root.images[index])) return
                const selected = root.images[carousel.currentIndex]
                root.images = paths
                carousel.currentIndex = Math.max(0, paths.indexOf(selected))
            }
        }
        onExited: code => {
            if (code !== 0) root.message = "フォルダーを読み込めませんでした · " + root.directory
        }
    }

    Process {
        id: apply
        onExited: code => {
            if (code === 0) root.opened = false
            else root.message = "壁紙を設定できませんでした。awww-daemon の起動を確認してください。"
        }
    }

    PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "#e6151720"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_H: carousel.decrementCurrentIndex(); break
                case Qt.Key_J: carousel.incrementCurrentIndex(); break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    const path = root.images[carousel.currentIndex]
                    if (path && !apply.running) {
                        apply.command = ["awww", "img", path]
                        apply.running = true
                    }
                    break
                case Qt.Key_Escape: root.opened = false; break
                default: return
                }
                event.accepted = true
            }

            PathView {
                id: carousel
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: parent.height * 0.58
                model: root.images
                pathItemCount: 9
                cacheItemCount: 18
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightRangeMode: PathView.StrictlyEnforceRange
                highlightMoveDuration: 320
                readonly property real rx: width * 0.34
                readonly property real ry: height * 0.20
                path: Path {
                    startX: carousel.width / 2
                    startY: carousel.height / 2 - carousel.ry
                    PathAttribute { name: "depth"; value: 0 }
                    PathArc {
                        x: carousel.width / 2; y: carousel.height / 2 + carousel.ry
                        radiusX: carousel.rx; radiusY: carousel.ry
                    }
                    PathAttribute { name: "depth"; value: 1 }
                    PathArc {
                        x: carousel.width / 2; y: carousel.height / 2 - carousel.ry
                        radiusX: carousel.rx; radiusY: carousel.ry
                    }
                    PathAttribute { name: "depth"; value: 0 }
                }
                delegate: Rectangle {
                    id: card
                    required property string modelData
                    width: Math.min(carousel.width * 0.47, carousel.height * 1.16)
                    height: width * 9 / 16
                    scale: 0.38 + 0.62 * PathView.depth
                    opacity: 0.4 + 0.6 * PathView.depth
                    z: PathView.depth
                    visible: PathView.onPath
                    color: PathView.isCurrentItem ? "#e6dcc5" : "#494a51"
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: root.imageUrl(card.modelData)
                        asynchronous: true
                        cache: true
                        sourceSize: root.thumbnailSize
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }

            Column {
                anchors.top: carousel.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9
                spacing: 10
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.message || (scan.running && !root.images.length ? "読み込み中…" :
                          (root.images[carousel.currentIndex] || "").split("/").pop() ||
                          "画像がありません · " + root.directory)
                    textFormat: Text.PlainText
                    elide: Text.ElideMiddle
                    color: "#f2ece3"
                    font.pixelSize: 22
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "h  前へ     j  次へ     Enter  設定     Esc  閉じる"
                    color: "#c2bdba"
                }
            }
        }
    }
}
