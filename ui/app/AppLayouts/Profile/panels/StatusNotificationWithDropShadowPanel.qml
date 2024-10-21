import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ.Platform 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Item {
    property string name
    property int chatType
    property string message

    height: statusNotification.height
    width: 416

    StatusMacNotification {
        id: statusNotification
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
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
