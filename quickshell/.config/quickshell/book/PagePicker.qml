pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window

Rectangle {
    id: root
    color: "#b8000000"
    property var pageImages: []
    property int currentPage: 1
    signal pageSelected(int page)
    signal closeRequested()
    focus: true
    Component.onCompleted: forceActiveFocus()
    onVisibleChanged: if (visible) forceActiveFocus()
    Connections {
        target: root.Window.window
        function onVisibleChanged() {
            if (root.Window.window.visible) Qt.callLater(root.forceActiveFocus);
        }
    }
    Keys.onEscapePressed: root.closeRequested()

    MouseArea {
        anchors.fill: parent
        onClicked: root.closeRequested()
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(880, root.width - 48)
        height: Math.min(650, root.height - 48)
        radius: 18
        color: "#30251b"
        border.color: "#84663c"
        // Consume clicks in the dialog without closing the window.
        MouseArea { anchors.fill: parent }

        Text {
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            text: "開くページを選択"
            color: "#ead6ad"
            font.pixelSize: 20
        }
        Grid {
            id: grid
            anchors.horizontalCenter: parent.horizontalCenter
            y: 80
            columns: panel.width < 600 ? 2 : 4
            spacing: 20
            readonly property int rowCount: Math.max(1, Math.ceil(root.pageImages.length / columns))
            readonly property real cellWidth: (panel.width - 64 - spacing * (columns - 1)) / columns
            readonly property real cellHeight: (panel.height - 112 - spacing * (rowCount - 1)) / rowCount
            Repeater {
                model: root.pageImages
                Rectangle {
                    id: card
                    required property int index
                    required property string modelData
                    objectName: "pageCard" + (index + 1)
                    width: grid.cellWidth
                    height: grid.cellHeight
                    radius: 10
                    color: cardMouse.containsMouse ? "#57412b" : "#3a2d20"
                    border.width: root.currentPage === index + 1 ? 2 : 1
                    border.color: root.currentPage === index + 1 ? "#e4bd76" : "#705537"
                    Image {
                        anchors.top: parent.top
                        anchors.topMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 24
                        height: Math.max(1, parent.height - 52)
                        source: Qt.resolvedUrl(card.modelData)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ページ " + (card.index + 1)
                        color: "#ead6ad"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pageSelected(card.index + 1)
                    }
                }
            }
        }
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            width: 48; height: 48
            text: "×"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "#ead6ad"
            font.pixelSize: 24
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()
            }
        }
    }
}
