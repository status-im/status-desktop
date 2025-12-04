import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import shared.panels
import shared.status

import utils

Rectangle {
    id: root

    property string communityId
    signal addMembersClicked()
    signal addCategoriesClicked()
    signal hideBannerRequested()

    implicitHeight: childrenRect.height + Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.padding
    anchors.right: parent.right
    anchors.rightMargin: Theme.padding
    border.color: Theme.palette.border
    radius: 16
    color: StatusColors.transparent

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
        asset.name: "channel"
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
        onClicked: root.hideBannerRequested()
    }

    StatusBaseText {
        id: descriptionText
        text: qsTr("Expand your community by adding more channels and categories")
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
        id: addMembersBtn
        text: qsTr("Add channels")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: descriptionText.bottom
        anchors.topMargin: Theme.padding
        onClicked: {
            root.addMembersClicked();
        }
    }

    StatusFlatButton {
        id: manageBtn
        text: qsTr("Add categories")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: addMembersBtn.bottom
        anchors.topMargin: Theme.halfPadding

        onClicked: {
            root.addCategoriesClicked();
        }
    }
}
