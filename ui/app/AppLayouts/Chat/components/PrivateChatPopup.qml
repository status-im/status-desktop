import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/controls"
import "../../../../shared/popups"
import "../../../../shared/panels"
import "../../../../shared/status"
import "./"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    //% "New chat"
    title: qsTrId("new-chat")

    signal profileClicked()
    function doJoin(pk, ensName) {
        chatsModel.channelView.joinPrivateChat(pk, Utils.isChatKey(pk) ? "" : ensName);
        popup.close();
    }

    onOpened: {
        contactFieldAndList.chatKey.text = ""
        contactFieldAndList.pubKey = ""
        contactFieldAndList.ensUsername = ""
        contactFieldAndList.chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contactFieldAndList.existingContacts.visible = profileModel.contacts.list.hasAddedContacts()
        contactFieldAndList.noContactsRect.visible = !contactFieldAndList.existingContacts.visible
    }

    ContactsListAndSearch {
        id: contactFieldAndList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        addContactEnabled: false
        onUserClicked: function (isContact, pubKey, ensName) {
            chatsModel.channelView.joinPrivateChat(pubKey, Utils.isChatKey(pubKey) ? "" : ensName);
            popup.close();
        }
    }

    Control {
        width: 124
        height: 36
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        background: Rectangle {
            anchors.fill: parent
            radius: 34
            color: Style.current.blue
        }
        contentItem: Item {
            anchors.fill: parent
            RoundedImage {
                id: dollarEmoji
                width: 32
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                source: appMain.getProfileImage(profileModel.profile.pubKey)
            }

            StyledText {
                anchors.left: dollarEmoji.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                //% "My Profile"
                text: qsTrId("my-profile")
                font.pixelSize: 15
                color: Style.current.white
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"
            onClicked: {
                popup.profileClicked();
                Config.currentMenuTab = 0;
                popup.close();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
