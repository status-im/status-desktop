import QtQuick 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

import "."

Rectangle {
    id: root
    height: childrenRect.height + Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    border.color: Style.current.border
    radius: 16
    color: Style.current.transparent

    Rectangle {
        width: 66
        height: 4
        color: Style.current.secondaryMenuBackground
        anchors.top: parent.top
        anchors.topMargin: -2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusRoundIcon {
        anchors.top: parent.top
        anchors.topMargin: -6
        anchors.horizontalCenter: parent.horizontalCenter
        width: 40
        height: 40
        icon.name: "objects"
    }

    StatusBaseText {
        id: backUpText
        //% "Back up community key"
        text: qsTrId("back-up-community-key")
        anchors.top: parent.top
        anchors.topMargin: 48
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
        color: Theme.palette.directColor1
    }

    StatusButton {
        id: backUpBtn
        //% "Back up"
        text: qsTrId("back-up")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: backUpText.bottom
        anchors.topMargin: Style.current.padding
        onClicked: {
            openPopup(transferOwnershipPopup, {privateKey: chatsModel.communities.exportCommunity()})
        }
    }

    Component {
        id: transferOwnershipPopup
        TransferOwnershipPopup {
            anchors.centerIn: parent
            onClosed: {
                let hiddenBannerIds = appSettings.hiddenCommunityBackUpBanners
                hiddenBannerIds.push(chatsModel.communities.activeCommunity.id)
                appSettings.hiddenCommunityBackUpBanners = hiddenBannerIds
                destroy()
            }
        }
    }
}

