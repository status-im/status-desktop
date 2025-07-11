import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

StatusFlatRoundButton {
    id: control
    property bool selected: false
    icon.name: "filled-account"
    icon.width: 36
    icon.height: 36
    Rectangle {
        anchors.fill: parent
        color: control.hovered ? control.icon.color : "transparent"
        opacity: 0.1
        radius: 8
    }

    Rectangle {
        width: 16
        height: 16
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        visible: control.selected
        radius: width / 2
        color: Theme.palette.successColor1
        StatusIcon {
            icon: "tiny/checkmark"
            height: 12
            color: Theme.palette.white
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}


