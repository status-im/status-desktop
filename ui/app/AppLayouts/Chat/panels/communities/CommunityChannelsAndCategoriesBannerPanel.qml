import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: root

    property string communityId
    signal addMembersClicked()
    signal addCategoriesClicked()

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
        icon.name: "channel"
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
            let hiddenBannerIds = localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners || []
            if (hiddenBannerIds.includes(communityId)) {
                return
            }
            hiddenBannerIds.push(communityId)
            localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners = hiddenBannerIds
        }
    }

    StatusBaseText {
        id: descriptionText
        text: qsTr("Expand your community by adding more channels and categories")
        anchors.top: parent.top
        anchors.topMargin: 48
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        color: Theme.palette.directColor1
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
    }

    StatusButton {
        id: addMembersBtn
        text: qsTr("Add channels")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: descriptionText.bottom
        anchors.topMargin: Style.current.padding
        onClicked: {
            root.addMembersClicked();
        }
    }

    StatusFlatButton {
        id: manageBtn
        text: qsTr("Add categories")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: addMembersBtn.bottom

        onClicked: {
            root.addCategoriesClicked();
        }
    }
}
