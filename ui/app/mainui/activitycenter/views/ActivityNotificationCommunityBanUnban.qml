import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import utils 1.0

import "../controls"

ActivityNotificationBase {
    id: root
    property bool banned: true

    bodyComponent: RowLayout {
        width: parent.width
        height: 50
        readonly property var community: notification ?
                                root.store.getCommunityDetailsAsJson(notification.communityId) :
                                null

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
            onCommunityNameClicked: root.store.setActiveCommunity(notification.communityId)
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
                root.store.setActiveCommunity(notification.communityId)
                root.closeActivityCenter()
            }
        }
    }
}
