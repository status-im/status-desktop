import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: root

    property var activeCommunity
    property var store
    property var communitySectionModule
    property bool hasAddedContacts

    signal manageCommunityClicked()

    height: childrenRect.height + Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    border.color: Style.current.border
    radius: 16
    color: Style.current.transparent

    Rectangle {
        width: 70
        height: 4
        color: Style.current.secondaryMenuBackground
        anchors.top: parent.top
        anchors.topMargin: -2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    SVGImage {
        anchors.top: parent.top
        anchors.topMargin: -6
        anchors.horizontalCenter: parent.horizontalCenter
        source: Style.svg("chatEmptyHeader")
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
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
    }

    StatusButton {
        id: addMembersBtn
        objectName:"CommunityWelcomeBannerPanel_AddMembersButton"
        text: qsTr("Add members")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: welcomeText.bottom
        anchors.topMargin: Style.current.padding
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
        anchors.topMargin: Style.current.halfPadding

        onClicked: root.manageCommunityClicked()
    }
}
