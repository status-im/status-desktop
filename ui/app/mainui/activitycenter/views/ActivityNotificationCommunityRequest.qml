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
import "../stores"

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
            asset.color: community ? community.color : "black"
            asset.name: community ? community.image : ""
            asset.width: 40
            asset.height: 40
            asset.letterSize: width / 2.4
            asset.isImage: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Theme.padding
        }

        StatusBaseText {
            text: qsTr("Request to join")
            color: Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: Theme.additionalTextSize
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

        StatusBaseText {
            text: {
                if (!notification)
                    return ""
                if (notification.membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Pending)
                    return qsTr("pending")
                if (notification.membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Accepted)
                    return qsTr("accepted")
                if (notification.membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Declined)
                    return qsTr("declined")
                return ""
            }
            color: Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: Theme.additionalTextSize
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }

    ctaComponent: notification && notification.membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Accepted ?
                        visitComponent : null

    Component {
        id: visitComponent

        StyledTextEdit {
            text: Utils.getLinkStyle(qsTr("Visit Community"), hoveredLink, Theme.palette.primaryColor1)
            readOnly: true
            textFormat: Text.RichText
            color: Theme.palette.primaryColor1
            font.pixelSize: Theme.additionalTextSize
            onLinkActivated: {
                root.store.setActiveCommunity(notification.communityId)
                root.closeActivityCenter()
            }
        }
    }
}
