import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

StatusListItem {
    id: statusNavigationListItem

    property bool selected: false
    property alias badge: statusBadge

    implicitWidth: 286
    implicitHeight: 48

    asset.bgWidth: 24
    asset.bgHeight: 24
    asset.width: 24
    asset.height: 24
    asset.bgColor: "transparent"

    statusListItemIcon.anchors.topMargin: 14

    color: {
        if (selected) {
            return Theme.palette.statusNavigationListItem.selectedBackgroundColor
        }
        return highlighted || sensor.containsMouse ?
          Theme.palette.statusNavigationListItem.hoverBackgroundColor :
          Theme.palette.baseColor4
    }

    components: [
        StatusBadge {
            id: statusBadge
            visible: value > 0
        }
    ]
}
