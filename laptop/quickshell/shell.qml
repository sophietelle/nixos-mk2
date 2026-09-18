pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

ShellRoot {
    id: root

    readonly property int toastWidth: 368

    // Room for the drop shadow to bleed on the sides facing into the screen.
    readonly property int shadowPad: 28

    // Gap between the card and the screen corner. It can be smaller than the
    // shadow needs: whatever spills past it falls off the screen edge anyway.
    readonly property int screenMargin: 10

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell-notifications"

            anchors {
                bottom: true
                right: true
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            visible: server.trackedNotifications.values.length > 0

            implicitWidth: root.toastWidth + root.shadowPad + root.screenMargin
            implicitHeight: column.implicitHeight + root.shadowPad + root.screenMargin

            // Only the toasts themselves take clicks, everything else
            // (padding + shadow bleed) falls through to the window below.
            mask: Region {
                item: column
            }

            Column {
                id: column

                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    rightMargin: root.screenMargin
                    bottomMargin: root.screenMargin
                }

                width: root.toastWidth
                spacing: 8

                Repeater {
                    model: server.trackedNotifications

                    delegate: Toast {
                        required property var modelData

                        notification: modelData
                        cardWidth: root.toastWidth
                    }
                }
            }
        }
    }
}
