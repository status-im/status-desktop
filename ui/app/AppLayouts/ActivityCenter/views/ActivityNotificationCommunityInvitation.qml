import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils

import "../controls"

ActivityNotificationMessage {
    id: root

    required property var community

    signal switchToRequested(string sectionId, string chatId, string messageId)
    signal setActiveCommunityRequested(string communityId)

    badgeComponent: CommunityBadge {
        id: communityBadge

        communityName: community ? community.name : ""
        communityImage: community ? community.image : ""
        communityColor: community ? community.color : "black"

        onCommunityNameClicked: {
            root.setActiveCommunityRequested(notification.message.communityId)
            root.closeActivityCenter()
        }
        onChannelNameClicked: {
            root.switchToRequested(notification.sectionId, notification.chatId, notification.message.id)
            root.closeActivityCenter()
        }
    }
}
