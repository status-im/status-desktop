import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: statusRoundedIcon

    property StatusAssetSettings asset: StatusAssetSettings {
        width: 24
        height: 24
        rotation: 0
        color: Theme.palette.primaryColor1
        bgWidth: 40
        bgHeight: 40
        bgColor: Theme.palette.primaryColor3
    }

    color: asset.bgColor
    implicitWidth: asset.bgWidth
    implicitHeight: asset.bgHeight
    radius: asset.bgWidth / 2


    StatusIcon {
        id: statusIcon
        anchors.centerIn: parent

        width: statusRoundedIcon.asset.width
        height: statusRoundedIcon.asset.height

        color: statusRoundedIcon.asset.color
        icon: statusRoundedIcon.asset.name
        rotation: statusRoundedIcon.asset.rotation
    }
}
