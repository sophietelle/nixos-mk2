import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Item {
    id: root

    required property var notification

    property int cardWidth: 380
    property int padding: 16

    implicitWidth: cardWidth
    implicitHeight: card.implicitHeight

    function close(): void {
        if (!closeAnim.running)
            closeAnim.start();
    }

    // The shadow is cast by a hidden copy of the card's silhouette so the
    // real card keeps crisp, unrasterised text on top of it.
    Rectangle {
        id: shadowCaster

        width: card.width
        height: card.height
        radius: card.radius
        color: "black"
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: shadowCaster
        source: shadowCaster
        opacity: body.opacity
        scale: body.scale

        shadowEnabled: true
        shadowColor: "#000000"
        shadowOpacity: 0.9
        shadowBlur: 1.0
        blurMax: 32
        shadowVerticalOffset: 8
    }

    Item {
        id: body

        anchors.fill: parent
        opacity: 0
        scale: 0.9

        Rectangle {
            id: card

            width: root.cardWidth
            implicitHeight: layout.implicitHeight + root.padding * 2

            color: "#000000"
            radius: 26
            border.width: 1
            border.color: "#151516"

            RowLayout {
                id: layout

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: root.padding
                    rightMargin: root.padding
                }

                spacing: 12

                Item {
                    id: avatar

                    Layout.alignment: Qt.AlignVCenter

                    implicitWidth: 44
                    implicitHeight: 44

                    // Whatever picture the notification carries: a contact photo
                    // or album art if the app sent one, otherwise its own icon.
                    readonly property string pfp: root.notification.image

                    // The app's own icon, for the badge. The notification's
                    // app_icon is folded into `image` by the server, so the
                    // desktop entry is what tells a photo and an icon apart.
                    //
                    // Scanning the list rather than calling byId() is deliberate:
                    // it reads `values`, so the binding re-runs once the entries
                    // finish loading, which is after the first notification.
                    readonly property string appIcon: {
                        const entries = DesktopEntries.applications.values;
                        const id = root.notification.desktopEntry.toLowerCase();
                        const name = root.notification.appName.toLowerCase();

                        let match = null;
                        for (let i = 0; i < entries.length; i++) {
                            const entry = entries[i];
                            const entryId = entry.id.toLowerCase();

                            if (id !== "" && (entryId === id || entryId === id + ".desktop"))
                                match = entry;
                            else if (!match && name !== "" && entry.name.toLowerCase() === name)
                                match = entry;
                        }

                        return match && match.icon !== "" ? Quickshell.iconPath(match.icon, true) : "";
                    }

                    // A picture that loaded and isn't merely the app icon again.
                    readonly property bool hasPfp: mainIcon.status === Image.Ready && pfp !== appIcon

                    ClippingRectangle {
                        anchors.fill: parent

                        // Circle for a photo, rounded square for an app icon.
                        radius: avatar.hasPfp ? width / 2 : width * 0.28
                        color: "#141416"

                        // Nothing loaded: a monogram, rather than Qt's magenta
                        // "missing image" tile.
                        Text {
                            anchors.centerIn: parent
                            visible: mainIcon.status !== Image.Ready && fillIcon.status !== Image.Ready
                            text: root.notification.appName.charAt(0).toUpperCase()
                            color: "#E0E1E4"
                            font.pixelSize: 19
                            font.weight: Font.DemiBold
                        }

                        // Both are always loaded, and shown or hidden by opacity,
                        // because an invisible image never reaches Ready.
                        IconImage {
                            id: fillIcon

                            anchors.fill: parent
                            opacity: mainIcon.status === Image.Ready ? 0 : 1
                            source: avatar.appIcon
                        }

                        // A plain Image, not an IconImage: photos are rarely
                        // square and should fill the circle rather than letterbox.
                        Image {
                            id: mainIcon

                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: width
                            sourceSize.height: height
                            opacity: status === Image.Ready ? 1 : 0
                            source: avatar.pfp
                        }
                    }

                    // App icon badged onto the photo. The ring is the card's own
                    // black, so it reads as a cutout.
                    Rectangle {
                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                            rightMargin: -2
                            bottomMargin: -2
                        }

                        // Opacity rather than visibility: an invisible badge
                        // never loads its icon, so it could never become Ready.
                        opacity: avatar.hasPfp && badge.status === Image.Ready ? 1 : 0
                        width: 21
                        height: 21
                        radius: width / 2
                        color: card.color

                        IconImage {
                            id: badge

                            anchors.centerIn: parent
                            implicitSize: 16
                            source: avatar.appIcon
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true

                        visible: text !== ""
                        text: root.notification.summary
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 2

                        visible: text !== ""
                        text: root.notification.body
                        color: "#A9AEB4"
                        font.pixelSize: 12
                        textFormat: Text.StyledText
                        wrapMode: Text.WordWrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                    }
                }
            }
        }

        MouseArea {
            id: mouse

            anchors.fill: card
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: event => {
                if (event.button === Qt.LeftButton) {
                    const actions = root.notification.actions;
                    for (let i = 0; i < actions.length; i++) {
                        if (actions[i].identifier === "default") {
                            actions[i].invoke();
                            return;
                        }
                    }
                }

                root.close();
            }
        }
    }

    // Critical notifications and ones asking to never expire stay put.
    Timer {
        running: !mouse.containsMouse
            && root.notification.expireTimeout !== 0
            && root.notification.urgency !== NotificationUrgency.Critical
        interval: root.notification.expireTimeout > 0 ? root.notification.expireTimeout : 5000
        onTriggered: root.close()
    }

    ParallelAnimation {
        running: true

        NumberAnimation {
            target: body
            property: "opacity"
            to: 1
            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: body
            property: "scale"
            to: 1
            duration: 420
            easing.type: Easing.OutBack
            easing.overshoot: 1.6
        }
    }

    SequentialAnimation {
        id: closeAnim

        ParallelAnimation {
            NumberAnimation {
                target: body
                property: "opacity"
                to: 0
                duration: 180
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: body
                property: "scale"
                to: 0.92
                duration: 180
                easing.type: Easing.InCubic
            }
        }

        ScriptAction {
            script: {
                if (root.notification)
                    root.notification.dismiss();
            }
        }
    }
}
