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

ActivityNotificationMessage {
    id: root

    readonly property var contactDetails: Utils.getContactDetailsAsJson(notification.author)

    messageDetails.messageText: qsTr("Wants to join")
    messageDetails.sender.displayName: contactDetails.displayName
    messageDetails.sender.secondaryName: contactDetails.localNickname
    messageDetails.sender.profileImage.name: contactDetails.displayIcon
    messageDetails.sender.profileImage.assetSettings.isImage: true
    messageDetails.sender.profileImage.pubkey: notification.author
    messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(notification.author)
    messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(notification.author, false, true)

    messageBadgeComponent: CommunityBadge {
        readonly property var community: root.store.getCommunityDetailsAsJson(notification.communityId)

        communityName: community.name
        communityImage: community.image
        communityColor: community.color

        onCommunityNameClicked: {
            root.store.setActiveCommunity(notification.communityId)
            root.closeActivityCenter()
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