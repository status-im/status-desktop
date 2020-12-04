import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    property string name
    property int chatType
    property string message

    height: statusNotification.height
    width: 416

    StatusNotification {
        id: statusNotification
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        width: parent.width
        name: parent.name
        chatType: parent.chatType
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
