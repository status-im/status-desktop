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

    badgeComponent: {
        if (!notification)
            return null

        switch (notification.chatType)
        {
        case Constants.chatType.communityChat:
            return communityBadgeComponent
        case Constants.chatType.privateGroupChat:
            return groupChatBadgeComponent
        default:
            return null
        }
    }

    Component {
        id: communityBadgeComponent

        CommunityBadge {
            id: communityBadge

            property var community: root.store.getCommunityDetailsAsJson(notification.message.communityId)
            property var channel: root.store.getChatDetails(notification.chatId)

            communityName: community.name
            communityImage: community.image
            communityColor: community.color
            channelName: channel.name

            onCommunityNameClicked: {
                root.store.setActiveCommunity(notification.message.communityId)
                root.closeActivityCenter()
            }
            onChannelNameClicked: {
                root.activityCenterStore.switchTo(notification)
                root.closeActivityCenter()
            }
        }
    }

    Component {
        id: groupChatBadgeComponent

        ChannelBadge {
            property var group: root.store.getChatDetails(notification.chatId)

            chatType: notification.chatType
            name: group.name
            asset.isImage: asset.name != ""
            asset.name: group.icon
            asset.emoji: group.emoji
            asset.color: group.color

            onChannelNameClicked: {
                root.activityCenterStore.switchTo(notification)
                root.closeActivityCenter()
            }
        }
    }

    onMessageClicked: {
        root.activityCenterStore.switchTo(notification)
        root.closeActivityCenter()
    }
}
