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

        RowLayout {
            id: contactsHeader
            anchors.top: parent.top
            anchors.topMargin: 56
            anchors.left: parent.left
            anchors.right: parent.right

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Contacts")
                font.weight: Font.Bold
                font.pixelSize: 28
                color: Theme.palette.directColor1
            }

            StatusButton {
                text: qsTr("Send contact request to chat key")
                onClicked: {
                    sendContactRequest.open()
                }
            }
        }

        SearchBox {
            id: searchBox
            anchors.top: contactsHeader.bottom
            anchors.topMargin: 32
            width: parent.width
            input.implicitHeight: 44
            input.placeholderText: qsTr("Search by a display name or chat key")
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
                addToWidth: Style.current.bigPadding
                btnText: qsTr("Contacts")
            }
            StatusTabButton {
                id: pendingRequestsBtn
                addToWidth: Style.current.bigPadding
                enabled: root.contactsStore.receivedContactRequestsModel.count > 0 ||
                         root.contactsStore.sentContactRequestsModel.count > 0
                btnText: qsTr("Pending Requests")
                badge.value: contactList.count
            }
            // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
//            StatusTabButton {
//                id: rejectedRequestsBtn
//                addToWidth: Style.current.bigPadding
//                enabled: root.contactsStore.receivedButRejectedContactRequestsModel.count > 0 ||
//                         root.contactsStore.sentButRejectedContactRequestsModel.count > 0
//                btnText: qsTr("Rejected Requests")
//            }
            StatusTabButton {
                id: blockedBtn
                addToWidth: Style.current.bigPadding
                enabled: root.contactsStore.blockedContactsModel.count > 0
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
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.5
                        contactsModel: root.contactsStore.myContactsModel
                        clip: true
                        title: qsTr("Identity Verified Contacts")
                        searchString: searchBox.text
                        panelUsage: Constants.contactsPanelUsage.verifiedMutualContacts

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onSendMessageActionTriggered: {
                            root.contactsStore.joinPrivateChat(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, true)
                        }
                    }

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.5
                        contactsModel: root.contactsStore.myContactsModel
                        clip: true
                        title: qsTr("Contacts")
                        searchString: searchBox.text
                        panelUsage: Constants.contactsPanelUsage.mutualContacts

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onSendMessageActionTriggered: {
                            root.contactsStore.joinPrivateChat(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, true)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                NoFriendsRectangle {
                    visible: root.contactsStore.myContactsModel.count === 0
                    //% "You don’t have any contacts yet"
                    text: qsTrId("you-don-t-have-any-contacts-yet")
                    width: parent.width
                    anchors.centerIn: parent
                }
            }

            // PENDING REQUESTS
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.5
                        clip: true
                        title: qsTr("Received")
                        searchString: searchBox.text
                        contactsModel: root.contactsStore.receivedContactRequestsModel
                        panelUsage: Constants.contactsPanelUsage.receivedContactRequest

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, true)
                        }

                        onContactRequestAccepted: {
                            root.contactsStore.acceptContactRequest(publicKey)
                        }

                        onContactRequestRejected: {
                            root.contactsStore.rejectContactRequest(publicKey)
                        }
                    }

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.5
                        clip: true
                        title: qsTr("Sent")
                        searchString: searchBox.text
                        contactsModel: root.contactsStore.sentContactRequestsModel
                        panelUsage: Constants.contactsPanelUsage.sentContactRequest

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, true)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
//            // REJECTED REQUESTS
//            Item {
//                Layout.fillWidth: true
//                Layout.fillHeight: true

//                ColumnLayout {
//                    anchors.fill: parent

//                    ContactsListPanel {
//                        Layout.fillWidth: true
//                        Layout.preferredHeight: parent.height * 0.5
//                        clip: true
//                        title: qsTr("Received")
//                        searchString: searchBox.text
//                        contactsModel: root.contactsStore.receivedButRejectedContactRequestsModel
//                        panelUsage: Constants.contactsPanelUsage.rejectedReceivedContactRequest

//                        onOpenProfilePopup: {
//                            Global.openProfilePopup(publicKey)
//                        }

//                        onOpenChangeNicknamePopup: {
//                            Global.openProfilePopup(publicKey, null, true)
//                        }

//                        onRejectionRemoved: {
//                            root.contactsStore.removeContactRequestRejection(publicKey)
//                        }
//                    }

//                    ContactsListPanel {
//                        Layout.fillWidth: true
//                        Layout.preferredHeight: parent.height * 0.5
//                        clip: true
//                        title: qsTr("Sent")
//                        searchString: searchBox.text
//                        contactsModel: root.contactsStore.sentButRejectedContactRequestsModel
//                        panelUsage: Constants.contactsPanelUsage.rejectedSentContactRequest

//                        onOpenProfilePopup: {
//                            Global.openProfilePopup(publicKey)
//                        }

//                        onOpenChangeNicknamePopup: {
//                            Global.openProfilePopup(publicKey, null, true)
//                        }
//                    }

//                    Item {
//                        Layout.fillWidth: true
//                        Layout.fillHeight: true
//                    }
//                }
//            }

            // BLOCKED
            ContactsListPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                searchString: searchBox.text
                contactsModel: root.contactsStore.blockedContactsModel
                panelUsage: Constants.contactsPanelUsage.blockedContacts

                onOpenProfilePopup: {
                    Global.openProfilePopup(publicKey)
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

    Loader {
        id: sendContactRequest
        active: false

        function open() {
            active = true
            sendContactRequest.item.open()
        }
        function close() {
            active = false
        }

        sourceComponent: SendContactRequestModal {
            anchors.centerIn: parent
            contactsStore: root.contactsStore

            onClosed: {
                sendContactRequest.close();
            }
        }
    }
}

