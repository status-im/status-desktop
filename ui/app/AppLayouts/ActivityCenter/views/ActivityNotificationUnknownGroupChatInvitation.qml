import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils

import "../controls"
import "../panels"
import "../stores"

ActivityNotificationMessage {
    id: root

    signal acceptActivityCenterNotificationRequested(string notificationId)
    signal dismissActivityCenterNotificationRequested(string notificationId)

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

        onAcceptRequestToJoinCommunity: root.acceptActivityCenterNotificationRequested(notification.id)
        onDeclineRequestToJoinCommunity: root.dismissActivityCenterNotificationRequestedstring(notification.id)
    }
}
