import QtQuick 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Components.private 0.1

Rectangle {
    implicitWidth: 12
    implicitHeight: 12
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.rightMargin: -border.width*2
    anchors.topMargin: -border.width*2
    border.width: 2
    border.color: Theme.palette.statusBadge.borderColor
    radius: height/2
    gradient: StatusNewItemGradient {}
}
