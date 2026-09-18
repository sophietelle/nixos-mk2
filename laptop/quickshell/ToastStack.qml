pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

// A right-hand stack of toasts on every screen. Give it a model and a
// Toast delegate; it owns the windows, nothing else.
Scope {
  id: root

  property var model
  property Component delegate

  // Which corner the stack grows from. Bottom right by default.
  property bool atTop: false

  property int toastWidth: 350
  property string layerNamespace: "qs-toasts"

  readonly property int spacing: 8
  readonly property int screenMargin: 10

  // Room inside the panel for the cards' drop shadow to render.
  readonly property int shadowPad: 28

  // The panel the cursor is over, if any. Hovering anywhere in the stack
  // holds every toast in it, so that reading the bottom one doesn't let
  // the ones above it expire and shuffle it out from under the cursor.
  property var hoveredPanel: null
  readonly property bool hovered: root.hoveredPanel !== null

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel

      required property var modelData
      screen: modelData

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: root.layerNamespace

      anchors {
        top: root.atTop
        bottom: !root.atTop
        right: true
      }

      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      visible: repeater.count > 0

      // fixed, so toasts don't flash as the window resizes around them
      implicitWidth: root.toastWidth + root.shadowPad + root.screenMargin
      implicitHeight: panel.screen.height

      // only toasts can handle clicks
      mask: Region {
        item: column
      }

      Column {
        id: column

        anchors {
          right: parent.right
          top: root.atTop ? parent.top : undefined
          bottom: root.atTop ? undefined : parent.bottom
          rightMargin: root.screenMargin
          topMargin: root.screenMargin
          bottomMargin: root.screenMargin
        }

        width: root.toastWidth
        spacing: root.spacing

        HoverHandler {
          onHoveredChanged: {
            if (hovered)
              root.hoveredPanel = panel;
            else if (root.hoveredPanel === panel)
              root.hoveredPanel = null;
          }
        }

        Repeater {
          id: repeater

          model: root.model
          delegate: root.delegate
        }
      }
    }
  }
}
