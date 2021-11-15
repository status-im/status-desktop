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

    property var messageStore

    property alias chatColumn: chatColumn
    property bool stickersLoaded: false
    signal profileButtonClicked()

    Connections {
        target: root.rootStore.chatsModelInst.stickers
        onStickerPacksLoaded: {
            stickersLoaded = true;
        }
    }

    property var onActivated: function () {
        root.rootStore.chatsModelInst.channelView.restorePreviousActiveChannel();
        chatColumn.onActivated();
    }
    // Not Refactored
   property RootStore rootStore: RootStore {
       messageStore: root.messageStore
   }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        searchPopup: searchPopup
        locationModel: root.rootStore.chatsModelInst.messageSearchViewController.locationMenuModel

        onItemClicked: {
            root.rootStore.chatsModelInst.messageSearchViewController.setSearchLocation(firstLevelItemValue, secondLevelItemValue)
            if(searchPopup.searchText !== "")
                searchMessages(searchPopup.searchText)
        }
    }

    property var searchMessages: Backpressure.debounce(searchPopup, 400, function (value) {
        root.rootStore.chatsModelInst.messageSearchViewController.searchMessages(value)
    })

    Connections {
        target: root.rootStore.chatsModelInst.messageSearchViewController.locationMenuModel
        onModelAboutToBeReset: {
            for (var i = 2; i <= searchPopupMenu.count; i++) {
                //clear menu
                if (!!searchPopupMenu.takeItem(i)) {
                    searchPopupMenu.removeItem(searchPopupMenu.takeItem(i));
                }
            }
        }
    }

    StatusSearchPopup {
        id: searchPopup

        noResultsLabel: qsTr("No results")
        defaultSearchLocationText: qsTr("Anywhere")

        searchOptionsPopupMenu: searchPopupMenu
        searchResults: root.rootStore.chatsModelInst.messageSearchViewController.resultModel

        formatTimestampFn: function (ts) {
            return new Date(parseInt(ts, 10)).toLocaleString(Qt.locale(localAppSettings.locale))
        }

        onSearchTextChanged: {
            searchMessages(searchPopup.searchText);
        }
        onAboutToHide: {
            if (searchPopupMenu.visible) {
                searchPopupMenu.close();
            }
        }
        onClosed: {
            searchPopupMenu.dismiss();
        }
        onOpened: {
            searchPopup.resetSearchSelection();
            searchPopup.forceActiveFocus()
            root.rootStore.chatsModelInst.messageSearchViewController.prepareLocationMenuModel()

            const jsonObj = root.rootStore.chatsModelInst.messageSearchViewController.getSearchLocationObject()

            if (!jsonObj) {
                return
            }

            let obj = JSON.parse(jsonObj)
            if (obj.location === "") {
                if(obj.subLocation === "") {
                    root.rootStore.chatsModelInst.messageSearchViewController.setSearchLocation("", "")
                }
                else {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                       "",
                                       obj.subLocation.imageSource,
                                       obj.subLocation.isIdenticon,
                                       obj.subLocation.iconName,
                                       obj.subLocation.identiconColor)

                    root.rootStore.chatsModelInst.messageSearchViewController.setSearchLocation("", obj.subLocation.value)
                }
            }
            else {
                if (obj.location.title === "Chat") {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                       "",
                                       obj.subLocation.imageSource,
                                       obj.subLocation.isIdenticon,
                                       obj.subLocation.iconName,
                                       obj.subLocation.identiconColor)

                    root.rootStore.chatsModelInst.messageSearchViewController.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
                else {
                    searchPopup.setSearchSelection(obj.location.title,
                                       obj.subLocation.text,
                                       obj.location.imageSource,
                                       obj.location.isIdenticon,
                                       obj.location.iconName,
                                       obj.location.identiconColor)

                    root.rootStore.chatsModelInst.messageSearchViewController.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
            }
        }
        onResultItemClicked: {
            searchPopup.close()

            root.rootStore.chatsModelInst.switchToSearchedItem(itemId)
        }

        onResultItemTitleClicked: {
            const pk = titleId
            const userProfileImage = appMain.getProfileImage(pk)
            return openProfilePopup(root.rootStore.chatsModelInst.userNameOrAlias(pk), pk, userProfileImage || root.rootStore.utilsModelInst.generateIdenticon(pk))
        }
    }

    leftPanel: Loader {
        id: contactColumnLoader
        sourceComponent: localAccountSensitiveSettings.communitiesEnabled && root.rootStore.chatsModelInst.communities.activeCommunity.active ? communtiyColumnComponent : contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        rootStore: root.rootStore
        chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount
    }

    showRightPanel: (localAccountSensitiveSettings.expandUsersList && (localAccountSensitiveSettings.showOnlineUsers || chatsModel.communities.activeCommunity.active)
                    && (chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne))
    rightPanel: localAccountSensitiveSettings.communitiesEnabled && chatsModel.communities.activeCommunity.active ? communityUserListComponent : userListComponent

    Component {
        id: communityUserListComponent
        CommunityUserListPanel {
            currentTime: chatColumn.currentTime
            messageContextMenu: quickActionMessageOptionsMenu
            profilePubKey: userProfile.pubKey
            community: root.rootStore.chatsModelInst.communities.activeCommunity
            currentUserName: Utils.removeStatusEns(root.rootStore.profileModelInst.ens.preferredUsername
                                                  || root.rootStore.profileModelInst.profile.username)
            currentUserOnline: root.store.userProfileInst.userStatus
            contactsList: root.rootStore.allContacts
        }
    }

    Component {
        id: userListComponent
        UserListPanel {
            currentTime: chatColumn.currentTime
            userList: chatColumn.userList
            messageContextMenu: quickActionMessageOptionsMenu
            profilePubKey: userProfile.pubKey
            contactsList: root.rootStore.allContacts
            isOnline: root.rootStore.chatsModelInst.isOnline
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
        }
    }

    Component {
        id: communtiyColumnComponent
        CommunityColumnView {
            store: root.rootStore
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
