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

    required property var community
    required property var channel

    signal setActiveCommunity(string communityId)
    signal switchToRequested(string sectionId, string chatId, string messageId)

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

            communityName: community.name
            communityImage: community.image
            communityColor: community.color
            channelName: channel.name

            onCommunityNameClicked: {
                root.setActiveCommunity(notification.message.communityId)
                root.closeActivityCenter()
            }
            onChannelNameClicked: {
                root.switchToRequested(notification.sectionId, notification.chatId, notification.message.id)
                root.closeActivityCenter()
            }
        }
    }

    Component {
        id: groupChatBadgeComponent

        ChannelBadge {
            property var group: root.channel

            chatType: notification.chatType
            name: group.name
            asset.isImage: asset.name != ""
            asset.name: group.icon
            asset.emoji: group.emoji
            asset.color: group.color

            onChannelNameClicked: {
                root.switchToRequested(notification.sectionId, notification.chatId, notification.message.id)
                root.closeActivityCenter()
            }
        }
    }

    onMessageClicked: {
        root.switchToRequested(notification.sectionId, notification.chatId, notification.message.id)
        root.closeActivityCenter()
    }
}
