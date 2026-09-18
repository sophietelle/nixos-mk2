pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Flashes the new layout's code in the top right whenever mango switches
// keyboard layouts. Same card as the notification toasts, just smaller.
Scope {
  id: root

  // Same card metrics as a notification, so the pill reads as one of them.
  readonly property int padding: 13
  readonly property int fontSize: 13

  // xkb layout description -> the code the pill shows.
  readonly property var codes: ({
    "English (US)": "en",
    "Russian": "ru",
    "Ukrainian": "ua"
  })

  property string layout: ""

  // Anything not in the table still gets a guess rather than an empty card.
  readonly property string code: root.codes[root.layout]
    ?? root.layout.slice(0, 2).toLowerCase()

  // `watch` reports the layout already in place as soon as it connects.
  // That one isn't a switch, so it shouldn't flash a pill at login.
  property bool primed: false

  // At most one pill. Switching again while it's still up keeps that card
  // and only restarts its timeout, so the fade in doesn't replay.
  property bool shown: false
  property int epoch: 0

  Process {
    running: true
    command: ["mmsg", "watch", "keyboardlayout"]

    stdout: SplitParser {
      onRead: line => {
        let layout = "";
        try {
          layout = JSON.parse(line).layout ?? "";
        } catch (e) {
          return;
        }

        if (layout === "" || layout === root.layout)
          return;

        root.layout = layout;

        if (!root.primed) {
          root.primed = true;
          return;
        }

        if (root.shown)
          root.epoch++;
        else
          root.shown = true;
      }
    }
  }

  FontMetrics {
    id: fm

    font.pixelSize: root.fontSize
  }

  // Every code gets the same card, measured off the widest and tallest of
  // them, so swapping the letters in place can't resize it underneath.
  readonly property rect glyphs: {
    let width = 0;
    let top = 0;
    let bottom = 0;

    for (const code of Object.values(root.codes)) {
      const tight = fm.tightBoundingRect(code);

      width = Math.max(width, fm.advanceWidth(code));
      top = Math.min(top, tight.y);
      bottom = Math.max(bottom, tight.y + tight.height);
    }

    return Qt.rect(0, top, Math.ceil(width), Math.ceil(bottom - top));
  }

  ToastStack {
    id: stack

    model: root.shown ? 1 : 0

    atTop: true
    toastWidth: root.glyphs.width + root.padding * 2
    layerNamespace: "qs-language"

    delegate: Toast {
      id: toast

      groupHovered: stack.hovered
      closable: false
      padding: root.padding
      timeout: 800

      // Bumped when the layout changes with the pill already on screen.
      readonly property int epoch: root.epoch
      onEpochChanged: toast.renew()

      onDismissed: root.shown = false

      // A line box carries a lot of empty leading above and below the
      // glyphs, and not the same amount of each. Sizing the card to the
      // glyphs instead leaves the padding even on all four sides.
      content: Item {
        anchors {
          left: parent.left
          right: parent.right
        }

        implicitHeight: root.glyphs.height

        Text {
          anchors.horizontalCenter: parent.horizontalCenter

          // Drops the baseline where the glyph box wants it, rather than
          // where the line box's ascent would have put it.
          y: -root.glyphs.y - fm.ascent

          text: root.code
          color: "#FFFFFF"
          font.pixelSize: root.fontSize
        }
      }
    }
  }
}
