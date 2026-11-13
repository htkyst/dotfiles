import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "#211b14"

        Book {
            anchors.fill: parent
            anchors.margins: 20
            onCloseRequested: Qt.quit()
        }
    }
}
