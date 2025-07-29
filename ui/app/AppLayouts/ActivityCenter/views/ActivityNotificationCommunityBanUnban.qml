import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import shared
import shared.panels
import shared.controls
import utils

import "../controls"

ActivityNotificationBase {
    id: root

    property bool banned: true

    required property var community

    signal setActiveCommunity(string communityId)

    QtObject {
        id: d

        property color stateTextColor: root.banned ? Theme.palette.dangerColor1 :
                                                     Theme.palette.successColor1
    }

    avatarComponent: StatusSmartIdenticon {
        name: community ? community.name : ""
        asset.color: community ? community.color : "black"
        asset.name: community ? community.image : ""
        asset.width: 40
        asset.height: 40
        asset.letterSize: width / 2.4
        asset.isImage: true
    }

    bodyComponent: ColumnLayout {
        width: parent.width
        spacing: Theme.halfPadding

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
            Layout.maximumWidth: parent.width
            text: root.banned ? qsTr("You were <font color='%1'>banned</font> from community").arg(d.stateTextColor) :
                                qsTr("You have been  <font color='%1'>unbanned</font> from community").arg(d.stateTextColor)
            color: Theme.palette.directColor1
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            font.pixelSize: Theme.additionalTextSize
        }
    }
}
