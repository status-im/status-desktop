import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../controls"

ActivityNotificationMessage {
    id: root

    badgeComponent: CommunityBadge {
        id: communityBadge

        property var community: root.store.getCommunityDetailsAsJson(notification.message.communityId)

        communityName: community.name
        communityImage: community.image
        communityColor: community.color

        onCommunityNameClicked: {
            root.store.setActiveCommunity(notification.message.communityId)
        }
        onChannelNameClicked: {
            root.activityCenterClose()
            root.store.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.id)
        }
    }
}