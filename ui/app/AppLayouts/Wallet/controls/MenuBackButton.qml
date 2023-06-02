import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusIconTextButton {
    id: root
    implicitHeight: 34
    spacing: 2
    leftPadding: 10
    statusIcon: "tiny/chevron-left"
    icon.width: 18
    icon.height: 18
    font.pixelSize: 13
    text: qsTr("Back")
    background: Rectangle {
        anchors.fill: parent
        color: root.hovered ? Theme.palette.baseColor2 : Theme.palette.statusModal.backgroundColor
    }
}
