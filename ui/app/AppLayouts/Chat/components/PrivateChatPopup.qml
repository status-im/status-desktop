import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    property string validationError: ""

    property string pubKey : "";
    property string ensUsername : "";

    function validate() {
        if (!Utils.isChatKey(chatKey.text) && !Utils.isValidETHNamePrefix(chatKey.text)) {
            validationError = qsTr("Enter a valid chat key or ENS username");
            pubKey = ""
            ensUsername.text = "";
        } else if (profileModel.profile.pubKey === chatKey.text) {
            validationError = qsTr("Can't chat with yourself");
        } else {
            validationError = ""
        }
        return validationError === ""
    }

    property var resolveENS: Backpressure.debounce(popup, 500, function (ensName){
        noContactsRect.visible = false
        searchResults.loading = true
        searchResults.showProfileNotFoundMessage = false
        chatsModel.resolveENS(ensName)
    });

    function onKeyReleased(){
        searchResults.pubKey = ""
        if (!validate()) {
            searchResults.showProfileNotFoundMessage = false
            noContactsRect.visible = false
            return;
        }

        chatKey.text = chatKey.text.trim();
        
        if (Utils.isChatKey(chatKey.text)){
            pubKey = chatKey.text;
            if (!profileModel.contacts.isAdded(pubKey)) {
                searchResults.username = utilsModel.generateAlias(pubKey)
                searchResults.userAlias = Utils.compactAddress(pubKey, 4)
                searchResults.pubKey = pubKey
            }
            noContactsRect.visible = false
            return;
        }
        
        Qt.callLater(resolveENS, chatKey.text)
    }

    function validateAndJoin(pk, ensName) {
        if (!validate() || pk.trim() === "" || validationError !== "") return;
        doJoin(pk, ensName)
    }
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
        chatKey.text = "";
        pubKey = "";
        ensUsername.text = "";
        chatKey.forceActiveFocus(Qt.MouseFocusReason)
        existingContacts.visible = profileModel.contacts.list.hasAddedContacts()
        noContactsRect.visible = !existingContacts.visible
    }

    Input {
        id: chatKey
        //% "Enter ENS username or chat key"
        placeholderText: qsTrId("enter-contact-code")
        Keys.onEnterPressed: validateAndJoin(popup.pubKey, chatKey.text)
        Keys.onReturnPressed: validateAndJoin(popup.pubKey, chatKey.text)
        Keys.onReleased: {
            onKeyReleased();
        }
        textField.anchors.rightMargin: clearBtn.width + Style.current.padding + 2

        Connections {
            target: chatsModel
            onEnsWasResolved: {
                if(chatKey.text == ""){
                    ensUsername.text = "";
                    pubKey = "";
                } else if(resolvedPubKey == ""){
                    ensUsername.text = "";
                    searchResults.pubKey = pubKey = "";
                    searchResults.showProfileNotFoundMessage = true
                } else {
                    if (profileModel.profile.pubKey === resolvedPubKey) {
                        popup.validationError = qsTr("Can't chat with yourself");
                    } else {
                        searchResults.username = chatsModel.formatENSUsername(chatKey.text)
                        let userAlias = utilsModel.generateAlias(resolvedPubKey)
                        userAlias = userAlias.length > 20 ? userAlias.substring(0, 19) + "..." : userAlias
                        searchResults.userAlias =  userAlias + " • " + Utils.compactAddress(resolvedPubKey, 4)
                        searchResults.pubKey = pubKey = resolvedPubKey;
                    }
                    searchResults.showProfileNotFoundMessage = false
                }
                searchResults.loading = false;
                noContactsRect.visible = pubKey === ""  && ensUsername.text === "" && !profileModel.contacts.list.hasAddedContacts() && !profileNotFoundMessage.visible
            }
        }

        StatusIconButton {
            id: clearBtn
            icon.name: "close-icon"
            type: "secondary"
            visible: chatKey.text !== ""
            icon.width: 14
            icon.height: 14
            width: 14
            height: 14
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                chatKey.text = ""
                chatKey.forceActiveFocus(Qt.MouseFocusReason)
                searchResults.showProfileNotFoundMessage = false
                searchResults.pubKey = popup.pubKey = ""
                noContactsRect.visible = false
            }
        }
    }

    StyledText {
        id: validationErrorMessage
        text: popup.validationError
        visible: popup.validationError !== ""
        font.pixelSize: 13
        color: Style.current.danger
        anchors.top: chatKey.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    PrivateChatPopupExistingContacts {
        id: existingContacts
        anchors.topMargin: this.height > 0 ? Style.current.xlPadding : 0
        anchors.top: chatKey.bottom
        filterText: chatKey.text
        onContactClicked: function (contact) {
            doJoin(contact.pubKey, profileModel.contacts.addedContacts.userName(contact.pubKey, contact.name))
        }
        expanded: !searchResults.loading && popup.pubKey === "" && !searchResults.showProfileNotFoundMessage
    }

    PrivateChatPopupSearchResults {
        id: searchResults
        anchors.top: existingContacts.visible ? existingContacts.bottom : chatKey.bottom
        anchors.topMargin: Style.current.padding
        hasExistingContacts: existingContacts.visible
        loading: false

        onResultClicked: validateAndJoin(popup.pubKey, chatKey.text)
        onAddToContactsButtonClicked: profileModel.contacts.addContact(popup.pubKey)
    }

    NoFriendsRectangle {
        id: noContactsRect
        anchors.top: chatKey.bottom
        anchors.topMargin: Style.current.xlPadding * 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
