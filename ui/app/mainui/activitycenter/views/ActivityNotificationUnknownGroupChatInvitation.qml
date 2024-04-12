import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../controls"
import "../panels"
import "../stores"

ActivityNotificationMessage {
    id: root

    messageDetails.messageText: qsTr("Invitation to an unknown group")

    badgeComponent: ChannelBadge {
        property var group: root.store.getChatDetails(notification.chatId)

        chatType: notification.chatType
        name: notification.name
        asset.isImage: asset.name != ""
        asset.name: group.icon
        asset.emoji: group.emoji
        asset.color: group.color
    }

    ctaComponent: MembershipCta {
        membershipStatus: if (notification.accepted)
                              return ActivityCenterStore.ActivityCenterMembershipStatus.Accepted
                          else if (notification.dismissed)
                              return ActivityCenterStore.ActivityCenterMembershipStatus.Declined
                          else
                              return ActivityCenterStore.ActivityCenterMembershipStatus.Pending

        onAcceptRequestToJoinCommunity: activityCenterStore.acceptActivityCenterNotification(notification)
        onDeclineRequestToJoinCommunity: activityCenterStore.dismissActivityCenterNotification(notification)
    }
}
