import QtQuick
import QtQuick.Effects

// One card: shadow, fade lifecycle, hover, dismiss button. Knows nothing
// about what it's showing.
Item {
  id: root

  // The card's contents. Anchor it to the left/right of its parent to
  // fill the width; the card sizes itself around what it reports.
  property alias content: cardContent.data

  property color background: "#000000"
  property int padding: 13

  // Time at full opacity before fading out. 0 stays up until closed.
  property int timeout: 5000

  // Whether a left click on the card does anything, for the cursor.
  property bool clickable: false

  // Whether hovering the card offers a dismiss button. Cards too small to
  // fit one turn it off; they still close on click.
  property bool closable: true

  signal clicked

  // Fired once the toast has finished fading out, however it got there:
  // expiry, the dismiss button, or close().
  signal dismissed

  // Fills the stack it sits in.
  implicitWidth: parent ? parent.width : 350
  implicitHeight: card.implicitHeight

  readonly property bool hovered: mouse.containsMouse

  // Set by the stack, so that hovering any toast holds all of them.
  property bool groupHovered: root.hovered

  property bool fading: false
  property bool fadeInterrupted: false
  property bool closing: false

  // Held false for one pass so the timeout binding drops and picks the
  // timer back up from zero. See renew().
  property bool renewing: false

  onGroupHoveredChanged: {
    if (root.closing)
      return;

    if (root.groupHovered) {
      root.fadeInterrupted = root.fading;
      root.fading = false;
    } else if (root.fadeInterrupted) {
      root.fading = true;
    }
  }

  onFadingChanged: {
    if (root.closing)
      return;

    if (root.fading) {
      fadeIn.stop();
      expireFade.restart();
    } else {
      expireFade.stop();
      fadeIn.restart();
    }
  }

  // Starts the toast's timeout over, pulling it back to full opacity if it
  // had begun fading. For a card whose contents changed while it was still
  // up: it stays where it is instead of replaying the fade in.
  function renew(): void {
    if (root.closing)
      return;

    root.fadeInterrupted = false;
    root.fading = false;

    // Through the binding rather than life.restart(), which would replace
    // it and leave the timer deaf to hover and fading afterwards.
    root.renewing = true;
    root.renewing = false;
  }

  function close(): void {
    if (root.closing)
      return;

    root.closing = true;
    expireFade.stop();
    fadeIn.stop();
    closeFade.start();
  }

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

    shadowEnabled: true
    shadowColor: "#000000"
    shadowOpacity: 0.9
    shadowBlur: 1.0
    blurMax: 24
  }

  Item {
    id: body

    anchors.fill: parent

    opacity: 0

    Rectangle {
      id: card

      width: root.width
      implicitHeight: cardContent.implicitHeight + root.padding * 2

      color: root.background
      radius: 18

      Item {
        id: cardContent

        anchors {
          left: parent.left
          right: parent.right
          verticalCenter: parent.verticalCenter
          leftMargin: root.padding
          rightMargin: root.padding
        }

        implicitHeight: childrenRect.height
      }

      // dismiss button
      Item {
        id: closeButton

        anchors {
          top: parent.top
          right: parent.right
          topMargin: 9
          rightMargin: 9
        }

        width: 16
        height: 16

        readonly property bool hovered: root.closable && mouse.containsMouse
          && mouse.mouseX >= x && mouse.mouseX < x + width
          && mouse.mouseY >= y && mouse.mouseY < y + height

        property color strokeColor: hovered ? "#FFFFFF" : "#A9AEB4"

        opacity: root.closable && mouse.containsMouse ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
          NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
          }
        }

        Behavior on strokeColor {
          ColorAnimation {
            duration: 100
          }
        }

        Rectangle {
          anchors.centerIn: parent
          width: 11
          height: 1.5
          radius: height / 2
          rotation: 45
          color: closeButton.strokeColor
        }

        Rectangle {
          anchors.centerIn: parent
          width: 11
          height: 1.5
          radius: height / 2
          rotation: -45
          color: closeButton.strokeColor
        }
      }
    }

    MouseArea {
      id: mouse

      anchors.fill: card
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

      cursorShape: closeButton.hovered || root.clickable
        ? Qt.PointingHandCursor
        : Qt.ArrowCursor

      onClicked: event => {
        if (closeButton.hovered || event.button !== Qt.LeftButton) {
          root.close();
          return;
        }

        root.clicked();
      }
    }
  }

  Timer {
    id: life

    repeat: true
    running: root.timeout > 0 && !root.fading && !root.closing
      && !root.groupHovered && !root.fadeInterrupted && !root.renewing
    interval: root.timeout
    onTriggered: root.fading = true
  }

  NumberAnimation {
    id: fadeIn

    running: true
    target: body
    property: "opacity"
    to: 1
    duration: 200
    easing.type: Easing.OutQuad
  }

  NumberAnimation {
    id: expireFade

    target: body
    property: "opacity"

    from: 1
    to: 0
    duration: 200
    easing.type: Easing.InQuad

    onFinished: {
      root.closing = true;
      root.dismissed();
    }
  }

  NumberAnimation {
    id: closeFade

    target: body
    property: "opacity"
    to: 0
    duration: 160
    easing.type: Easing.InQuad
    onFinished: root.dismissed()
  }
}
