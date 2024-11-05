import QtQuick 2.15

import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property double dotsDiameter
    property int duration
    property double maxOpacity
    property color dotsColor

    width: root.dotsDiameter
    height: width
    radius: width / 2
    color: root.dotsColor

    SequentialAnimation {
        id: blinkingAnimation

        loops: Animation.Infinite
        running: visible
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: root.duration }
        NumberAnimation { target: root; property: "opacity"; to: root.maxOpacity; duration: root.duration }
    }

    Component.onCompleted: blinkingAnimation.start()
}
