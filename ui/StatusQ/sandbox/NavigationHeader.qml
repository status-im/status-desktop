import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    height: 34
    width: 176
    property alias text: label.text

    StatusBaseText {
        anchors.verticalCenter: parent.verticalCenter
        id: label
        font.pixelSize: 15
        color: Theme.palette.baseColor1
    }
}

