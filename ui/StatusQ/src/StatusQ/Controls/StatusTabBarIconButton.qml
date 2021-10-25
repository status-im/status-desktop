import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
        name: ""
    }

    property bool highlighted: false
    property bool enabled: true

    signal clicked(var mouse)

    implicitWidth: 40
    implicitHeight: 40

    MouseArea {
        id: sensor
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        anchors.fill: parent
        hoverEnabled: true
        onClicked: function (mouse) {
            root.clicked(mouse)
        }

        StatusIcon {
            id: statusIcon
            width: root.icon.width
            height: root.icon.height
            icon: root.icon.name
            color: root.highlighted || sensor.containsMouse ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            anchors.centerIn: parent
        }

        Rectangle {
            visible: root.highlighted || sensor.containsMouse
            width: statusIcon.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 2
            radius: 1
            color: Theme.palette.primaryColor1
            anchors.bottom: parent.bottom
        }
    }
}

