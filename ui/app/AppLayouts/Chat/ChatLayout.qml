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

    // Not Refactored
   property RootStore rootStore: RootStore { }

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
        sourceComponent: root.rootStore.chatCommunitySectionModule.isCommunity()? communtiyColumnComponent : contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        rootStore: root.rootStore
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
        // Check if user list is available as an option for particular chat content module.
        let usersListAvailable = root.rootStore.currentChatContentModule().chatDetails.isUsersListAvailable
        return localAccountSensitiveSettings.showOnlineUsers && usersListAvailable && localAccountSensitiveSettings.expandUsersList
    }

    rightPanel: localAccountSensitiveSettings.communitiesEnabled && root.rootStore.chatCommunitySectionModule.isCommunity()? communityUserListComponent : userListComponent

    Component {
        id: communityUserListComponent
        CommunityUserListPanel {
            messageContextMenu: quickActionMessageOptionsMenu
            usersModule: root.rootStore.chatContentModule.usersModule
        }
    }

    Component {
        id: userListComponent
        UserListPanel {
            messageContextMenu: quickActionMessageOptionsMenu
            usersModule: root.rootStore.chatContentModule.usersModule
        }
    }

    Component {
        id: contactsColumnComponent
        ContactsColumnView {
            store: root.rootStore
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
            store: root.rootStore
            pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
        }
    }

    Component {
        id: groupInfoPopupComponent
        GroupInfoPopup {
            // Not Refactored
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
            // Not Refactored Yet
//            if (root.rootStore.contactsModuleInst.model.isAdded(chatColumn.contactToRemove)) {
//                root.rootStore.contactsModuleInst.model.removeContact(chatColumn.contactToRemove)
//            }
//            removeContactConfirmationDialog.parentPopup.close();
//            removeContactConfirmationDialog.close();
        }
    }

    MessageContextMenuView {
        id: quickActionMessageOptionsMenu
        store: root.rootStore
        // Not Refactored
//        reactionModel: root.rootStore.emojiReactionsModel

        onOpenProfileClicked: {
            Global.openProfilePopup(displayName, publicKey, icon, "", displayName)
        }
        onCreateOneToOneChat: {
            root.rootStore.chatCommunitySectionModule.createOneToOneChat(chatId, ensName);
        }
    }
}
