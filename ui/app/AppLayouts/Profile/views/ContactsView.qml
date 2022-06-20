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

SettingsContentBase {
    id: root

    property ContactsStore contactsStore

    property alias searchStr: searchBox.text
    property bool isPending: false

    headerComponents: [
        StatusButton {
            text: qsTr("Send contact request to chat key")
            onClicked: {
                sendContactRequest.open()
            }
        }
    ]

    ColumnLayout {
        spacing: 0
        width: root.contentWidth
        height: root.height

        SearchBox {
            id: searchBox
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            input.implicitHeight: 44
            input.placeholderText: qsTr("Search by a display name or chat key")
        }

        StatusTabBar {
            id: contactsTabBar
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            Layout.topMargin: 2 * Style.current.padding
            
            StatusTabButton {
                id: contactsBtn
                width: implicitWidth
                text: qsTr("Contacts")
            }
            StatusTabButton {
                id: pendingRequestsBtn
                width: implicitWidth
                enabled: root.contactsStore.receivedContactRequestsModel.count > 0 ||
                         root.contactsStore.sentContactRequestsModel.count > 0
                text: qsTr("Pending Requests")
                badge.value: root.contactsStore.receivedContactRequestsModel.count
            }
            // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
            //            StatusTabButton {
            //                id: rejectedRequestsBtn
            //                width: implicitWidth
            //                enabled: root.contactsStore.receivedButRejectedContactRequestsModel.count > 0 ||
            //                         root.contactsStore.sentButRejectedContactRequestsModel.count > 0
            //                btnText: qsTr("Rejected Requests")
            //            }
            StatusTabButton {
                id: blockedBtn
                width: implicitWidth
                enabled: root.contactsStore.blockedContactsModel.count > 0
                text: qsTr("Blocked")
            }
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: contactsTabBar.currentIndex

            // CONTACTS
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.height * 0.5
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
                            Global.openProfilePopup(publicKey, null, "openNickname")
                        }
                    }

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.height * 0.5
                        contactsModel: root.contactsStore.myContactsModel
                        clip: true
                        searchString: searchBox.text
                        panelUsage: Constants.contactsPanelUsage.mutualContacts

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onSendMessageActionTriggered: {
                            root.contactsStore.joinPrivateChat(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, "openNickname")
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
                        Layout.preferredHeight: root.height * 0.5
                        clip: true
                        title: qsTr("Received")
                        searchString: searchBox.text
                        contactsModel: root.contactsStore.receivedContactRequestsModel
                        panelUsage: Constants.contactsPanelUsage.receivedContactRequest

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, "openNickname")
                        }

                        onContactRequestAccepted: {
                            root.contactsStore.acceptContactRequest(publicKey)
                        }

                        onContactRequestRejected: {
                            root.contactsStore.dismissContactRequest(publicKey)
                        }
                    }

                    ContactsListPanel {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.height * 0.5
                        clip: true
                        title: qsTr("Sent")
                        searchString: searchBox.text
                        contactsModel: root.contactsStore.sentContactRequestsModel
                        panelUsage: Constants.contactsPanelUsage.sentContactRequest

                        onOpenProfilePopup: {
                            Global.openProfilePopup(publicKey)
                        }

                        onOpenChangeNicknamePopup: {
                            Global.openProfilePopup(publicKey, null, "openNickname")
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
            //                        Layout.preferredHeight: root.height * 0.5
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
            //                        Layout.preferredHeight: root.height * 0.5
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
            width: parent.width
            height: parent.height
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
}

