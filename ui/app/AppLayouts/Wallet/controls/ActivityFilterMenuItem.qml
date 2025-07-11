import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups

StatusMenuItem {
    arrow: StatusIcon {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        icon: "next"
        color: Theme.palette.directColor1
    }
}
