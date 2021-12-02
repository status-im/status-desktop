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

    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule

    // Not Refactored
   property var messageStore

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
        sourceComponent: chatCommunitySectionModule.isCommunity()? communtiyColumnComponent : contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        rootStore: root.rootStore
        //chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount

        onOpenAppSearch: {
            root.openAppSearch()
        }
    }

    showRightPanel: (localAccountSensitiveSettings.expandUsersList && (localAccountSensitiveSettings.showOnlineUsers || chatsModel.communities.activeCommunity.active)
                    && (chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne))
    rightPanel: localAccountSensitiveSettings.communitiesEnabled && chatCommunitySectionModule.isCommunity()? communityUserListComponent : userListComponent

    Component {
        id: communityUserListComponent
        CommunityUserListPanel {
            //Not Refactored Yet
            //currentTime: chatColumn.currentTime
            messageContextMenu: quickActionMessageOptionsMenu
//            profilePubKey: userProfile.pubKey
//            community: root.rootStore.chatsModelInst.communities.activeCommunity
//            currentUserName: Utils.removeStatusEns(root.rootStore.profileModelInst.ens.preferredUsername
//                                                  || root.rootStore.profileModelInst.profile.username)
//            currentUserOnline: root.store.userProfileInst.userStatus
//            contactsList: root.rootStore.allContacts
        }
    }

    Component {
        id: userListComponent
        UserListPanel {
            //Not Refactored Yet
            //currentTime: chatColumn.currentTime
            //userList: chatColumn.userList
            messageContextMenu: quickActionMessageOptionsMenu
//            profilePubKey: userProfile.pubKey
//            contactsList: root.rootStore.allContacts
//            isOnline: root.rootStore.chatsModelInst.isOnline
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
            //pinnedMessagesPopupComponent: chatColumn.pinnedMessagesPopupComponent
        }
    }

    Component {
        id: groupInfoPopupComponent
        GroupInfoPopup {
            // Not Refactored
            store: root.rootStore
            //pinnedMessagesPopupComponent: chatColumn.pinnedMessagesPopupComponent
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
