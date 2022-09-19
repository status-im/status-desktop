import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import utils 1.0
import shared.views.chat 1.0

ActivityNotificationBase {
    id: root

    property var messageContextMenu

    signal activityCenterClose()

    height: Math.max(60, notificationMessage.height)

    MessageView {
        id: notificationMessage
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: -1

        rootStore: root.store
        messageStore: root.store.messageStore
        messageContextMenu: root.messageContextMenu

        messageId: notification.id
        senderDisplayName: notification.message.senderDisplayName
        messageText: notification.message.messageText
        responseToMessageWithId: notification.message.responseToMessageWithId
        senderId: notification.message.senderId
        senderOptionalName: notification.message.senderOptionalName
        senderIcon: notification.message.senderIcon
        amISender: notification.message.amISender
        messageImage: notification.message.messageImage
        messageTimestamp: notification.timestamp
        messageOutgoingStatus: notification.message.outgoingStatus
        messageContentType: notification.message.contentType
        senderTrustStatus: notification.message.senderTrustStatus
        activityCenterMessage: true
        activityCenterMessageRead: false
        onImageClicked: Global.openImagePopup(image, root.messageContextMenu)
        scrollToBottom: null
        messageClickHandler: (sender, 
                              point,
                              isProfileClick,
                              isSticker = false,
                              isImage = false,
                              image = null,
                              isEmoji = false,
                              ideEmojiPicker = false,
                              isReply = false,
                              isRightClickOnImage = false,
                              imageSource = "") => {
            if (isProfileClick) {
                return Global.openProfilePopup(notification.message.senderId)
            }

            activityCenterClose()
            root.store.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.id)
        }
    }
}