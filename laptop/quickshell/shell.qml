pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

ShellRoot {
    id: root

    // Width of a single toast. The window is padded around it so the drop
    // shadow has room to bleed without being clipped by the surface.
    readonly property int toastWidth: 380
    readonly property int pad: 32

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

            implicitWidth: root.toastWidth + root.pad * 2
            implicitHeight: column.implicitHeight + root.pad * 2

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
                    rightMargin: root.pad
                    bottomMargin: root.pad
                }

                width: root.toastWidth
                spacing: 10

                move: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

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
