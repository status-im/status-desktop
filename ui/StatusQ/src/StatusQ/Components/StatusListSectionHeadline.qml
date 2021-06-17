import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    implicitHeight: 34
    implicitWidth: 176

    property alias text: label.text

    StatusBaseText {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.leftMargin: 16
        id: label
        font.pixelSize: 15
        color: Theme.palette.baseColor1
    }
}
