import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: shell
    property bool pickerOpen: false
    // One entry per selectable page. Replace individual URLs as artwork arrives.
    readonly property var pageImages: [
        "assets/siori.png", "assets/siori.png", "assets/siori.png", "assets/siori.png",
        "assets/siori.png", "assets/siori.png", "assets/siori.png", "assets/siori.png"
    ]

    PanelWindow {
        id: bookWindow
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "#211b14"

        Book {
            id: book
            anchors.fill: parent
            anchors.margins: 20
            pageCount: shell.pageImages.length
            enabled: !shell.pickerOpen
            onPickerRequested: shell.pickerOpen = true
            onCloseRequested: Qt.quit()
        }
    }

    PanelWindow {
        visible: shell.pickerOpen
        screen: bookWindow.screen
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: true
        color: "transparent"

        PagePicker {
            anchors.fill: parent
            pageImages: shell.pageImages
            currentPage: book.currentPage
            onPageSelected: page => {
                shell.pickerOpen = false;
                book.openPage(page);
            }
            onCloseRequested: shell.pickerOpen = false
        }
    }
}
