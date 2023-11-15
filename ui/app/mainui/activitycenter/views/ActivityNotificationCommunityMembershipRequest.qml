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
import "../stores"

ActivityNotificationMessage {
    id: root

    contactDetails: notification ? Utils.getContactDetailsAsJson(notification.author, false) : null

    messageDetails.messageText: qsTr("Wants to join")
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
        Layout.maximumWidth: 190
    }

    ctaComponent: MembershipCta {
        membershipStatus: notification && notification.membershipStatus ? notification.membershipStatus : ActivityCenterStore.ActivityCenterMembershipStatus.None
        onAcceptRequestToJoinCommunity: root.store.acceptRequestToJoinCommunity(notification.id, notification.communityId)
        onDeclineRequestToJoinCommunity: root.store.declineRequestToJoinCommunity(notification.id, notification.communityId)
        //TODO: Get backend value. If the membersip is in acceptedPending or declinedPending state, another user can't accept or decline the request
        //Only the user who requested can cancel the request
        //ctaAllowed: true
    }
}
