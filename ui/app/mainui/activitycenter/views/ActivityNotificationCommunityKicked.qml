import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import utils 1.0

import "../controls"

ActivityNotificationBase {
    id: root

    bodyComponent: RowLayout {
        height: 50
        readonly property var community: root.store.getCommunityDetailsAsJson(notification.communityId)

        StatusSmartIdenticon {
            id: identicon
            name: community.name
            asset.width: 40
            asset.height: 40
            asset.color: community.color
            asset.letterSize: width / 2.4
            asset.name: community.image
            asset.isImage: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Style.current.padding
        }

        StatusBaseText {
            text: qsTr("You were kicked from")
            font.pixelSize: 15
            Layout.alignment: Qt.AlignVCenter
        }

        CommunityBadge {
            communityName: community.name
            communityImage: community.image
            communityColor: community.color
            onCommunityNameClicked: root.store.setActiveCommunity(notification.communityId)
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }
    }
}