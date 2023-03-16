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
            Layout.leftMargin: Style.current.padding
        }

        StatusBaseText {
            text: qsTr("Request to join")
            color: Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }

        CommunityBadge {
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""
            communityColor: community ? community.color : "black"
            onCommunityNameClicked: root.store.setActiveCommunity(notification.communityId)
            Layout.alignment: Qt.AlignVCenter
        }

        StatusBaseText {
            text: {
                if (!notification)
                    return ""
                if (notification.membershipStatus === Constants.activityCenterMembershipStatusPending)
                    return qsTr("pending")
                if (notification.membershipStatus === Constants.activityCenterMembershipStatusAccepted)
                    return qsTr("accepted")
                if (notification.membershipStatus === Constants.activityCenterMembershipStatusDeclined)
                    return qsTr("declined")
                return ""
            }
            color: Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }

    ctaComponent: notification && notification.membershipStatus === Constants.activityCenterMembershipStatusAccepted ?
                        visitComponent : null

    Component {
        id: visitComponent

        StyledTextEdit {
            text: Utils.getLinkStyle(qsTr("Visit Community"), hoveredLink, Style.current.blue)
            readOnly: true
            textFormat: Text.RichText
            color: Style.current.blue
            font.pixelSize: 13
            onLinkActivated: {
                root.store.setActiveCommunity(notification.communityId)
                root.closeActivityCenter()
            }
        }
    }
}