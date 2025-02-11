import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Components.private 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property int borderWidth: 2
    height: innerCircle.height + borderWidth
    width: innerCircle.width + borderWidth

    color: Theme.palette.baseColor2
    radius: height/2

    Rectangle {
        id: innerCircle

        anchors.centerIn: parent
        height: 10
        width: 10

        StatusGradient {
          id: gradient

          anchors.fill: parent
          source: parent
        }

        radius: height/2
    }
}

