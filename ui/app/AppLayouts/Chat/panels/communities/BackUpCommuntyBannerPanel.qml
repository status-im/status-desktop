import QtQuick 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

Rectangle {
    property string communityId
    signal backupButtonClicked(var mouse)

    id: root
    height: childrenRect.height + Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    border.color: Style.current.border
    radius: Style.dp(16)
    color: "transparent"

    Rectangle {
        width: Style.dp(66)
        height: Style.dp(4)
        color: Style.current.secondaryMenuBackground
        anchors.top: parent.top
        anchors.topMargin: -Style.dp(2)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusRoundIcon {
        anchors.top: parent.top
        anchors.topMargin: -Style.dp(6)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Style.dp(40)
        height: width
        icon.name: "objects"
    }

    StatusFlatRoundButton {
        id: closeImg
        implicitWidth: Style.dp(32)
        implicitHeight: implicitWidth
        anchors.top: parent.top
        anchors.topMargin: Style.dp(10)
        anchors.right: parent.right
        anchors.rightMargin: Style.dp(10)
        icon.height: Style.dp(20)
        icon.width: Style.dp(20)
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
        //% "Back up community key"
        text: qsTrId("back-up-community-key")
        anchors.top: parent.top
        anchors.topMargin: Style.dp(48)
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Style.current.primaryTextFontSize
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
        onClicked: root.backupButtonClicked(mouse)
    }
}

