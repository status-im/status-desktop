import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.stores 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "../"
import "../views"
import "../panels"
import "../status"
import "."

Item {
    id: root
    height: (chatKey.height + message.height + existingContacts.height
            + searchResults.height + noContactsRect.height + 24)

    property var rootStore
    property var contactsStore
    property var community

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
    signal userClicked(string pubKey, bool isAddedContact, string name, string address)
    property var pubKeys: ([])
    property bool hideCommunityMembers: false
    property bool addContactEnabled: true
    property string wrongInputValidationError: qsTr("Enter a valid chat key or ENS username");


    property var resolveENS: Backpressure.debounce(root, 500, function (ensName) {
        noContactsRect.visible = false
        searchResults.loading = true
        searchResults.showProfileNotFoundMessage = false
        mainModule.resolveENS(ensName, "")
    });

    function validate() {
        if (!Utils.isChatKey(chatKey.text) && !Utils.isValidETHNamePrefix(chatKey.text)) {
            root.validationError = wrongInputValidationError
            pubKey = ""
            ensUsername = "";
        } else if (RootStore.userProfileInst.pubKey === chatKey.text) {
            root.validationError = qsTr("Can't chat with yourself");
        } else {
            root.validationError = "";
        }
        return root.validationError === "";
    }

    Input {
        id: chatKey
        property bool hasValidSearchResult: false

        placeholderText: qsTr("Enter ENS username or chat key")
        visible: showSearch
        height: visible ? implicitHeight : 0
        Keys.onReleased: {
            successMessage = "";
            searchResults.pubKey = "";
            root.validationError = "";
            searchResults.showProfileNotFoundMessage = false;
            if (chatKey.text !== "") {
                if (!validate()) {
                    noContactsRect.visible = false;
                    return;
                }

                chatKey.text = chatKey.text.trim();

                if (Utils.isChatKey(chatKey.text)) {
                    pubKey = chatKey.text;
                    let contactDetails = Utils.getContactDetailsAsJson(pubKey)
                    if (!contactDetails.isContact) {
                        searchResults.username = contactDetails.alias
                        searchResults.userAlias = Utils.compactAddress(pubKey, 4);
                        searchResults.pubKey = pubKey
                    }
                    noContactsRect.visible = false;
                    return;
                }

                chatKey.hasValidSearchResult = false
                Qt.callLater(resolveENS, chatKey.text);
            } else {
                root.validationError = "";
            }
        }
        textField.anchors.rightMargin: clearBtn.width + Style.current.padding + 2

        Connections {
            target: mainModule
            onResolvedENS: {
                chatKey.hasValidSearchResult = false
                if (chatKey.text == "") {
                    ensUsername.text = "";
                    pubKey = "";
                } else if(resolvedPubKey == ""){
                    ensUsername.text = "";
                    searchResults.pubKey = pubKey = "";
                    searchResults.address = "";
                    searchResults.showProfileNotFoundMessage = root.showContactList
                } else {
                    if (userProfile.pubKey === resolvedPubKey) {
                        root.validationError = qsTr("Can't chat with yourself");
                    } else {
                        chatKey.hasValidSearchResult = true
                        searchResults.username = Utils.addStatusEns(chatKey.text.trim())
                        let userAlias = globalUtils.generateAlias(resolvedPubKey)
                        userAlias = userAlias.length > 20 ? userAlias.substring(0, 19) + "..." : userAlias
                        searchResults.userAlias =  userAlias + " • " + Utils.compactAddress(resolvedPubKey, 4)
                        searchResults.pubKey = pubKey = resolvedPubKey;
                        searchResults.address = resolvedAddress;
                    }
                    searchResults.showProfileNotFoundMessage = false
                }
                searchResults.loading = false;
                noContactsRect.visible = pubKey === ""  &&
                        ensUsername.text === "" &&
                        root.contactsStore.myContactsModel.count === 0 &&
                        !profileNotFoundMessage.visible
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
            visible: chatKey.text !== "" && !chatKey.readOnly
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
                chatKey.hasValidSearchResult = false
            }
        }
    }

    StyledText {
        id: message
        text: root.validationError || successMessage
        visible: root.validationError !== "" || successMessage !== ""
        height: visible ? contentHeight : 0
        font.pixelSize: 13
        color: !!root.validationError ? Style.current.danger : Style.current.success
        anchors.top: chatKey.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ExistingContacts {
        id: existingContacts

        contactsStore: root.contactsStore
        community: root.community
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

            chatKey.hasValidSearchResult = false
            userClicked(contact.pubKey, contact.isContact, contact.alias, contact.address)
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
            chatKey.hasValidSearchResult = false
            userClicked(pubKey, isAddedContact, username, searchResults.address)
            if (!validate()) {
                return
            }
        }
        onAddToContactsButtonClicked: {
            root.contactsStore.addContact(pubKey)
        }
    }

    NoFriendsRectangle {
        id: noContactsRect
        visible: showContactList
        anchors.centerIn: parent
        rootStore: root.rootStore
    }
}
