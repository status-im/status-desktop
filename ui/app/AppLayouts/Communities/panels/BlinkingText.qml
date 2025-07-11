import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

StatusBaseText {
    id: root

    color: Theme.palette.dangerColor1

    SequentialAnimation {
        id: blinkingAnimation

        loops: Animation.Infinite
        running: root.visible
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 1500;}
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 1500;}
    }
}
