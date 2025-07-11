import QtQuick
import StatusQ.Core
import StatusQ.Core.Theme

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
        bgRadius: bgWidth / 2
    }

    color: asset.bgColor
    implicitWidth: asset.bgWidth
    implicitHeight: asset.bgHeight
    radius: asset.bgRadius
    border.width: asset.bgBorderWidth
    border.color: asset.bgBorderColor

    StatusIcon {
        id: statusIcon
        anchors.centerIn: parent

        width: statusRoundedIcon.asset.width
        height: statusRoundedIcon.asset.height

        color: statusRoundedIcon.asset.color
        icon: statusRoundedIcon.asset.name || statusRoundedIcon.asset.source
        rotation: statusRoundedIcon.asset.rotation
    }
}
