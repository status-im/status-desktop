import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
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

import AppLayouts.Profile.stores 1.0
import AppLayouts.Profile.panels 1.0
import AppLayouts.Profile.popups 1.0

SettingsContentBase {
    id: root

    property ContactsStore contactsStore
    property SharedStores.UtilsStore utilsStore

    required property var mutualContactsModel
    required property var blockedContactsModel
    required property var pendingContactsModel
    required property int pendingReceivedContactsCount

    property alias searchStr: searchBox.text

    titleRowComponentLoader.sourceComponent: StatusButton {
        objectName: "ContactsView_ContactRequest_Button"
        text: qsTr("Send contact request to chat key")
        onClicked: sendContactRequestComponent.createObject(root).open()
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

    headerComponents: ColumnLayout {
        width: root.contentWidth
        spacing: Theme.padding

        StatusTabBar {
            id: contactsTabBar
            Layout.fillWidth: true

            StatusTabButton {
                readonly property int panelUsage: Constants.contactsPanelUsage.mutualContacts

                width: implicitWidth
                text: qsTr("Contacts")
            }
            StatusTabButton {
                readonly property int panelUsage: Constants.contactsPanelUsage.pendingContacts

                objectName: "ContactsView_PendingRequest_Button"
                width: implicitWidth
                enabled: !!root.pendingContactsModel && !root.pendingContactsModel.ModelCount.empty
                text: qsTr("Pending Requests")
                badge.value: root.pendingReceivedContactsCount
            }
            StatusTabButton {
                readonly property int panelUsage: Constants.contactsPanelUsage.blockedContacts

                objectName: "ContactsView_Blocked_Button"
                width: implicitWidth
                enabled: !!root.blockedContactsModel && !root.blockedContactsModel.ModelCount.empty
                text: qsTr("Blocked")
            }
        }

        SearchBox {
            id: searchBox
            Layout.fillWidth: true
            placeholderText: qsTr("Search by name or chat key")
        }
    }

    ContactsListPanel {
        id: contactsListPanel
        width: root.contentWidth
        height: root.availableHeight

        panelUsage: contactsTabBar.currentItem.panelUsage
        contactsModel: {
            switch (panelUsage) {
            case Constants.contactsPanelUsage.pendingContacts:
                return root.pendingContactsModel
            case Constants.contactsPanelUsage.blockedContacts:
                return root.blockedContactsModel
            case Constants.contactsPanelUsage.mutualContacts:
            default:
                return root.mutualContactsModel
            }
        }
        section.property: {
            switch (contactsListPanel.panelUsage) {
            case Constants.contactsPanelUsage.pendingContacts:
                return "contactRequest"
            case Constants.contactsPanelUsage.mutualContacts:
                return "isVerified"
            case Constants.contactsPanelUsage.blockedContacts:
            default:
                return ""
            }
        }
        section.delegate: SectionComponent {
            text: {
                switch (contactsListPanel.panelUsage) {
                case Constants.contactsPanelUsage.pendingContacts:
                    return section === `${Constants.ContactRequestState.Received}` ? qsTr("Received") : qsTr("Sent")
                case Constants.contactsPanelUsage.mutualContacts:
                    return section === "true" ? qsTr("Trusted Contacts") : qsTr("Contacts")
                case Constants.contactsPanelUsage.blockedContacts:
                default:
                    return ""
                }
            }
        }
        section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart

        header: NoFriendsRectangle {
            width: ListView.view.width
            visible: ListView.view.count === 0
            inviteButtonVisible: searchBox.text === ""
        }

        searchString: searchBox.text
        onOpenContactContextMenu: root.openContextMenu(contactsModel, publicKey)
        onSendMessageActionTriggered: root.contactsStore.joinPrivateChat(publicKey)
        onContactRequestAccepted: root.contactsStore.acceptContactRequest(publicKey, "")
        onContactRequestRejected: root.contactsStore.dismissContactRequest(publicKey, "")

        Component {
            id: sendContactRequestComponent
            SendContactRequestModal {
                contactsStore: root.contactsStore
                onClosed: destroy()
            }
        }

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
    }

    component SectionComponent: Rectangle {
        required property string section
        property alias text: sectionText.text

        width: ListView.view.width
        height: sectionText.implicitHeight
        color: Theme.palette.statusListItem.backgroundColor

        StatusBaseText {
            id: sectionText
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            topPadding: Theme.halfPadding
            bottomPadding: Theme.halfPadding

            color: Theme.palette.baseColor1
            font.pixelSize: Theme.additionalTextSize
            font.weight: Font.Medium
            elide: Text.ElideRight
        }
    }
}
