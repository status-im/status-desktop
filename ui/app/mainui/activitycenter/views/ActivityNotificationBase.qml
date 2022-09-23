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

    property alias bodyComponent: bodyLoader.sourceComponent
    property alias badgeComponent: badgeLoader.sourceComponent
    property alias actionComponent: actionLoader.sourceComponent
    property alias action: actionLoader

    height: Math.max(50, bodyLoader.height + (badgeLoader.item ? badgeLoader.height : 0))

    Loader {
        id: bodyLoader
        anchors.top: parent.top
        anchors.right: actionLoader.left
        anchors.left: parent.left
    }

    Loader {
        id: badgeLoader
        anchors.top: bodyLoader.bottom
        anchors.left: parent.left
        anchors.leftMargin: 61 // TODO find a way to align with the text of the message
    }

    Loader {
        id: actionLoader
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding

        sourceComponent: StatusFlatRoundButton {
            id: markReadBtn
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
                        notification.id, notification.message.communityId,
                        notification.message.chatId, notification.notificationType) :
                    root.store.activityCenterModuleInst.markActivityCenterNotificationRead(
                        notification.id, notification.message.communityId,
                        notification.chatId, notification.notificationType)
            }
        }
    }
}