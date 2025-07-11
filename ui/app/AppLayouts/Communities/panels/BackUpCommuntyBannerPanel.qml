import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import utils

Rectangle {
    id: root

    property string communityId
    signal backupButtonClicked()

    height: childrenRect.height + Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.padding
    anchors.right: parent.right
    anchors.rightMargin: Theme.padding
    border.color: Theme.palette.border
    radius: 16
    color: "transparent"

    Rectangle {
        width: 66
        height: 4
        color: Theme.palette.secondaryMenuBackground
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
        asset.name: "objects"
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
            let hiddenBannerIds = localAccountSensitiveSettings.hiddenCommunityBackUpBanners || []
            if (hiddenBannerIds.includes(root.communityId)) {
                return
            }
            hiddenBannerIds.push(root.communityId)
            localAccountSensitiveSettings.hiddenCommunityBackUpBanners = hiddenBannerIds
        }
    }

    StatusBaseText {
        id: backUpText
        text: qsTr("Back up community key")
        anchors.top: parent.top
        anchors.topMargin: 48
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Theme.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Theme.xlPadding
    }

    StatusButton {
        id: backUpBtn
        text: qsTr("Back up")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: backUpText.bottom
        anchors.topMargin: Theme.padding
        onClicked: root.backupButtonClicked()
    }
}

