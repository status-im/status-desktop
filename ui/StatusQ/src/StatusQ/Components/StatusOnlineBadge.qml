import QtQuick 2.15
import StatusQ.Core.Theme 0.1

StatusBadge {
    id: root

    property bool online: false

    implicitHeight: 11
    implicitWidth: 11
    color: online ? Theme.palette.successColor1 : Theme.palette.baseColor1
    border.width: 2
    border.color: Theme.palette.baseColor4
    radius: Math.ceil(width / 2)
}
