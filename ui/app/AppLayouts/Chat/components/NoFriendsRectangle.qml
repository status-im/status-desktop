import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

Rectangle {
    id: noContactsRect
    width: 260
    StyledText {
        id: noContacts
        //% "You don’t have any contacts yet. Invite your friends to start chatting."
        text: qsTrId("you-don-t-have-any-contacts-yet--invite-your-friends-to-start-chatting-")
        color: Style.current.darkGrey
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    StyledButton {
        //% "Invite friends"
        label: qsTrId("invite-friends")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: noContacts.bottom
        anchors.topMargin: Style.current.xlPadding
        onClicked: inviteFriendsPopup.open()
    }
    InviteFriendsPopup {
        id: inviteFriendsPopup
    }
}
