import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
    }

    margins {
        top: 50
    }

    implicitWidth: 60
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    visible: GlobalState.isOpened 
        || GlobalState.isPinned 
        || fadeAnimation.running

    Item {
        anchors.fill: parent

        opacity: GlobalState.isOpened ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                id: fadeAnimation
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        SidebarItems {
            anchors.fill: parent
        }
    }
}
