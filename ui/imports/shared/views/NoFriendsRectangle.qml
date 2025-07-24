import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils
import shared.popups

Item {
    id: root
    implicitWidth: 260
    implicitHeight: visible ? 120 : 0

    property string text: inviteButtonVisible ? qsTr("You don’t have any contacts yet. Invite your friends to start chatting.")
                                              : qsTr("No users match your search")
    property alias textColor: noContacts.color
    property bool inviteButtonVisible: true

    StatusBaseText {
        id: noContacts
        text: root.text
        color: Theme.palette.baseColor1
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    StatusButton {
        objectName: "inviteFriendsStatusButton"
        text: qsTr("Invite friends")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: noContacts.bottom
        anchors.topMargin: Theme.padding
        visible: root.inviteButtonVisible
        onClicked: inviteFriendsPopup.createObject(root).open()
    }

    Component {
        id: inviteFriendsPopup
        InviteFriendsPopup {
            destroyOnClose: true
        }
    }
}
