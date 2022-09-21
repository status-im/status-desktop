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

    signal communityNameClicked()
    signal channelNameClicked()

    badge: notification.message.communityId ? communityBadgeComponent : notification.chatId ? groupChatBadgeComponent : null

    Component {
        id: communityBadgeComponent

        CommunityBadge {
            id: communityBadge

            property string communityId: notification.message.communityId

            textColor: Utils.colorForPubkey(communityId)
            // TODO: wrong result image: Global.getProfileImage(communityId)
            // TODO: wrong result iconColor: Utils.colorForPubkey(communityId)
            communityName: root.store.getSectionNameById(communityId)
            // TODO: no info about channelName

            onCommunityNameClicked: root.communityNameClicked()
            onChannelNameClicked: root.channelNameClicked()
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