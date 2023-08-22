import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root

    text: qsTr("Requirements check pending...")

    color: Theme.palette.dangerColor1

    SequentialAnimation {
        id: blinkingAnimation

        loops: Animation.Infinite
        running: root.visible
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 1500;}
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 1500;}
    }
}
