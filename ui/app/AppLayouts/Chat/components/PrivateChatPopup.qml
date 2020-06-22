import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../Profile/Sections/Contacts/"
import "./"

ModalPopup {
    property string validationError: ""

    function validate() {
        // TODO change this when we support ENS names
        if (!Utils.isChatKey(chatKey.text)) {
            validationError = "This needs to be a valid chat key"
        } else {
            validationError = ""
        }
        return validationError === ""
    }

    function doJoin() {
        if (chatKey.text !== "") {
            if (!validate()) {
                return
            }

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
        if (contactListView.selectedContact) {
            contactListView.selectedContact.checked = false
        }
    }

    Input {
        id: chatKey
        placeholderText: qsTr("Enter ENS username or chat key")
        Keys.onEnterPressed: doJoin()
        Keys.onReturnPressed: doJoin()
        validationError: popup.validationError
        textField.onEditingFinished: {
            validate()
        }
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
