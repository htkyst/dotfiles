import Quickshell
import Quickshell.Io
import "./popup"
import "./viewer"

ShellRoot {
    NotificationPopup {
    }

    NotificationViewer {
        id: notificationViewer
    }

    IpcHandler {
        target: "notice"

        function toggle(): void {
            notificationViewer.popupVisible = !notificationViewer.popupVisible
        }

        function show(): void {
            notificationViewer.popupVisible = true
        }

        function hide(): void {
            notificationViewer.popupVisible = false
        }
    }
}
