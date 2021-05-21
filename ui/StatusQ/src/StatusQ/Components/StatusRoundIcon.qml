import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: statusRoundedIcon

    implicitWidth: 40
    implicitHeight: 40
    radius: width / 2;

    color: Theme.palette.primaryColor3;
    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
    }

    StatusIcon {
        id: statusIcon
        anchors.centerIn: parent

        width: statusRoundedIcon.icon.width
        height: statusRoundedIcon.icon.height

        color: Theme.palette.primaryColor1
        icon: statusRoundedIcon.icon.name
    }
}
