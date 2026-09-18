pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Scope {
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

  ToastStack {
    id: stack

    model: server.trackedNotifications

    delegate: Toast {
      id: toast

      required property var modelData

      groupHovered: stack.hovered

      readonly property var defaultAction: {
        const actions = toast.modelData.actions;
        for (let i = 0; i < actions.length; i++) {
          if (actions[i].identifier === "default")
            return actions[i];
        }
        return null;
      }

      readonly property bool expires: toast.modelData.expireTimeout !== 0
        && toast.modelData.urgency !== NotificationUrgency.Critical

      timeout: !expires
        ? 0
        : toast.modelData.expireTimeout > 0
          ? toast.modelData.expireTimeout
          : 5000

      clickable: defaultAction !== null

      onClicked: {
        if (toast.defaultAction)
          toast.defaultAction.invoke();
      }

      onDismissed: {
        if (toast.modelData)
          toast.modelData.dismiss();
      }

      content: RowLayout {
        anchors {
          left: parent.left
          right: parent.right
        }

        spacing: 11

        Item {
          id: avatar

          Layout.alignment: Qt.AlignVCenter

          visible: hasVisual
          implicitWidth: 34
          implicitHeight: 34

          readonly property string pfp: toast.modelData.image

          readonly property string appIcon: {
            const entries = DesktopEntries.applications.values;
            const name = toast.modelData.appName;

            const hinted = toast.modelData.appIcon;
            if (hinted !== "") {
              const hintedPath = Quickshell.iconPath(hinted, true);
              if (hintedPath !== "")
                return hintedPath;
            }

            if (name === "")
              return "";

            let match = null;
            const lower = name.toLowerCase();
            for (const entry of entries) {
              if (entry.name.toLowerCase() === lower) {
                match = entry;
                break;
              }
            }

            return match ? Quickshell.iconPath(match.icon, true) : "";
          }

          readonly property bool hasPfp: mainIcon.status === Image.Ready && pfp !== appIcon
          readonly property bool hasVisual: appIcon !== ""
            || (pfp !== "" && mainIcon.status !== Image.Error)

          ClippingRectangle {
            anchors.fill: parent

            radius: avatar.hasPfp ? width / 2 : width * 0.28
            color: "#141416"

            IconImage {
              id: fillIcon

              anchors.fill: parent
              opacity: mainIcon.status === Image.Ready ? 0 : 1
              source: avatar.appIcon
            }

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

          // app icon badge
          Rectangle {
            anchors {
              right: parent.right
              bottom: parent.bottom
              rightMargin: -2
              bottomMargin: -2
            }

            opacity: avatar.hasPfp && badge.status === Image.Ready ? 1 : 0
            width: 17
            height: 17
            radius: width / 2
            color: toast.background

            IconImage {
              id: badge

              anchors.centerIn: parent
              implicitSize: 13
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
            text: toast.modelData.summary
            color: "#FFFFFF"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            elide: Text.ElideRight
          }

          Text {
            Layout.fillWidth: true
            Layout.topMargin: 2

            visible: text !== ""
            text: toast.modelData.body
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
  }
}
