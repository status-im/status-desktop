import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: addEditError
    anchors.left: parent.left
    anchors.right: parent.right

    property alias text: label.text

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
        anchors.leftMargin: Style.current.halfPadding
        font.pixelSize: Style.current.additionalTextSize
        color: Theme.palette.dangerColor1
    }
}
