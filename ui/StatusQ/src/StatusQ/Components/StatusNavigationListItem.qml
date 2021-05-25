import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

StatusListItem {
    id: statusNavigationListItem

    signal clicked(var mouse)
    property bool selected: false
    property alias badge: statusBadge

    implicitWidth: 286
    implicitHeight: 48

    icon.background.width: 20
    icon.background.height: 20
    icon.background.color: "transparent"


    color: {
        if (selected) {
            return Theme.palette.statusNavigationListItem.selectedBackgroundColor
        }
        return sensor.containsMouse ? 
          Theme.palette.statusNavigationListItem.hoverBackgroundColor :
          Theme.palette.baseColor4
    }

    MouseArea {
        id: sensor
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor 
        hoverEnabled: true
        onClicked: statusNavigationListitem.clicked(mouse)
    }

    components: [
        StatusBadge {
            id: statusBadge
            visible: value > 0
        }
    ]
}
