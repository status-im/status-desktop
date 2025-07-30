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

    bodyComponent: RowLayout {
        width: parent.width
        height: 50

        StatusSmartIdenticon {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
            Layout.topMargin: 2

            asset {
                width: 24
                height: width
                name: "communities"
                color: root.banned ? "red" : "green"
                bgWidth: 40
                bgHeight: 40
                bgColor: Theme.palette.getColor(asset.color, 0.1)
            }
        }

        StatusBaseText {
            text: root.banned ? qsTr("You were banned from") : qsTr("You've been unbanned from")
            Layout.alignment: Qt.AlignVCenter
            font.italic: true
            color: Theme.palette.baseColor1
        }

        CommunityBadge {
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""
            communityColor: community ? community.color : "black"
            onCommunityNameClicked: root.setActiveCommunity(notification.communityId)
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 190
        }

        Item {
            Layout.fillWidth: true
        }
    }

    ctaComponent: root.banned ? undefined : visitCommunityCta

    Component {
        id: visitCommunityCta
        StatusLinkText {
            text: qsTr("Visit Community")
            onClicked: {
                root.setActiveCommunity(notification.communityId)
                root.closeActivityCenter()
            }
        }
    }
}
