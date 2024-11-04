import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.controls 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0 as SharedStores
import shared.views 1.0
import shared.views.chat 1.0

import "../stores"
import "../panels"
import "../popups"

SettingsContentBase {
    id: root

    property ContactsStore contactsStore
    property SharedStores.UtilsStore utilsStore

    property alias searchStr: searchBox.text
    property bool isPending: false

    titleRowComponentLoader.sourceComponent: StatusButton {
        objectName: "ContactsView_ContactRequest_Button"
        text: qsTr("Send contact request to chat key")
        onClicked: {
            Global.openPopup(sendContactRequest);
        }
    }

    function openContextMenu(model, pubKey) {
        const entry = ModelUtils.getByKey(model, "pubKey", pubKey)

        const profileType = Utils.getProfileType(entry.isCurrentUser, false, entry.isBlocked)
        const contactType = Utils.getContactType(entry.contactRequest, entry.isContact)

        const params = {
            pubKey, profileType, contactType,
            compressedPubKey: entry.compressedPubKey,
            emojiHash: root.utilsStore.getEmojiHash(pubKey),
            displayName: entry.preferredDisplayName,
            userIcon: entry.icon,
            colorHash: entry.colorHash,
            colorId: entry.colorId,
            trustStatus: entry.trustStatus,
            onlineStatus: entry.onlineStatus,
            ensVerified: entry.isEnsVerified,
            hasLocalNickname: !!entry.localNickname
        }

        Global.openMenu(contactContextMenuComponent, this, params)
    }

    Item {
        id: contentItem
        width: root.contentWidth
        height: (searchBox.height + contactsTabBar.height
                + stackLayout.height + (2 * Theme.bigPadding))

        Component {
            id: contactContextMenuComponent
            ProfileContextMenu {
                id: contactContextMenu

                property string pubKey

                onOpenProfileClicked: Global.openProfilePopup(contactContextMenu.pubKey, null, null)
                onReviewContactRequest: Global.openReviewContactRequestPopup(contactContextMenu.pubKey, null)
                onSendContactRequest: Global.openContactRequestPopup(contactContextMenu.pubKey, null)
                onEditNickname: Global.openNicknamePopupRequested(contactContextMenu.pubKey, null)
                onUnblockContact: Global.unblockContactRequested(contactContextMenu.pubKey)
                onMarkAsUntrusted: Global.markAsUntrustedRequested(contactContextMenu.pubKey)
                onRemoveContact: Global.removeContactRequested(contactContextMenu.pubKey)
                onBlockContact: Global.blockContactRequested(contactContextMenu.pubKey)

                onCreateOneToOneChat: root.contactsStore.joinPrivateChat(contactContextMenu.pubKey)
                onRemoveTrustStatus: root.contactsStore.removeTrustStatus(contactContextMenu.pubKey)
                onRemoveNickname: root.contactsStore.changeContactNickname(contactContextMenu.pubKey, "",
                                                                           contactContextMenu.displayName, true)
                onMarkAsTrusted: Global.openMarkAsIDVerifiedPopup(contactContextMenu.pubKey, null)
                onRemoveTrustedMark: Global.openRemoveIDVerificationDialog(contactContextMenu.pubKey, null)
                onClosed: destroy()
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
            anchors.topMargin: Theme.padding

            StatusTabButton {
                id: contactsBtn
                leftPadding: Theme.padding
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
            StatusTabButton {
                id: blockedBtn
                objectName: "ContactsView_Blocked_Button"
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
            anchors.topMargin: Theme.padding
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
                spacing: Theme.padding
                ContactsListPanel {
                    id: verifiedContacts
                    Layout.fillWidth: true
                    title: qsTr("Trusted Contacts")
                    visible: !noFriendsItem.visible && count > 0
                    contactsModel: root.contactsStore.myContactsModel
                    searchString: searchBox.text
                    onOpenContactContextMenu: root.openContextMenu(contactsModel, publicKey)
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
                    onOpenContactContextMenu: root.openContextMenu(contactsModel, publicKey)
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
                        text: qsTr("You don't have any contacts yet")
                    }
                }
            }

            // PENDING REQUESTS
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 0
                Layout.maximumHeight: (receivedRequests.height + sentRequests.height)
                spacing: Theme.padding
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
                    visible: count > 0
                    onOpenContactContextMenu: root.openContextMenu(contactsModel, publicKey)
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
                }

                ContactsListPanel {
                    id: sentRequests
                    objectName: "sentRequests_ContactsListPanel"
                    Layout.fillWidth: true
                    title: qsTr("Sent")
                    searchString: searchBox.text
                    visible: count > 0
                    onOpenContactContextMenu: root.openContextMenu(contactsModel, publicKey)
                    contactsModel: root.contactsStore.sentContactRequestsModel
                    panelUsage: Constants.contactsPanelUsage.sentContactRequest
                }
            }

            // BLOCKED
            ContactsListPanel {
                Layout.fillWidth: true
                searchString: searchBox.text
                onOpenContactContextMenu: root.openContextMenu(contactsModel, publicKey)
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
