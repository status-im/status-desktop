import QtQuick 2.15
import QtQuick.Layouts 1.15

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
