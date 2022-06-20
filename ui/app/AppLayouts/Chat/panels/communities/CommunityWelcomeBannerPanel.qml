import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls

import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: root
    height: Style.dp(220)
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    border.color: Style.current.border
    radius: Style.dp(16)
    color: Style.current.transparent
    property var activeCommunity
    property var store
    property var communitySectionModule
    property bool hasAddedContacts

    signal manageCommunityClicked()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true
        onClicked: {
            /* Prevents sending events to the component beneath
               if Right Mouse Button is clicked. */
            mouse.accepted = false;
        }
    }

    Rectangle {
        width: Style.dp(70)
        height: Style.dp(4)
        color: Style.current.secondaryMenuBackground
        anchors.top: parent.top
        anchors.topMargin: -height/2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    SVGImage {
        anchors.top: parent.top
        anchors.topMargin: -Style.dp(6)
        anchors.horizontalCenter: parent.horizontalCenter
        source: Style.svg("chatEmptyHeader")
        width: Style.dp(66)
        height: Style.dp(50)
    }

    StatusQControls.StatusFlatRoundButton {
        id: closeImg
        implicitWidth: Style.dp(32)
        implicitHeight: Style.dp(32)
        anchors.top: parent.top
        anchors.topMargin: Style.dp(10)
        anchors.right: parent.right
        anchors.rightMargin: Style.dp(10)
        icon.height: Style.dp(20)
        icon.width: Style.dp(20)
        icon.name: "close-circle"
        type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
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
        //% "Welcome to your community!"
        text: qsTrId("welcome-to-your-community-")
        anchors.top: parent.top
        anchors.topMargin: Style.dp(60)
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Style.current.primaryTextFontSize
        color: Theme.palette.directColor1
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
    }

    StatusQControls.StatusButton {
        id: addMembersBtn
        //% "Add members"
        text: qsTrId("add-members")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: manageBtn.top
        anchors.bottomMargin: Style.current.halfPadding
        onClicked: Global.openPopup(inviteFriendsToCommunityPopup, {
            community: root.activeCommunity,
            hasAddedContacts: root.hasAddedContacts,
            communitySectionModule: root.communitySectionModule
        })
    }

    StatusQControls.StatusFlatButton {
        id: manageBtn
        //% "Manage community"
        text: qsTrId("manage-community")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding

        onClicked: root.manageCommunityClicked()
    }
}
