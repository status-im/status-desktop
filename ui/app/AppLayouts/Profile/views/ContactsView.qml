import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import "../panels"
import "../popups"

Item {
    id: root

    property var store

    property alias searchStr: searchBox.text
    property bool isPending: false
    height: parent.height
    Layout.fillWidth: true
    clip: true

    Item {
        anchors.top: parent.top
        anchors.topMargin: 32
        anchors.bottom: parent.bottom
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        SearchBox {
            id: searchBox
            anchors.top: parent.top
            fontPixelSize: 15
        }

        Item {
            id: addNewContact
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.bigPadding
            width: addButton.width + usernameText.width + Style.current.padding
            height: addButton.height


            StatusRoundButton {
                id: addButton
                width: 40
                height: 40
                icon.name: "add"
                type: StatusRoundButton.Type.Secondary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                id: usernameText
                //% "Add new contact"
                text: qsTrId("add-new-contact")
                color: Style.current.blue
                anchors.left: addButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: addButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    addContactModal.open()
                }
            }
        }

        Item {
            id: blockedContactsButton
            anchors.top: addNewContact.bottom
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            visible: root.store.blockedContacts.count > 0
            height: 64

            StatusRoundButton {
                id: blockButton
                width: 40
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "cancel"
                icon.color: Theme.palette.primaryColor1
            }

            StyledText {
                id: blockButtonLabel
                //% "Blocked contacts"
                text: qsTrId("blocked-contacts")
                color: Style.current.blue
                anchors.left: blockButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: blockButton.verticalCenter
                font.pixelSize: 15
            }

            StyledText {
                id: numberOfBlockedContacts
                text: root.store.blockedContacts.count
                color: Style.current.darkGrey
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: blockButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    blockedContactsModal.open()
                }
            }
        }

        ModalPopup {
            id: blockedContactsModal
            //% "Blocked contacts"
            title: qsTrId("blocked-contacts")

            ContactsListPanel {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                contacts: root.store.blockedContacts

                onRemoveContactActionTriggered: {
                    removeContactConfirmationDialog.value = contact.address
                    removeContactConfirmationDialog.open()
                }

                onUnblockContactActionTriggered: {
                    root.store.unblockContact(contact.address)
                }
            }
        }

        Component {
            id: loadingIndicator
            StatusLoadingIndicator {
                width: 12
                height: 12
            }
        }

        ModalPopup {
            id: addContactModal
            //% "Add contact"
            title: qsTrId("add-contact")
            property string validationError: ""

            function validate(value) {
                if (!Utils.isChatKey(value) && !Utils.isValidETHNamePrefix(value)) {
                    addContactModal.validationError = qsTr("Enter a valid chat key or ENS username");
                } else if (root.store.pubKey === value) {
                    //% "You can't add yourself"
                    addContactModal.validationError = qsTrId("you-can-t-add-yourself");
                } else {
                    addContactModal.validationError = "";
                }
                return addContactModal.validationError === "";
            }

            property var lookupContact: Backpressure.debounce(addContactSearchInput, 400, function (value) {
                root.isPending = true
                searchResults.showProfileNotFoundMessage = false
                root.store.lookupContact(value)
            })

            onOpened: {
                addContactSearchInput.text = ""
                searchResults.reset()
                addContactSearchInput.forceActiveFocus()
            }

            Input {
                id: addContactSearchInput
                //% "Enter ENS username or chat key"
                placeholderText: qsTrId("enter-contact-code")
                customHeight: 44
                fontPixelSize: 15
                onTextEdited: {
                    if (addContactSearchInput.text === "") {
                        searchResults.reset();
                        return;
                    }
                    if (!addContactModal.validate(addContactSearchInput.text)) {
                        searchResults.reset();
                        root.isPending = false;
                        return;
                    }

                    Qt.callLater(addContactModal.lookupContact, addContactSearchInput.text);
                }


                Connections {
                    target: root.store.contactsModuleInst
                    onEnsWasResolved: function (resolvedPubKey) {
                        if (resolvedPubKey === "") {
                            searchResults.pubKey = ""
                            searchResults.showProfileNotFoundMessage = true
                            root.isPending = false
                            return
                        }
                        searchResults.username = Utils.isChatKey(addContactSearchInput.text) ? root.store.generateAlias(resolvedPubKey) : Utils.addStatusEns(addContactSearchInput.text.trim())
                        searchResults.userAlias = Utils.compactAddress(resolvedPubKey, 4)
                        searchResults.pubKey = resolvedPubKey
                        searchResults.showProfileNotFoundMessage = false
                        root.isPending = false
                    }
                }
            }

            StyledText {
                id: validationErrorMessage
                text: addContactModal.validationError
                visible: addContactModal.validationError !== ""
                font.pixelSize: 13
                color: Style.current.danger
                anchors.top: addContactSearchInput.bottom
                anchors.topMargin: Style.current.smallPadding
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SearchResults {
                id: searchResults
                anchors.top: addContactSearchInput.bottom
                anchors.topMargin: Style.current.xlPadding
                loading: root.isPending
                resultClickable: false
                onAddToContactsButtonClicked: root.store.addContact(pubKey)
            }
        }

        ContactsListPanel {
            id: contactListView
            anchors.top: blockedContactsButton.visible ? blockedContactsButton.bottom : addNewContact.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.bottom: parent.bottom
            contacts: root.store.addedContacts
            hideBlocked: true
            searchString: searchBox.text

            onContactClicked: {
                root.store.changeAppSectionBySectionType(Constants.appSection.chat)
                root.store.joinPrivateChat(contact.address)
            }

            onSendMessageActionTriggered: {
                root.store.changeAppSectionBySectionType(Constants.appSection.chat)
                root.store.joinPrivateChat(contact.address)
            }

            onBlockContactActionTriggered: {
                blockContactConfirmationDialog.contactName = Utils.removeStatusEns(contact.name)
                blockContactConfirmationDialog.contactAddress = contact.address
                blockContactConfirmationDialog.open()
            }

            onRemoveContactActionTriggered: {
                removeContactConfirmationDialog.value = contact.address
                removeContactConfirmationDialog.open()
            }

            onUnblockContactActionTriggered: {
                root.store.unblockContact(contact.address)
            }
        }

        NoFriendsRectangle {
            id: element
            visible: root.store.addedContacts.count === 0
            //% "You don’t have any contacts yet"
            text: qsTrId("you-don-t-have-any-contacts-yet")
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // TODO: Make BlockContactConfirmationDialog a dynamic component on a future refactor
    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            root.store.blockContact(blockContactConfirmationDialog.contactAddress)
            blockContactConfirmationDialog.close()
        }
    }


    // TODO: Make ConfirmationDialog a dynamic component on a future refactor
    ConfirmationDialog {
        id: removeContactConfirmationDialog
        //% "Remove contact"
        header.title: qsTrId("remove-contact")
        //% "Are you sure you want to remove this contact?"
        confirmationText: qsTrId("are-you-sure-you-want-to-remove-this-contact-")
        onConfirmButtonClicked: {
            if (root.store.isContactAdded(removeContactConfirmationDialog.value)) {
              root.store.removeContact(removeContactConfirmationDialog.value);
            }
            removeContactConfirmationDialog.close()
        }
    }
}

