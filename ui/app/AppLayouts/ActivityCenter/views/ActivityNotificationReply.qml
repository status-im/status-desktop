import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import utils

import "../controls"

ActivityNotificationMessage {
    id: root

    signal switchToRequested(string sectionId, string chatId, string messageId)
    signal jumpToMessageRequested(string messageId)

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
            root.switchToRequested(notification.sectionId, notification.chatId, notification.message.id)
            root.closeActivityCenter()
            root.jumpToMessageRequested(model.id)
        }
    }

    onMessageClicked: {
        root.switchToRequested(notification.sectionId, notification.chatId, notification.message.id)
        root.closeActivityCenter()
    }
}
