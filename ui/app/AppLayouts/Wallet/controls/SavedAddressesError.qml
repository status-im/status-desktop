import QtQuick 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property alias text: label.text

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    StatusIcon {
        id: errorIcon
        icon: "warning"
        color: Theme.palette.dangerColor1
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
    }

    StatusBaseText {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: errorIcon.right
        anchors.leftMargin: Theme.halfPadding
        font.pixelSize: Theme.additionalTextSize
        color: Theme.palette.dangerColor1
    }
}
