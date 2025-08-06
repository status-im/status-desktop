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
