import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.popups 1.0

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
