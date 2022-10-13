import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0
import shared.views.chat 1.0

import "../controls"
import "../panels"

ActivityNotificationBase {
    id: root

    property var messageContextMenu
    property int previousNotificationIndex

    readonly property string previousNotificationTimestamp: previousNotificationIndex == 0 ?
                                                                "" : root.store.activityCenterList.getNotificationData(
                                                                        previousNotificationIndex, "timestamp")

    signal activityCenterClose()

    bodyComponent: MessageView {
        readonly property var contactDetails: Utils.getContactDetailsAsJson(senderId)

        rootStore: root.store
        messageStore: root.store.messageStore
        messageId: notification.id
        messageText: qsTr("Wants to join")
        messageTimestamp: notification.timestamp
        senderId: notification.author
        senderIcon: contactDetails.displayIcon
        senderDisplayName: contactDetails.name

        activityCenterMessage: true
        activityCenterMessageRead: false
        scrollToBottom: null
        prevMessageIndex: root.previousNotificationIndex
        prevMsgTimestamp: root.previousNotificationTimestamp
        onImageClicked: Global.openImagePopup(image, root.messageContextMenu)
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
                return Global.openProfilePopup(notification.author)
            }

            root.activityCenterClose()
            root.store.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.id)
        }

        CommunityBadge {
            readonly property var community: root.store.getCommunityDetailsAsJson(notification.communityId)

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 160 // TODO: get right text margin
            communityName: community.name
            communityImage: community.image
            communityColor: community.color

            onCommunityNameClicked: root.store.setActiveCommunity(notification.communityId)
        }
    }

    ctaComponent: MembershipCta {
        pending: notification.membershipStatus === Constants.activityCenterMembershipStatusPending
        accepted: notification.membershipStatus === Constants.activityCenterMembershipStatusAccepted
        declined: notification.membershipStatus === Constants.activityCenterMembershipStatusDeclined
        onAcceptRequestToJoinCommunity: {
            root.store.setActiveCommunity(message.communityId)
            root.store.acceptRequestToJoinCommunity(notification.id)
        }
        onDeclineRequestToJoinCommunity: {
            root.store.setActiveCommunity(message.communityId)
            root.store.declineRequestToJoinCommunity(notification.id)
        }
    }
}