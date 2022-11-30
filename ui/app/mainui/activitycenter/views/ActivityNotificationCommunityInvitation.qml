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

        readonly property var community: notification ?
                                    root.store.getCommunityDetailsAsJson(notification.message.communityId) :
                                    null

        communityName: community ? community.name : ""
        communityImage: community ? community.image : ""
        communityColor: community ? community.color : "black"

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