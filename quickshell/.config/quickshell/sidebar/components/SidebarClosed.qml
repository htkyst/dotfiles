import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    anchors {
        top: true
        bottom: true
        left: true
    }

    margins {
        top: 50
        bottom: 50
    }

    implicitWidth: 3
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        anchors.fill: parent

        radius: 30
        color: "#20fff0f5"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                GlobalState.isOpened = true
            }
        }
    }
}
