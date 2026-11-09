import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Rectangle {
    id: iconArea
    color: "transparent"

    Column {
        anchors.fill: parent
        spacing: 3
        z: 1    // Positioned in front of hoverArea

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-notification.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    noticeProcess.running = true
                }
            }
        }

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-tools.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                }
            }
        }

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-music.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                }
            }
        }

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-illust.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                }
            }
        }

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-coding.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                }
            }
        }

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-setting.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                }
            }
        }

        Image {
            width: iconArea.width

            source: Qt.resolvedUrl("../assets/page-char.png")
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                }
            }
        }
    }

    Process {
        id: noticeProcess

        command: [
            "qs",
            "-c", "notice",
            "ipc", "call",
            "notice", "toggle"
        ]

        running: false
    }

    HoverHandler {
        id: hoverHandler

        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop()
            } else if (!GlobalState.isPinned) {
                closeTimer.start()
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 200
        repeat: false

        onTriggered: {
            if (!GlobalState.isPinned && !hoverHandler.hovered) {
                GlobalState.isOpened = false
            }
        }
    }

}
