import QtQuick 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "views"
import "panels"
import "panels/communities"
import "popups"
import "helpers"
import "controls"
import "stores"

import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

StatusAppThreePanelLayout {
    id: root

    handle: SplitViewHandle { implicitWidth: 5 }

    property var store

    // Not Refactored
//    property var messageStore

    // Not Refactored
   property RootStore rootStore: RootStore {
       messageStore: root.messageStore
   }

    // Not Refactored
//    property alias chatColumn: chatColumn
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
        sourceComponent: store.isCommunity()? communtiyColumnComponent : contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        rootStore: root.rootStore
        chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount

        onOpenAppSearch: {
            root.openAppSearch()
        }
    }

    showRightPanel: (localAccountSensitiveSettings.expandUsersList && (localAccountSensitiveSettings.showOnlineUsers || chatsModel.communities.activeCommunity.active)
                    && (chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne))
    rightPanel: localAccountSensitiveSettings.communitiesEnabled && chatsModel.communities.activeCommunity.active ? communityUserListComponent : userListComponent

    Component {
        id: communityUserListComponent
        CommunityUserListPanel {
            currentTime: chatColumn.currentTime
            messageContextMenu: quickActionMessageOptionsMenu
            contactsList: root.rootStore.allContacts

            // Not Refactored
//            profilePubKey: root.rootStore.profileModelInst.profile.pubKey
//            community: root.rootStore.chatsModelInst.communities.activeCommunity
//            currentUserName: Utils.removeStatusEns(root.rootStore.profileModelInst.ens.preferredUsername
//                                                  || root.rootStore.profileModelInst.profile.username)
//            currentUserOnline: root.rootStore.profileModelInst.profile.sendUserStatus
        }
    }

    Component {
        id: userListComponent
        UserListPanel {
            currentTime: chatColumn.currentTime
            userList: chatColumn.userList
            messageContextMenu: quickActionMessageOptionsMenu
            contactsList: root.rootStore.allContacts
            // Not Refactored
//            profilePubKey: root.rootStore.profileModelInst.profile.pubKey
//            isOnline: root.rootStore.chatsModelInst.isOnline
        }
    }

    Component {
        id: contactsColumnComponent
        ContactsColumnView {
            // Not Refactored
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
            store: root.store
            pinnedMessagesPopupComponent: chatColumn.pinnedMessagesPopupComponent
        }
    }

    Component {
        id: groupInfoPopupComponent
        GroupInfoPopup {
            // Not Refactored
            store: root.rootStore
            pinnedMessagesPopupComponent: chatColumn.pinnedMessagesPopupComponent
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
            if (root.rootStore.contactsModuleInst.model.isAdded(chatColumn.contactToRemove)) {
                root.rootStore.contactsModuleInst.model.removeContact(chatColumn.contactToRemove)
            }
            removeContactConfirmationDialog.parentPopup.close();
            removeContactConfirmationDialog.close();
        }
    }

    MessageContextMenuView {
        id: quickActionMessageOptionsMenu
        // Not Refactored
       store: root.rootStore
//        reactionModel: root.rootStore.emojiReactionsModel
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25;height:770;width:1152}
}
##^##*/
