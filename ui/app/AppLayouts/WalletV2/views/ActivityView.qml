import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root
    StatusBaseText {
        anchors.centerIn: parent
        color: Theme.palette.baseColor1
        text: qsTr("Activity will appear here")
        font.pixelSize: 15
    }
}
