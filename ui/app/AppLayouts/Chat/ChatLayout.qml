import QtQuick 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.views.chat 1.0

import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

import "views"
import "panels"
import "panels/communities"
import "popups"
import "helpers"
import "controls"
import "stores"

StatusAppThreePanelLayout {
    id: root

    handle: SplitViewHandle { implicitWidth: 5 }

    property var contactsStore
    property bool hasAddedContacts: root.contactsStore.myContactsModel.count > 0

    // Not Refactored
   property var messageStore

   property RootStore rootStore: RootStore {
      contactsStore: root.contactsStore
   }

    property Component pinnedMessagesListPopupComponent
    property bool stickersLoaded: false
    signal profileButtonClicked()
    signal openAppSearch()

    // Not Refactored
//    Connections {
//        target: root.rootStore.chatsModelInst.stickers
//        onStickerPacksLoaded: {
//            stickersLoaded = true;
//        }
//    }

//    property var onActivated: function () {
//        root.rootStore.chatsModelInst.channelView.restorePreviousActiveChannel();
//        chatColumn.onActivated();
//    }

    leftPanel: Loader {
        id: contactColumnLoader
        sourceComponent: root.rootStore.chatCommunitySectionModule.isCommunity()?
                             communtiyColumnComponent :
                             contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        parentModule: root.rootStore.chatCommunitySectionModule
        rootStore: root.rootStore
        contactsStore: root.contactsStore
        chatSectionModule: root.rootStore.chatCommunitySectionModule
        pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
        stickersLoaded: root.stickersLoaded
        //chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount
        onOpenStickerPackPopup: {
            Global.openPopup(statusStickerPackClickPopup, {packId: stickerPackId} )
        }
        onOpenAppSearch: {
            root.openAppSearch()
        }
    }

    showRightPanel: {
        if (!localAccountSensitiveSettings.showOnlineUsers || !localAccountSensitiveSettings.expandUsersList) {
            return false
        }
        let chatContentModule = root.rootStore.currentChatContentModule()
        if (!chatContentModule) {
            // New communities have no chats, so no chatContentModule
            return false
        }
        // Check if user list is available as an option for particular chat content module
        return chatContentModule.chatDetails.isUsersListAvailable
    }

    rightPanel: userListComponent

    Component {
        id: userListComponent
        UserListPanel {
            label: localAccountSensitiveSettings.communitiesEnabled &&
                root.rootStore.chatCommunitySectionModule.isCommunity() ?
                //% "Members"
                qsTrId("members-label") :
                qsTr("Last seen")
            messageContextMenu: quickActionMessageOptionsMenu
            usersModule: {
                let chatContentModule = root.rootStore.currentChatContentModule()
                if (!chatContentModule || !chatContentModule.usersModule) {
                    // New communities have no chats, so no chatContentModule
                    return {}
                }
                return chatContentModule.usersModule
            }
        }
    }

    Component {
        id: contactsColumnComponent
        ContactsColumnView {
            chatSectionModule: root.rootStore.chatCommunitySectionModule
            store: root.rootStore
            contactsStore: root.contactsStore
            onOpenProfileClicked: {
                root.profileButtonClicked();
            }

            onOpenAppSearch: {
                root.openAppSearch()
            }
        }
    }

    Component {
        id: communtiyColumnComponent
        CommunityColumnView {
            communitySectionModule: root.rootStore.chatCommunitySectionModule
            store: root.rootStore
            hasAddedContacts: root.hasAddedContacts
            pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
        }
    }

    Component {
        id: groupInfoPopupComponent
        GroupInfoPopup {
            chatSectionModule: root.rootStore.chatCommunitySectionModule
            store: root.rootStore
            pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
        }
    }

    Component {
        id: statusStickerPackClickPopup
        StatusStickerPackClickPopup{
            onClosed: {
                destroy();
            }
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        // % "Remove contact"
        header.title: qsTrId("remove-contact")
        //% "Are you sure you want to remove this contact?"
        confirmationText: qsTrId("are-you-sure-you-want-to-remove-this-contact-")
        onConfirmButtonClicked: {
            let pk = chatColumn.contactToRemove
            if (Utils.getContactDetailsAsJson(pk).isContact) {
                root.contactsStore.removeContact(pk)
            }
            removeContactConfirmationDialog.parentPopup.close();
            removeContactConfirmationDialog.close();
        }
    }

    MessageContextMenuView {
        id: quickActionMessageOptionsMenu
        store: root.rootStore

        onOpenProfileClicked: {
            Global.openProfilePopup(publicKey)
        }
        onCreateOneToOneChat: {
            Global.changeAppSectionBySectionType(Constants.appSection.chat)
            root.rootStore.chatCommunitySectionModule.createOneToOneChat(chatId, ensName)
        }
    }
}
