import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    function doJoin(pk, ensName) {
        if(Utils.isChatKey(pk)){
            chatsModel.joinChat(pk, Constants.chatTypeOneToOne);
        } else {
            chatsModel.joinChatWithENS(pk, ensName);
        }

        popup.close();
    }

    id: popup
    //% "New chat"
    title: qsTrId("new-chat")

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
        onUserClicked: function (isContact, pubKey, ensName) {
            if(Utils.isChatKey(pubKey)){
                chatsModel.joinChat(pubKey, Constants.chatTypeOneToOne);
            } else {
                chatsModel.joinChatWithENS(pubKey, ensName);
            }

            popup.close();
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
