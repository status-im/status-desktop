import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import utils 1.0
import shared.panels.chat 1.0

import "../controls"

ActivityNotificationMessage {
    id: root

    badge: notification.message.communityId ? communityBadgeComponent : notification.chatId ? groupChatBadgeComponent : null

    Component {
        id: communityBadgeComponent

        CommunityBadge {
            id: communityBadge

            property var community: root.store.getCommunityDetailsAsJson(notification.message.communityId)
            // TODO: here i need chanel
            // property var channel: root.store.chatSectionModule.getItemAsJson(notification.chatId)

            communityName: community.name
            communityImage: community.image
            communityColor: community.color

            // channelName: channel.name

            onCommunityNameClicked: {
                root.store.setActiveCommunity(notification.message.communityId)
            }
            onChannelNameClicked: {
                root.activityCenterClose()
                root.store.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.id)
            }
        }
    }

    Component {
        id: groupChatBadgeComponent

        ChannelBadge {
            realChatType: root.realChatType
            textColor: Utils.colorForPubkey(notification.message.senderId)
            name: root.name
            profileImage: Global.getProfileImage(notification.message.chatId)
        }
    }
}