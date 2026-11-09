import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    id: root

    property int nextId: 0
    property int maxNotifications: 4
    property int displayDuration: 5000

    function addNotification(appName, title, body) {
        notifications.insert(0, {
            uid: ++nextId,
            appName: appName || "Application",
            title: title || "",
            body: body || ""
        });

        while (notifications.count > maxNotifications) {
            notifications.remove(notifications.count - 1);
        }
    }

    function removeNotification(uid) {
        for (let i = 0; i < notifications.count; i++) {
            if (notifications.get(i).uid === uid) {
                notifications.remove(i);
                return;
            }
        }
    }

    ListModel {
        id: notifications
    }

    NotificationServer {
        id: notificationServer

        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: false
        imageSupported: false

        onNotification: notification => {
            root.addNotification(
                notification.appName,
                notification.summary,
                notification.body
            );
        }
    }

    PanelWindow {
        id: popup

        visible: notifications.count > 0
        color: "transparent"

        implicitWidth: 380
        implicitHeight: Math.max(
            1,
            Math.min(notifications.count, root.maxNotifications) * 140
        )

        anchors {
            top: true
            right: true
        }

        margins {
            top: 20
            right: 20
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay

        // 通知のない透明部分はクリックを妨げない
        mask: Region {
            width: popup.width
            height: popup.height
        }

        ListView {
            id: notificationList

            anchors.fill: parent
            clip: true

            spacing: 10
            interactive: false

            model: notifications

            // 新しい通知に押し出された既存通知を下へ移動
            addDisplaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }

            // 通知が消えたとき、残りを上へ移動
            removeDisplaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            delegate: Item {
                id: delegateRoot

                required property int uid
                required property string appName
                required property string title
                required property string body

                property bool leaving: false

                width: notificationList.width
                height: 130

                function dismiss() {
                    if (leaving)
                        return;

                    leaving = true;
                    lifeTimer.stop();
                    enterAnimation.stop();
                    exitAnimation.start();
                }

                Rectangle {
                    id: card

                    x: popup.width
                    y: 0

                    width: parent.width
                    height: parent.height

                    radius: 14
                    color: "#A0242936"

                    border.color: "#40495e"
                    border.width: 1

                    Rectangle {
                        x: 0
                        y: 16
                        width: 3
                        height: parent.height - 32
                        radius: 2
                        color: "#89b4fa"
                    }

                    Column {
                        x: 20
                        y: 14
                        width: parent.width - 56
                        spacing: 8

                        Text {
                            width: parent.width
                            text: delegateRoot.appName
                            color: "#89b4fa"
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }

                        Text {
                            width: parent.width
                            text: delegateRoot.title
                            color: "#ffffff"
                            font.pixelSize: 16
                            font.bold: true
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }

                        Text {
                            width: parent.width
                            text: delegateRoot.body
                            color: "#bac2de"
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                    }

                    Rectangle {
                        width: 26
                        height: 26

                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 10
                        }

                        radius: 6

                        color: closeMouse.containsMouse
                            ? "#454b60"
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "#cdd6f4"
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: closeMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: delegateRoot.dismiss()
                        }
                    }
                }

                NumberAnimation {
                    id: enterAnimation

                    target: card
                    property: "x"

                    from: popup.width
                    to: 0

                    duration: 420
                    easing.type: Easing.OutCubic

                    onFinished: {
                        if (!delegateRoot.leaving)
                            lifeTimer.start();
                    }
                }

                NumberAnimation {
                    id: exitAnimation

                    target: card
                    property: "x"

                    to: popup.width

                    duration: 300
                    easing.type: Easing.InCubic

                    onFinished: {
                        root.removeNotification(delegateRoot.uid);
                    }
                }

                Timer {
                    id: lifeTimer

                    interval: root.displayDuration
                    repeat: false

                    onTriggered: delegateRoot.dismiss()
                }

                Component.onCompleted: enterAnimation.start()
            }
        }
    }
}

