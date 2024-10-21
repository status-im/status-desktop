import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import AppLayouts.Chat.stores 1.0

import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: root

    property var activeCommunity
    property RootStore store
    property var communitySectionModule
    property bool hasAddedContacts

    signal manageCommunityClicked()

    height: childrenRect.height + Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.padding
    anchors.right: parent.right
    anchors.rightMargin: Theme.padding
    border.color: Theme.palette.border
    radius: 16
    color: Theme.palette.transparent

    Rectangle {
        width: 70
        height: 4
        color: Theme.palette.secondaryMenuBackground
        anchors.top: parent.top
        anchors.topMargin: -2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    SVGImage {
        anchors.top: parent.top
        anchors.topMargin: -6
        anchors.horizontalCenter: parent.horizontalCenter
        source: Theme.svg("chatEmptyHeader")
        width: 66
        height: 50
    }

    StatusFlatRoundButton {
        id: closeImg
        implicitWidth: 32
        implicitHeight: 32
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon.height: 20
        icon.width: 20
        icon.name: "close-circle"
        type: StatusFlatRoundButton.Type.Tertiary
        onClicked: {
            let hiddenBannerIds = localAccountSensitiveSettings.hiddenCommunityWelcomeBanners || []
            if (hiddenBannerIds.includes(root.activeCommunity.id)) {
                return
            }
            hiddenBannerIds.push(root.activeCommunity.id)
            localAccountSensitiveSettings.hiddenCommunityWelcomeBanners = hiddenBannerIds
        }
    }

    StatusBaseText {
        id: welcomeText
        text: qsTr("Welcome to your community!")
        anchors.top: parent.top
        anchors.topMargin: 60
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Theme.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Theme.xlPadding
    }

    StatusButton {
        id: addMembersBtn
        objectName:"CommunityWelcomeBannerPanel_AddMembersButton"
        text: qsTr("Add members")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: welcomeText.bottom
        anchors.topMargin: Theme.padding
        onClicked: {
            Global.openInviteFriendsToCommunityPopup(root.activeCommunity,
                                                     root.communitySectionModule,
                                                     null)
        }
    }

    StatusFlatButton {
        id: manageBtn
        objectName:"CommunityWelcomeBannerPanel_ManageCommunity"
        text: qsTr("Manage community")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: addMembersBtn.bottom
        anchors.topMargin: Theme.halfPadding

        onClicked: root.manageCommunityClicked()
    }
}
