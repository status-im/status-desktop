import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import "../stores"
import "../panels"
import "../popups"
// TODO remove this import when the ContactRequestPanel is moved to the the Profile completely
import "../../Chat/panels"

Item {
    id: root

    property ContactsStore contactsStore
    property int profileContentWidth

    property alias searchStr: searchBox.text
    property bool isPending: false
    height: parent.height
    Layout.fillWidth: true
    clip: true

    Item {
        height: parent.height
        width: profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        StatusFlatButton {
            icon.name: "arrow-left"
            icon.width: 20
            icon.height: 20
            text: qsTr("Messaging")
            size: StatusBaseButton.Size.Large
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: -40
            onClicked: Global.changeAppSectionBySectionType(Constants.appSection.profile,
                Constants.settingsSubsection.messaging)
        }

        StatusBaseText {
            id: titleText
            text: qsTr("Contacts")
            font.weight: Font.Bold
            font.pixelSize: 28
            color: Theme.palette.directColor1
            anchors.top: parent.top
            anchors.topMargin: 56
        }

        SearchBox {
            id: searchBox
            anchors.top: titleText.bottom
            anchors.topMargin: 32
            fontPixelSize: 15
            placeholderText: qsTr("Search by a display name or chat key")
        }

        TabBar {
            id: contactsTabBar
            width: parent.width
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.padding
            height: contactsBtn.height
            background: Rectangle {
                color: Style.current.transparent
            }
            StatusTabButton {
                id: contactsBtn
                anchors.top: parent.top
                btnText: qsTr("Contacts")
            }
            StatusTabButton {
                id: pendingRequestsBtn
                enabled: root.contactsStore.contactRequestsModel.count > 0
                anchors.left: contactsBtn.right
                anchors.top: parent.top
                anchors.leftMargin: Style.current.bigPadding
                btnText: qsTr("Pending Requests")
                badge.value: contactList.count
            }
            StatusTabButton {
                id: blockedBtn
                enabled: root.contactsStore.blockedContactsModel.count > 0
                anchors.left: pendingRequestsBtn.right
                anchors.leftMargin: Style.current.bigPadding
                anchors.top: parent.top
                btnText: qsTr("Blocked")
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.top: contactsTabBar.bottom
            anchors.topMargin: Style.current.padding
            currentIndex: contactsTabBar.currentIndex

            // CONTACTS
            Item {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                height: parent.height

                ContactsListPanel {
                    id: contactListView
                    anchors.fill: parent
                    contactsModel: root.contactsStore.myContactsModel
                    clip: true
                    hideBlocked: true
                    searchString: searchBox.text
                    showSendMessageButton: true

                    onContactClicked: {
                        root.contactsStore.joinPrivateChat(contact.pubKey)
                    }

                    onOpenProfilePopup: {
                        Global.openProfilePopup(contact.pubKey)
                    }

                    onSendMessageActionTriggered: {
                        root.contactsStore.joinPrivateChat(contact.pubKey)
                    }
                    onOpenChangeNicknamePopup: {
                        Global.openProfilePopup(contact.pubKey, null, true)
                    }
                }

                NoFriendsRectangle {
                    visible: root.contactsStore.myContactsModel.count === 0
                    //% "You don’t have any contacts yet"
                    text: qsTrId("you-don-t-have-any-contacts-yet")
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // PENDING REQUESTS
            Item {
                ListView {
                    id: contactList

                    anchors.fill: parent
                    anchors.leftMargin: -Style.current.halfPadding
                    anchors.rightMargin: -Style.current.halfPadding

                    model: root.contactsStore.contactRequestsModel
                    clip: true

                    delegate: ContactRequestPanel {
                        contactName: model.name
                        contactIcon: model.icon
                        contactIconIsIdenticon: model.isIdenticon
                        onOpenProfilePopup: {
                            Global.openProfilePopup(model.pubKey)
                        }
                        onBlockContactActionTriggered: {
                            blockContactConfirmationDialog.contactName = model.name
                            blockContactConfirmationDialog.contactAddress = model.pubKey
                            blockContactConfirmationDialog.open()
                        }
                        onAcceptClicked: {
                            root.contactsStore.acceptContactRequest(model.pubKey)
                        }
                        onDeclineClicked: {
                            root.contactsStore.rejectContactRequest(model.pubKey)
                        }
                    }
                }
            }

            // BLOCKED
            ContactsListPanel {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                height: parent.height
                clip: true
                contactsModel: root.contactsStore.blockedContactsModel

                onOpenProfilePopup: {
                    Global.openProfilePopup(contact.pubKey)
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
    }

    // TODO: Make BlockContactConfirmationDialog a dynamic component on a future refactor
    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            root.contactsStore.blockContact(blockContactConfirmationDialog.contactAddress)
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
            if (Utils.getContactDetailsAsJson(removeContactConfirmationDialog.value).isContact) {
              root.contactsStore.removeContact(removeContactConfirmationDialog.value);
            }
            removeContactConfirmationDialog.close()
        }
    }
}

