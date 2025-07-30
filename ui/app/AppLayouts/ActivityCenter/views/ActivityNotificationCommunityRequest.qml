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
import "../stores"

ActivityNotificationBase {
    id: root

    required property var community

    signal setActiveCommunity(string communityId)

    bodyComponent: RowLayout {
        width: parent.width
        height: 50

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
            onCommunityNameClicked: root.setActiveCommunity(notification.communityId)
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
                root.setActiveCommunity(notification.communityId)
                root.closeActivityCenter()
            }
        }
    }
}
