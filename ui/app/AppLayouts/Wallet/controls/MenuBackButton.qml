import QtQuick
import QtQuick.Controls

import StatusQ.Controls
import StatusQ.Core.Theme

StatusIconTextButton {
    id: root
    implicitHeight: 34
    spacing: 2
    leftPadding: 10
    statusIcon: "tiny/chevron-left"
    icon.width: 18
    icon.height: 18
    font.pixelSize: Theme.additionalTextSize
    text: qsTr("Back")
    background: Rectangle {
        anchors.fill: parent
        color: root.hovered ? Theme.palette.baseColor2 : Theme.palette.statusModal.backgroundColor
    }
}
