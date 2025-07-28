import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import shared.controls
import utils

import "../controls"

ActivityNotificationBase {
    id: root

    bodyComponent: RowLayout {
        width: parent.width
        height: 50
        readonly property var community: notification ?
                                root.store.getCommunityDetailsAsJson(notification.communityId) :
                                null

        StatusSmartIdenticon {
            id: identicon
            name: community ? community.name : ""
            asset.name: community ? community.image : ""
            asset.color: community ? community.color : "black"
            asset.width: 40
            asset.height: 40
            asset.letterSize: width / 2.4
            asset.isImage: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Theme.padding
        }

        StatusBaseText {
            text: qsTr("You were kicked from")
            font.pixelSize: Theme.primaryTextFontSize
            Layout.alignment: Qt.AlignVCenter
        }

        CommunityBadge {
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""
            communityColor: community ? community.color : "black"
            onCommunityNameClicked: root.store.setActiveCommunity(notification.communityId)
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 190
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
