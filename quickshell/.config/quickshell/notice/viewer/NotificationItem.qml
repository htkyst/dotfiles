import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

Rectangle {
    id: noticeItem

    required property var notification

    property real itemWidth: 0
    property real itemHeight: 0

    width: itemWidth
    height: itemHeight

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + 20

    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 5

        // Image icon
        Item {
            id: iconContainer

            Layout.preferredWidth: 64
            Layout.fillHeight: true

            Item {
                id: iconBox

                property real side: Math.min(
                    iconContainer.width,
                    iconContainer.height
                )

                width: side
                height: side

                anchors.centerIn: parent

                // Icon
                Image {
                    id: notificationIcon

                    source: Qt.resolvedUrl("../assets/char-face-smile-up.png") 
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    visible: false
                }

                Rectangle {
                    id: iconMask

                    anchors.fill: parent
                    radius: width / 2
                    color: "white"

                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    anchors.fill: parent

                    source: notificationIcon
                    maskEnabled: true
                    maskSource: iconMask

                    visible: notificationIcon.status == Image.Ready
                }
            }

        }

        // Message
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 6

            Text {
                text: noticeItem.notification.summary

                color: "#cdd6f4"
                font.family: "Noto Serif"
                font.pixelSize: 15
                font.bold: true

                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: noticeItem.notification.body

                color: "#bac2de"
                font.family: "Noto Serif"
                font.pixelSize: 13

                Layout.fillWidth: true
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }

        // 閉じるボタン
        Text {
            text: "×"
            color: "#6c7086"
            font.pixelSize: 20

            Layout.alignment: Qt.AlignTop

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    noticeItem.notification.dismiss()
                }
            }
        }

    }
}
