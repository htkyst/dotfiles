import QtQuick
import Quickshell

ShellRoot {
    FloatingWindow {
        title: "Book"
        implicitWidth: 1100
        implicitHeight: 780
        color: "#211b14"

        Book {
            anchors.fill: parent
            anchors.margins: 20
        }
    }
}
