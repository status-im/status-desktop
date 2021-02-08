import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../../Chat/components"
import "./Contacts"

Item {
    id: contactsContainer
    property alias searchStr: searchBox.text
    property bool isPending: false
    height: parent.height
    Layout.fillWidth: true

    Item {
        anchors.top: parent.top
        anchors.topMargin: 32
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin

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
                icon.name: "plusSign"
                size: "medium"
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
            width: blockButton.width + blockButtonLabel.width + Style.current.padding
            visible: profileModel.contacts.blockedContacts.rowCount() > 0
            height: addButton.height

            StatusRoundButton {
                id: blockButton
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "block-icon"
                icon.color: Style.current.lightBlue
                width: 40
                height: 40
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

            ContactList {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                contacts: profileModel.contacts.blockedContacts
            }
        }

        Connections {
            target: profileModel.contacts
            onContactToAddChanged: {
                contactsContainer.isPending = false
            }
        }

        Component {
            id: loadingIndicator
            LoadingImage {
                width: 12
                height: 12
            }
        }

        ModalPopup {
            id: addContactModal
            //% "Add contact"
            title: qsTrId("add-contact")

            property var lookupContact: Backpressure.debounce(addContactSearchInput, 400, function (value) {
                profileModel.contacts.lookupContact(value)
            })

            onOpened: {
                addContactSearchInput.text = ""
            }

            Input {
                id: addContactSearchInput
                //% "Enter ENS username or chat key"
                placeholderText: qsTrId("enter-contact-code")
                customHeight: 44
                fontPixelSize: 15
                onEditingFinished: {
                    contactsContainer.isPending = true
                    profileModel.contacts.lookupContact(inputValue)
                    contactsContainer.isPending = false
                }
                onTextChanged: {
                    if (addContactSearchInput.text !== "") {
                        contactsContainer.isPending = true
                    }
                }
                Keys.onReleased: {
                    Qt.callLater(addContactModal.lookupContact, addContactSearchInput.text)
                }
            }

            Loader {
                sourceComponent: loadingIndicator
                anchors.top: addContactSearchInput.bottom
                anchors.topMargin: Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter
                active: contactsContainer.isPending
            }

            Item {
                id: contactToAddInfo
                anchors.top: addContactSearchInput.bottom
                anchors.topMargin: Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter
                height: contactUsername.height
                width: contactUsername.width + contactPubKey.width
                visible: !contactsContainer.isPending && !!addContactSearchInput.text


                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                    color: Style.current.darkGrey
                    //% "User not found"
                    text: qsTrId("user-not-found")
                    visible: !contactsContainer.isPending && !!!profileModel.contacts.contactToAddUsername
                }

                Connections {
                    target: profileModel.contacts
                    onEnsWasResolved: {
                        if(addContactSearchInput.text !== "" && !Utils.isHex(addContactSearchInput.text) && resolvedPubKey !== ""){
                            contactUsername.text = Qt.binding(function () {
                                return chatsModel.formatENSUsername(addContactSearchInput.text) + " • "
                            });
                        }
                    }
                }

                StyledText {
                    id: contactUsername
                    text: profileModel.contacts.contactToAddUsername + " • "
                    font.pixelSize: 12
                    color: Style.current.darkGrey
                    visible: !!profileModel.contacts.contactToAddPubKey
                }

                StyledText {
                    id: contactPubKey
                    text: profileModel.contacts.contactToAddPubKey
                    anchors.left: contactUsername.right
                    width: 100
                    font.pixelSize: 12
                    elide: Text.ElideMiddle
                    color: Style.current.darkGrey
                    visible: !!profileModel.contacts.contactToAddPubKey
                }

            }
            footer: StatusButton {
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                //% "Add contact"
                text: qsTrId("add-contact")
                enabled: contactToAddInfo.visible
                anchors.bottom: parent.bottom
                onClicked: {
                    profileModel.contacts.addContact(profileModel.contacts.contactToAddPubKey);
                    addContactModal.close()
                }
            }
        }

        ContactList {
            id: contactListView
            anchors.top: blockedContactsButton.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.bottom: parent.bottom
            contacts: profileModel.contacts.addedContacts
            searchString: searchBox.text
        }

        NoFriendsRectangle {
            id: element
            visible: profileModel.contacts.addedContacts.rowCount() === 0
            text: qsTr("You don’t have any contacts yet")
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.6600000262260437;height:480;width:600}
}
##^##*/
