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

    signal activityCenterClose()

    bodyComponent: MessageView {
        readonly property var contactDetails: Utils.getContactDetailsAsJson(notification.author)

        rootStore: root.store
        messageStore: root.store.messageStore
        messageId: notification.id
        messageText: qsTr("Wants to join")
        messageTimestamp: notification.timestamp
        senderId: notification.author
        senderIcon: contactDetails.displayIcon
        senderDisplayName: contactDetails.displayName
        senderOptionalName: contactDetails.localNickname
        messageContextMenu: root.messageContextMenu
        activityCenterMessage: true
        activityCenterMessageRead: false
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

            root.activityCenterStore.switchTo(notification)
            root.activityCenterClose()
        }

        CommunityBadge {
            readonly property var community: root.store.getCommunityDetailsAsJson(notification.communityId)

            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 15
            anchors.left: parent.left
            anchors.leftMargin: 160 // TODO: get right text margin
            communityName: community.name
            communityImage: community.image
            communityColor: community.color

            onCommunityNameClicked: {
                root.store.setActiveCommunity(notification.communityId)
                root.activityCenterClose()
            }
        }
    }

    ctaComponent: MembershipCta {
        pending: notification.membershipStatus === Constants.activityCenterMembershipStatusPending
        accepted: notification.membershipStatus === Constants.activityCenterMembershipStatusAccepted
        declined: notification.membershipStatus === Constants.activityCenterMembershipStatusDeclined
        onAcceptRequestToJoinCommunity: root.store.acceptRequestToJoinCommunity(notification.id, notification.communityId)
        onDeclineRequestToJoinCommunity: root.store.declineRequestToJoinCommunity(notification.id, notification.communityId)
    }
}