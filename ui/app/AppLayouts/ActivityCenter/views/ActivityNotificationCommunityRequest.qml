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
import AppLayouts.ActivityCenter.helpers

ActivityNotificationBase {
    id: root

    required property var community

    signal setActiveCommunityRequested(string notificationId, string communityId)

    QtObject {
        id: d

        property color stateTextColor: Theme.palette.directColor1
        property string stateText: ""
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
            onCommunityNameClicked: root.setActiveCommunityRequested(notification.id, notification.communityId)
        }

        StatusBaseText {
            text: qsTr("Request to join <font color='%1'>%2</font>").arg(d.stateTextColor).arg(d.stateText)
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
    }

    states: [
        State {
            when: notification.membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.Pending
            PropertyChanges {
                target: d
                stateText: qsTr("pending")
                stateTextColor: Theme.palette.baseColor1
            }
        },
        State {
            when: notification.membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.Accepted
            PropertyChanges {
                target: d
                stateText: qsTr("accepted")
                stateTextColor: Theme.palette.successColor1
            }
        },
        State {
            when: notification.membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.Declined
            PropertyChanges {
                target: d
                stateText: qsTr("declined")
                stateTextColor: Theme.palette.dangerColor1
            }
        }
    ]
}
