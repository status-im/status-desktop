import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "../../Profile/Sections/Contacts/"
import "./"

ModalPopup {

    function doJoin(){
        if (chatKey.text !== "") {
            chatsModel.joinChat(chatKey.text, Constants.chatTypeOneToOne);
        } else if (contactListView.selectedContact.checked) {
            chatsModel.joinChat(contactListView.selectedContact.parent.address, Constants.chatTypeOneToOne);
        } else {
            return;
        }
        popup.close();
    }

    id: popup
    title: qsTr("New chat")

    onOpened: {
        chatKey.text = "";
        chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contactListView.selectedContact.checked = false
    }

    Input {
        id: chatKey
        placeholderText: qsTr("Enter ENS username or chat key")
        Keys.onEnterPressed: doJoin()
        Keys.onReturnPressed: doJoin()
    }

    ContactList {
        id: contactListView
        contacts: profileModel.contactList
        selectable: true
    }

    footer: Button {
        width: 44
        height: 44
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        Image {
            source: chatKey.text == "" ? "../../../img/arrow-button-inactive.svg" : "../../../img/arrow-btn-active.svg"
        }
        background: Rectangle {
            color: "transparent"
        }
        MouseArea {
            id: btnMAnewChat
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked : doJoin()
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
