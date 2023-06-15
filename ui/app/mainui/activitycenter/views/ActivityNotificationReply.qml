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

    function badgeTextFromRepliedMessageContent(message) {
        switch (message.contentType) {
        case Constants.messageContentType.stickerType:
            return qsTr("sticker")
        case Constants.messageContentType.emojiType:
            return qsTr("emoji")
        case Constants.messageContentType.transactionType:
            return qsTr("transaction")
        case Constants.messageContentType.imageType:
            return qsTr("image")
        case Constants.messageContentType.audioType:
            return qsTr("audio")
        default:
            return message.messageText
        }
    }

    badgeComponent: ReplyBadge {
        repliedMessageContent: notification ? badgeTextFromRepliedMessageContent(notification.repliedMessage) : ""
        onReplyClicked: {
            root.activityCenterStore.switchTo(notification)
            root.closeActivityCenter()
            root.store.messageStore.messageModule.jumpToMessage(model.id)
        }
    }

    onMessageClicked: {
        root.activityCenterStore.switchTo(notification)
        root.closeActivityCenter()
    }
}
