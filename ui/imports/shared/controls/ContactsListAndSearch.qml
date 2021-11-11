import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "../"
import "../views"
import "../panels"
import "../status"
import "."

Item {
    property string validationError: ""
    property string successMessage: ""
    property alias chatKey: chatKey
    property alias existingContacts: existingContacts
    property alias noContactsRect: noContactsRect
    property string pubKey : ""
    property int searchResultsWidth : 0
    property alias loading : searchResults.loading
    property string ensUsername : ""
    property bool showCheckbox: false
    property bool showContactList: true
    property bool showSearch: true
    signal userClicked(bool isContact, string pubKey, string ensName, string address)
    property var pubKeys: ([])
    property bool hideCommunityMembers: false
    property bool addContactEnabled: true

    id: root
    height: childrenRect.height + 24

    property var resolveENS: Backpressure.debounce(root, 500, function (ensName) {
        noContactsRect.visible = false
        searchResults.loading = true
        searchResults.showProfileNotFoundMessage = false
        chatsModel.ensView.resolveENS(ensName)
    });

    function validate() {
        if (!Utils.isChatKey(chatKey.text) && !Utils.isValidETHNamePrefix(chatKey.text)) {
            root.validationError = qsTr("Enter a valid chat key or ENS username");
            pubKey = ""
            ensUsername = "";
        } else if (profileModel.profile.pubKey === chatKey.text) {
            //% "Can't chat with yourself"
            root.validationError = qsTrId("can-t-chat-with-yourself");
        } else {
            root.validationError = "";
        }
        return root.validationError === "";
    }

    Input {
        id: chatKey
        //% "Enter ENS username or chat key"
        placeholderText: qsTrId("enter-contact-code")
        visible: showSearch
        Keys.onReleased: {
            successMessage = "";
            searchResults.pubKey = "";
            if (chatKey.text !== "") {
                if (!validate()) {
                    searchResults.showProfileNotFoundMessage = false;
                    noContactsRect.visible = false;
                    return;
                }

                chatKey.text = chatKey.text.trim();

                if (Utils.isChatKey(chatKey.text)) {
                    pubKey = chatKey.text;
                    if (!contactsModule.model.isAdded(pubKey)) {
                        searchResults.username = utilsModel.generateAlias(pubKey);
                        searchResults.userAlias = Utils.compactAddress(pubKey, 4);
                        searchResults.pubKey = pubKey
                    }
                    noContactsRect.visible = false;
                    return;
                }

                Qt.callLater(resolveENS, chatKey.text);
            } else {
                root.validationError = "";
            }
        }
        textField.anchors.rightMargin: clearBtn.width + Style.current.padding + 2

        Connections {
            target: chatsModel.ensView
            onEnsWasResolved: {
                if (chatKey.text == "") {
                    ensUsername.text = "";
                    pubKey = "";
                } else if(resolvedPubKey == ""){
                    ensUsername.text = "";
                    searchResults.pubKey = pubKey = "";
                    searchResults.address = "";
                    searchResults.showProfileNotFoundMessage = true
                } else {
                    if (profileModel.profile.pubKey === resolvedPubKey) {
                        //% "Can't chat with yourself"
                        root.validationError = qsTrId("can-t-chat-with-yourself");
                    } else {
                        searchResults.username = chatsModel.ensView.formatENSUsername(chatKey.text)
                        let userAlias = utilsModel.generateAlias(resolvedPubKey)
                        userAlias = userAlias.length > 20 ? userAlias.substring(0, 19) + "..." : userAlias
                        searchResults.userAlias =  userAlias + " • " + Utils.compactAddress(resolvedPubKey, 4)
                        searchResults.pubKey = pubKey = resolvedPubKey;
                        searchResults.address = resolvedAddress;
                    }
                    searchResults.showProfileNotFoundMessage = false
                }
                searchResults.loading = false;
                noContactsRect.visible = pubKey === ""  && ensUsername.text === "" && !contactsModule.model.list.hasAddedContacts() && !profileNotFoundMessage.visible
            }
        }

        StatusFlatRoundButton {
            id: clearBtn
            width: 20
            height: 20
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "clear"
            visible: chatKey.text !== ""
            icon.width: 20
            icon.height: 20
            type: StatusFlatRoundButton.Type.Tertiary
            color: "transparent"
            onClicked: {
                chatKey.text = "";
                chatKey.forceActiveFocus(Qt.MouseFocusReason);
                searchResults.showProfileNotFoundMessage = false;
                searchResults.pubKey = pubKey = "";
                noContactsRect.visible = false;
                searchResults.loading = false;
                root.validationError = "";
            }
        }
    }

    StyledText {
        id: message
        text: root.validationError || successMessage
        visible: root.validationError !== "" || successMessage !== ""
        font.pixelSize: 13
        color: !!root.validationError ? Style.current.danger : Style.current.success
        anchors.top: chatKey.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ExistingContacts {
        id: existingContacts
        visible: showContactList
        hideCommunityMembers: root.hideCommunityMembers
        anchors.topMargin: this.height > 0 ? Style.current.halfPadding : 0
        anchors.top: {
            if (message.visible) {
                return message.bottom
            }
            if (chatKey.visible) {
                return chatKey.bottom
            }
        }
        showCheckbox: root.showCheckbox
        filterText: chatKey.text
        pubKeys: root.pubKeys
        onContactClicked: function (contact) {
            if (!contact || typeof contact === "string") {
                return
            }
            const index = root.pubKeys.indexOf(contact.pubKey)
            const pubKeysCopy = Object.assign([], root.pubKeys)
            if (index === -1) {
                pubKeysCopy.push(contact.pubKey)
            } else {
                pubKeysCopy.splice(index, 1)
            }
            root.pubKeys = pubKeysCopy

            userClicked(true, contact.pubKey, contactsModule.model.addedContacts.userName(contact.pubKey, contact.name), contact.address)
        }
        expanded: !searchResults.loading && pubKey === "" && !searchResults.showProfileNotFoundMessage
    }

    SearchResults {
        id: searchResults
        anchors.top: existingContacts.visible ? existingContacts.bottom :
                                                message.visible? message.bottom : chatKey.bottom
        anchors.topMargin: Style.current.halfPadding
        hasExistingContacts: existingContacts.visible
        loading: false
        width: searchResultsWidth > 0 ? searchResultsWidth : parent.width
        addContactEnabled: root.addContactEnabled
        onResultClicked: {
            if (!validate()) {
                return
            }
            userClicked(false, pubKey, chatKey.text, searchResults.address)
        }
        onAddToContactsButtonClicked: contactsModule.addContact(pubKey)
    }

    NoFriendsRectangle {
        id: noContactsRect
        visible: showContactList
        anchors.top: chatKey.bottom
        anchors.topMargin: Style.current.xlPadding * 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
