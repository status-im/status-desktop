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
import shared.views.chat 1.0

import "../stores"
import "../panels"
import "../popups"

SettingsContentBase {
    id: root
    property ContactsStore contactsStore
    property alias searchStr: searchBox.text
    property bool isPending: false

    titleRowComponentLoader.sourceComponent: StatusButton {
        objectName: "ContactsView_ContactRequest_Button"
        text: qsTr("Send contact request to chat key")
        onClicked: {
            Global.openPopup(sendContactRequest);
        }
    }

    function openContextMenu(publicKey, name, icon) {
        Global.openMenu(contactContextMenuComponent, this, {
                            selectedUserPublicKey: publicKey,
                            selectedUserDisplayName: name,
                            selectedUserIcon: icon,
                        })
    }

    Item {
        id: contentItem
        width: root.contentWidth
        height: (searchBox.height + contactsTabBar.height
                + stackLayout.height + (2 * Style.current.bigPadding))

        Component {
            id: contactContextMenuComponent

            ProfileContextMenu {
                id: contactContextMenu
                store: ({contactsStore: root.contactsStore})

                onOpenProfileClicked: function (pubkey) {
                    Global.openProfilePopup(pubkey, null)
                }
                onCreateOneToOneChat: function (communityId, chatId, ensName) {
                    root.contactsStore.joinPrivateChat(chatId)
                }
                onClosed: {
                    destroy()
                }
            }
        }

        SearchBox {
            id: searchBox
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: qsTr("Search by a display name or chat key")
        }

        StatusTabBar {
            id: contactsTabBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.padding

            StatusTabButton {
                id: contactsBtn
                leftPadding: Style.current.padding
                width: implicitWidth
                text: qsTr("Contacts")
            }
            StatusTabButton {
                id: pendingRequestsBtn
                objectName: "ContactsView_PendingRequest_Button"
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
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: contactsTabBar.bottom
            currentIndex: contactsTabBar.currentIndex
            anchors.topMargin: Style.current.padding
            // CONTACTS
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 0
                Layout.maximumHeight: (verifiedContacts.height + mutualContacts.height + noFriendsItem.height)
                visible: (stackLayout.currentIndex === 0)
                onVisibleChanged: {
                    if (visible) {
                        stackLayout.height = height+contactsTabBar.anchors.topMargin;
                    }
                }
                spacing: Style.current.padding
                ContactsListPanel {
                    id: verifiedContacts
                    Layout.fillWidth: true
                    title: qsTr("Identity Verified Contacts")
                    visible: !noFriendsItem.visible && count > 0
                    contactsModel: root.contactsStore.myContactsModel
                    searchString: searchBox.text
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    contactsStore: root.contactsStore
                    panelUsage: Constants.contactsPanelUsage.verifiedMutualContacts
                    onSendMessageActionTriggered: {
                        root.contactsStore.joinPrivateChat(publicKey)
                    }
                }

                ContactsListPanel {
                    id: mutualContacts
                    Layout.fillWidth: true
                    visible: !noFriendsItem.visible && count > 0
                    title: qsTr("Contacts")
                    contactsModel: root.contactsStore.myContactsModel
                    searchString: searchBox.text
                    contactsStore: root.contactsStore
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    panelUsage: Constants.contactsPanelUsage.mutualContacts

                    onSendMessageActionTriggered: {
                        root.contactsStore.joinPrivateChat(publicKey)
                    }
                }

                Item {
                    id: noFriendsItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ?  (root.contentHeight - (2*searchBox.height) - contactsTabBar.height - contactsTabBar.anchors.topMargin) : 0
                    visible: root.contactsStore.myContactsModel.count === 0
                    NoFriendsRectangle {
                        anchors.centerIn: parent
                        text: qsTr("You don’t have any contacts yet")
                    }
                }
            }

            // PENDING REQUESTS
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 0
                Layout.maximumHeight: (receivedRequests.height + sentRequests.height)
                spacing: Style.current.padding
                visible: (stackLayout.currentIndex === 1)
                onVisibleChanged: {
                    if (visible) {
                        stackLayout.height = height+contactsTabBar.anchors.topMargin;
                    }
                }
                ContactsListPanel {
                    id: receivedRequests
                    objectName: "receivedRequests_ContactsListPanel"
                    Layout.fillWidth: true
                    title: qsTr("Received")
                    searchString: searchBox.text
                    contactsStore: root.contactsStore
                    visible: count > 0
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    contactsModel: root.contactsStore.receivedContactRequestsModel
                    panelUsage: Constants.contactsPanelUsage.receivedContactRequest

                    onSendMessageActionTriggered: {
                        root.contactsStore.joinPrivateChat(publicKey)
                    }

                    onContactRequestAccepted: {
                        root.contactsStore.acceptContactRequest(publicKey, "")
                    }

                    onContactRequestRejected: {
                        root.contactsStore.dismissContactRequest(publicKey, "")
                    }

                    onShowVerificationRequest: {
                        Global.openIncomingIDRequestPopup(publicKey, null)
                    }
                }

                ContactsListPanel {
                    id: sentRequests
                    objectName: "sentRequests_ContactsListPanel"
                    Layout.fillWidth: true
                    title: qsTr("Sent")
                    searchString: searchBox.text
                    contactsStore: root.contactsStore
                    visible: count > 0
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    contactsModel: root.contactsStore.sentContactRequestsModel
                    panelUsage: Constants.contactsPanelUsage.sentContactRequest
                }
            }

            // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
            //            // REJECTED REQUESTS
            //            Item {
            //                Layout.fillWidth: true
            //                //Layout.fillHeight: true

            //                ColumnLayout {
            //                    //anchors.fill: parent

            //                    ContactsListPanel {
            //                        Layout.fillWidth: true
            //                        Layout.preferredHeight: root.height * 0.5
            //                        clip: true
            //                        title: qsTr("Received")
            //                        searchString: searchBox.text
            //                        contactsStore: root.contactsStore
            //                        onOpenContactContextMenu: function (publicKey, name, icon) {
            //                           root.openContextMenu(publicKey, name, icon)
            //                        }
            //                        contactsModel: root.contactsStore.receivedButRejectedContactRequestsModel
            //                        panelUsage: Constants.contactsPanelUsage.rejectedReceivedContactRequest

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
            //                        contactsStore: root.contactsStore
            //                        onOpenContactContextMenu: function (publicKey, name, icon) {
            //                             root.openContextMenu(publicKey, name, icon)
            //                         }
            //                        contactsModel: root.contactsStore.sentButRejectedContactRequestsModel
            //                        panelUsage: Constants.contactsPanelUsage.rejectedSentContactRequest
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
                searchString: searchBox.text
                contactsStore: root.contactsStore
                onOpenContactContextMenu: function (publicKey, name, icon) {
                    root.openContextMenu(publicKey, name, icon)
                }
                contactsModel: root.contactsStore.blockedContactsModel
                panelUsage: Constants.contactsPanelUsage.blockedContacts
                visible: (stackLayout.currentIndex === 2)
                onVisibleChanged: {
                    if (visible) {
                        stackLayout.height = height;
                    }
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

        Component {
            id: sendContactRequest
            SendContactRequestModal {
                contactsStore: root.contactsStore
                onClosed: destroy()
            }
        }
    }
}

