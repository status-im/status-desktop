import QtQuick 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0

import utils 1.0
import "../../../shared"
import "../../../shared/popups"
import "../../../shared/status"
import "."
import "./data"
import "components"
import "./ChatColumn"
import "./CommunityComponents"

import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

StatusAppThreePanelLayout {
    id: chatView

    handle: SplitViewHandle { implicitWidth: 5 }

    property alias chatColumn: chatColumn
    property bool stickersLoaded: false
    signal profileButtonClicked()

    Connections {
        target: chatsModel.stickers
        onStickerPacksLoaded: {
            stickersLoaded = true;
        }
    }

    property var onActivated: function () {
        chatsModel.channelView.restorePreviousActiveChannel()
        chatColumn.onActivated()
    }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        searchPopup: searchPopup
        locationModel: chatsModel.messageSearchViewController.locationMenuModel

        onItemClicked: {
            chatsModel.messageSearchViewController.setSearchLocation(firstLevelItemValue, secondLevelItemValue)
            if(searchPopup.searchText !== "")
                searchMessages(searchPopup.searchText)
        }
    }

    property var searchMessages: Backpressure.debounce(searchPopup, 400, function (value) {
        chatsModel.messageSearchViewController.searchMessages(value)
    })

    Connections {
        target: chatsModel.messageSearchViewController.locationMenuModel
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
        searchResults: chatsModel.messageSearchViewController.resultModel

        formatTimestampFn: function (ts) {
            return new Date(parseInt(ts, 10)).toLocaleString(Qt.locale(globalSettings.locale))
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
            chatsModel.messageSearchViewController.prepareLocationMenuModel()

            const jsonObj = chatsModel.messageSearchViewController.getSearchLocationObject()

            if (!jsonObj) {
                return
            }

            let obj = JSON.parse(jsonObj)
            if (obj.location === "") {
                if(obj.subLocation === "") {
                    chatsModel.messageSearchViewController.setSearchLocation("", "")
                }
                else {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                       "",
                                       obj.subLocation.imageSource,
                                       obj.subLocation.isIdenticon,
                                       obj.subLocation.iconName,
                                       obj.subLocation.identiconColor)

                    chatsModel.messageSearchViewController.setSearchLocation("", obj.subLocation.value)
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

                    chatsModel.messageSearchViewController.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
                else {
                    searchPopup.setSearchSelection(obj.location.title,
                                       obj.subLocation.text,
                                       obj.location.imageSource,
                                       obj.location.isIdenticon,
                                       obj.location.iconName,
                                       obj.location.identiconColor)

                    chatsModel.messageSearchViewController.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
            }
        }
        onResultItemClicked: {
            searchPopup.close()

            chatsModel.switchToSearchedItem(itemId)
        }

        onResultItemTitleClicked: {
            const pk = titleId
            const userProfileImage = appMain.getProfileImage(pk)
            return openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
        }
    }

    leftPanel: Loader {
        id: contactColumnLoader
        sourceComponent: appSettings.communitiesEnabled && chatsModel.communities.activeCommunity.active ? communtiyColumnComponent : contactsColumnComponent
    }

    centerPanel: ChatColumn {
        id: chatColumn
        chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount
    }

    showRightPanel: (appSettings.expandUsersList && (appSettings.showOnlineUsers || chatsModel.communities.activeCommunity.active)
                    && (chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne))
    rightPanel: appSettings.communitiesEnabled && chatsModel.communities.activeCommunity.active ? communityUserListComponent : userListComponent

    Component {
        id: communityUserListComponent
        CommunityUserList { currentTime: chatColumn.currentTime; messageContextMenu: quickActionMessageOptionsMenu }
    }

    Component {
        id: userListComponent
        UserList { currentTime: chatColumn.currentTime; userList: chatColumn.userList; messageContextMenu: quickActionMessageOptionsMenu}
    }

    Component {
        id: contactsColumnComponent
        ContactsColumn {
            onOpenProfileClicked: {
                chatView.profileButtonClicked();
            }
        }
    }

    Component {
        id: communtiyColumnComponent
        CommunityColumn {
            pinnedMessagesPopupComponent: chatColumn.pinnedMessagesPopupComponent
        }
    }

    Component {
        id: groupInfoPopupComponent
        GroupInfoPopup {
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
            if (profileModel.contacts.isAdded(chatColumn.contactToRemove)) {
                profileModel.contacts.removeContact(chatColumn.contactToRemove)
            }
            removeContactConfirmationDialog.parentPopup.close();
            removeContactConfirmationDialog.close();
        }
    }

    MessageContextMenu {
        id: quickActionMessageOptionsMenu
        reactionModel: EmojiReactions { }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25;height:770;width:1152}
}
##^##*/
