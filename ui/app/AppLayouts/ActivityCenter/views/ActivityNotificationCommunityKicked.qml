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

    required property var community

    signal setActiveCommunity(string communityId)

    avatarComponent: StatusSmartIdenticon {
        name: community ? community.name : ""
        asset.name: community ? community.image : ""
        asset.color: community ? community.color : "black"
        asset.width: 40
        asset.height: 40
        asset.letterSize: width / 2.4
        asset.isImage: true
    }

    bodyComponent: ColumnLayout {
        spacing: Theme.halfPadding
        width: parent.width
        clip: true

        CommunityBadge {
            Layout.maximumWidth: parent.width
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""
            communityColor: community ? community.color : "black"
            communityLinkTextColor: Theme.palette.directColor1
            communityLinkTextPixelSize: Theme.additionalTextSize
            communityLinkTextWeight: Font.Medium
            onCommunityNameClicked: root.setActiveCommunity(notification.communityId)
        }

        StatusBaseText {
            text: qsTr("You were <font color='%1'>kicked</font> from community").arg(Theme.palette.dangerColor1)
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            font.pixelSize: Theme.additionalTextSize
        }
    }
}
