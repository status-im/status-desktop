import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import utils 1.0

Item {
    id: root

    property var notification
    property var store

    property alias markReadBtnVisible: markReadBtn.visible

    width: listView.availableWidth
    height: 50

    StatusFlatRoundButton {
        id: markReadBtn
        width: 32
        height: 32
        icon.width: 24
        icon.height: 24
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        icon.source: Style.svg("check-activity")
        icon.color: notification.read ? icon.disabledColor : "transparent"
        color: "transparent"
        tooltip.text: !notification.read ? qsTr("Mark as Read") : qsTr("Mark as Unread")
        tooltip.orientation: StatusToolTip.Orientation.Left
        tooltip.x: -tooltip.width - Style.current.padding
        tooltip.y: 4
        onClicked: {
            notification.read ?
                root.store.activityCenterModuleInst.markActivityCenterNotificationUnread(
                    notification.id, notification.message.communityId, notification.message.chatId, notification.notificationType) :
                root.store.activityCenterModuleInst.markActivityCenterNotificationRead(
                    notification.id, notification.message.communityId, notification.chatId, notification.notificationType)
        }
    }
}