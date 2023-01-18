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

    readonly property var contactDetails: notification ?
                                            Utils.getContactDetailsAsJson(notification.author, false) :
                                            null

    messageDetails.messageText: qsTr("Wants to join")
    messageDetails.sender.displayName: contactDetails ? contactDetails.displayName : ""
    messageDetails.sender.secondaryName: contactDetails ? contactDetails.localNickname : ""
    messageDetails.sender.profileImage.name: contactDetails ? contactDetails.displayIcon : ""
    messageDetails.sender.profileImage.assetSettings.isImage: true
    messageDetails.sender.profileImage.pubkey: notification ? notification.author : ""
    messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(notification ? notification.author : "")
    messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(notification ? notification.author : "", contactDetails && contactDetails.ensVerified)

    messageBadgeComponent: CommunityBadge {
        readonly property var community: notification ?
                            root.store.getCommunityDetailsAsJson(notification.communityId) :
                            null

        communityName: community ? community.name : ""
        communityImage: community ? community.image : ""
        communityColor: community ? community.color : "black"

        onCommunityNameClicked: {
            root.store.setActiveCommunity(notification.communityId)
            root.closeActivityCenter()
        }
    }

    ctaComponent: MembershipCta {
        pending: notification && notification.membershipStatus === Constants.activityCenterMembershipStatusPending
        accepted: notification && notification.membershipStatus === Constants.activityCenterMembershipStatusAccepted
        declined: notification && notification.membershipStatus === Constants.activityCenterMembershipStatusDeclined
        onAcceptRequestToJoinCommunity: root.store.acceptRequestToJoinCommunity(notification.id, notification.communityId)
        onDeclineRequestToJoinCommunity: root.store.declineRequestToJoinCommunity(notification.id, notification.communityId)
    }
}
