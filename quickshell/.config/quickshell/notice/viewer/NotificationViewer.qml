import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Scope {
    id: root

    property bool popupVisible: false
    property var notices: []

    function addNotice(title, message) {
        notices = [...notices, {
            title: title,
            message: message
        }]
    }

    // Notification Server
    NotificationServer {
        id: notificationServer

        onNotification: notification => {
            notification.tracked = true
            root.addNotice(
                notification.summary,
                notification.body
            )           
        }
    }

    // Widget
    PanelWindow {
        id: notificationWindow

        visible: root.popupVisible

        anchors {
            top: true
            right: true
            bottom: true
        }

        margins {
            top: 25
            right: 3 
            bottom: 0
        }

        color: "transparent"

        implicitWidth: 350
        implicitHeight: screen.height

        exclusionMode: ExclusionMode.Ignore

        // Notification area
        Rectangle {
            anchors.fill: parent

            color: "transparent"

            // Scroll window
            Flickable {
                id: flickable

                anchors.fill: parent

                clip: true

                contentWidth: width
                contentHeight: noticeColumn.implicitHeight

                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds

                // Notification item list
                Column {
                    id: noticeColumn

                    width: flickable.width
                    spacing: 15

                    Repeater {
                        model: root.notices

                        // Notification item
                        Rectangle {
                            id: noticeItem

                            property bool expanded: false

                            readonly property real collapsedHeight: contentColumn.implicitHeight + 20
                            readonly property real expandedHeight: contentColumnFull.implicitHeight + 20

                            property real animatedHeight: collapsedHeight

                            property bool showFullText: false

                            property color randomColor: Qt.rgba(
                                Math.random(),
                                Math.random(),
                                Math.random(),
                                0.5
                            )

                            property real brightness: 0.299 * randomColor.r + 0.587 * randomColor.g + 0.114 * randomColor.b

                            property color textColor: brightness > 0.5 ? "#000000" : "#ffffff"

                            Layout.fillWidth: true
                            implicitHeight: 64

                            width: noticeColumn.width
                            height: animatedHeight

                            radius: 20

                            color: randomColor

                            Behavior on height {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.InOutCubic
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 0
                                spacing: 5

                                // Image icon
                                Item {
                                    id: noticeIconContainer

                                    Layout.preferredWidth: 64
                                    Layout.fillHeight: true

                                    Item {
                                        id: noticeIconBox

                                        property real side: Math.min(
                                            noticeIconContainer.width,
                                            noticeIconContainer.height
                                        )

                                        width: side
                                        height: side

                                        anchors.centerIn: parent

                                        // Icon
                                        Image {
                                            id: noticeIcon

                                            source: Qt.resolvedUrl("../assets/char-face-smile-up.png") 
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true

                                            visible: false
                                        }

                                        Rectangle {
                                            id: noticeIconMask

                                            anchors.fill: parent
                                            radius: width / 2
                                            color: "white"

                                            visible: false
                                            layer.enabled: true
                                        }

                                        MultiEffect {
                                            anchors.fill: parent

                                            source: noticeIcon
                                            maskEnabled: true
                                            maskSource: noticeIconMask

                                            visible: noticeIcon.status == Image.Ready
                                        }
                                    }
                                }

                                // Message (preview)
                                ColumnLayout {
                                    id: contentColumn

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    spacing: 6

                                    visible: !noticeItem.showFullText

                                    Text {
                                        text: modelData.title

                                        color: noticeItem.textColor
                                        font.family: "Noto Serif"
                                        font.pixelSize: 11
                                        font.bold: true

                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap

                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.message

                                        color: noticeItem.textColor
                                        font.family: "Noto Serif"
                                        font.pixelSize: 9

                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText

                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                }

                                // Message (full)
                                ColumnLayout {
                                    id: contentColumnFull

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    spacing: 6

                                    visible: noticeItem.showFullText

                                    Text {
                                        text: modelData.title

                                        color: noticeItem.textColor
                                        font.family: "Noto Serif"
                                        font.pixelSize: 11
                                        font.bold: true

                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }

                                    Text {
                                        text: modelData.message

                                        color: noticeItem.textColor
                                        font.family: "Noto Serif"
                                        font.pixelSize: 9

                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText
                                    }
                                }

                            } // RowLayout

                            SequentialAnimation {
                                id: expandAnimation

                                NumberAnimation {
                                    target: noticeItem
                                    property: "animatedHeight"
                                    to: noticeItem.expandedHeight
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }

                                ScriptAction {
                                    script: {
                                        noticeItem.showFullText = true
                                        noticeItem.expanded = true
                                    }
                                }
                            }

                            SequentialAnimation {
                                id: collapseAnimation

                                ScriptAction {
                                    script: {
                                        noticeItem.showFullText = false
                                    }
                                }

                                NumberAnimation {
                                    target: noticeItem
                                    property: "animatedHeight"
                                    to: noticeItem.collapsedHeight
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }

                                ScriptAction {
                                    script: {
                                        noticeItem.expanded = false
                                    }
                                }
                            }

                            TapHandler {
                                onTapped: {
                                    if (expandAnimation.running || collapseAnimation.running) {
                                        return
                                    }

                                    if (noticeItem.expanded)
                                        collapseAnimation.start()
                                    else
                                        expandAnimation.start()
                                }
                            }

                        } // Rectangle
                    } // Repeater
                } // ColumnLayout
            } // Flickable
        } // Rectangle
    } // PanelWindow
}
