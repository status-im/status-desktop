import QtQuick 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "../popups"

Item {
    id: noContactsRect
    implicitWidth: 260
    implicitHeight: visible ? 120 : 0

    property string text: qsTr("You don’t have any contacts yet. Invite your friends to start chatting.")
    property alias textColor: noContacts.color

    StatusBaseText {
        id: noContacts
        text: noContactsRect.text
        color: Theme.palette.baseColor1
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
    }
    StatusButton {
        text: qsTr("Invite friends")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: noContacts.bottom
        anchors.topMargin: Theme.padding
        onClicked: Global.openPopup(inviteFriendsPopup);
    }

    Component {
        id: inviteFriendsPopup
        InviteFriendsPopup {
            destroyOnClose: true
        }
    }
}
