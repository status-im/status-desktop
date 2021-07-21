import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

MenuSeparator {
    id: root
    property string text
    height: visible && enabled ? implicitHeight : 0
    contentItem: Item {
        implicitWidth: 176
        implicitHeight: 16
        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            color: Theme.palette.baseColor1
            font.pixelSize: 12
            text: root.text
        }
    }
}

