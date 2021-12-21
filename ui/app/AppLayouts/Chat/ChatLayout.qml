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

    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule
    // Since qml component doesn't follow encaptulation from the backend side, we're introducing
    // a method which will return appropriate chat content module for selected chat/channel
    function currentChatContentModule(){
        // When we decide to have the same struct as it's on the backend we will remove this function.
        // So far this is a way to deal with refactord backend from the current qml structure.
        if(chatCommunitySectionModule.activeItem.isSubItemActive)
            chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.activeSubItem.id)
        else
            chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.id)

        return chatCommunitySectionModule.getChatContentModule()
    }

    // Not Refactored
   property var messageStore

    // Not Refactored
   property RootStore rootStore: RootStore {
       messageStore: root.messageStore
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
        sourceComponent: chatCommunitySectionModule.isCommunity()? communtiyColumnComponent : contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        parentModule: chatCommunitySectionModule
        rootStore: root.rootStore
        pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
        //chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount

        onOpenAppSearch: {
            root.openAppSearch()
        }
    }

    showRightPanel: {
        // Check if user list is available as an option for particular chat content module.
        let usersListAvailable = currentChatContentModule().chatDetails.isUsersListAvailable
        return localAccountSensitiveSettings.showOnlineUsers && usersListAvailable && localAccountSensitiveSettings.expandUsersList
    }

    rightPanel: localAccountSensitiveSettings.communitiesEnabled && chatCommunitySectionModule.isCommunity()? communityUserListComponent : userListComponent

    Component {
        id: communityUserListComponent
        CommunityUserListPanel {
            messageContextMenu: quickActionMessageOptionsMenu
            usersModule: {
                let chatContentModule = currentChatContentModule()
                return chatContentModule.usersModule
            }
        }
    }

    Component {
        id: userListComponent
        UserListPanel {
            messageContextMenu: quickActionMessageOptionsMenu
            usersModule: {
                let chatContentModule = currentChatContentModule()
                return chatContentModule.usersModule
            }
        }
    }

    Component {
        id: contactsColumnComponent
        ContactsColumnView {
            chatSectionModule: root.chatCommunitySectionModule
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
            communitySectionModule: root.chatCommunitySectionModule
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

        onOpenProfileClicked: {
            openProfilePopup(displayName, publicKey, icon, "", displayName)
        }
        onCreateOneToOneChat: {
            Global.changeAppSectionBySectionType(Constants.appSection.chat)
            root.chatCommunitySectionModule.createOneToOneChat(chatId, ensName)
        }
    }
}
