import QtQuick
import Qt5Compat.GraphicalEffects

import StatusQ.Platform

Item {
    property string name
    property string message

    height: statusNotification.height

    implicitWidth: statusNotification.implicitWidth
    implicitHeight: statusNotification.implicitHeight

    StatusMacNotification {
        id: statusNotification

        width: parent.width
        name: parent.name
        message: parent.message
    }

    DropShadow {
        anchors.fill: statusNotification
        horizontalOffset: 0
        verticalOffset: 2
        radius: 10
        samples: 12
        color: "#22000000"
        source: statusNotification
    }
}
