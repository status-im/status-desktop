import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import utils 1.0

import "../controls"

ActivityNotificationMessage {
    id: root

    badgeComponent: ReplyBadge {
        repliedMessageContent: notification.repliedMessage.messageText
        onReplyClicked: {
            root.activityCenterStore.switchTo(notification)
            root.closeActivityCenter()
        }
    }
}