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
import StatusQ.Controls 0.1

import "."
import "../panels"
import "../panels/communities"
import "../popups"
import "../helpers"
import "../controls"
import "../stores"

StatusSectionLayout {
    id: root

    property var contactsStore
    property bool hasAddedContacts: root.contactsStore.myContactsModel.count > 0

    property RootStore rootStore
    property var chatContentModule: root.rootStore.currentChatContentModule()

    property Component pinnedMessagesListPopupComponent
    property Component membershipRequestPopup
    property var emojiPopup
    property bool stickersLoaded: false

    signal communityInfoButtonClicked()
    signal communityManageButtonClicked()
    signal profileButtonClicked()
    signal openAppSearch()
    signal importCommunityClicked()
    signal createCommunityClicked()

    Connections {
        target: root.rootStore.stickersStore.stickersModule

        function onStickerPacksLoaded() {
            root.stickersLoaded = true;
        }
    }

    Connections {
        target: root.rootStore.chatCommunitySectionModule
        ignoreUnknownSignals: true

        function onActiveItemChanged() {
            Global.closeCreateChatView()
            groupChatLoader.active = false;
        }
    }

    notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList && headerContent.membersButton.visible ? 0 : 14
    notificationButton.highlighted: activityCenter.visible
    onNotificationButtonClicked: Global.openActivityCenterPopup()
    notificationCount: root.rootStore.unreadNotificationsCount

    headerContent: ChatHeaderContentView {
        id: headerContent
        visible: (!!root.rootStore.currentChatContentModule() && !groupChatLoader.active)
        rootStore: root.rootStore
        chatContentModule: root.chatContentModule
        onSearchButtonClicked: root.openAppSearch()
        onAddRemoveGroupMemberClicked: groupChatLoader.active = true;
    }

    leftPanel: Loader {
        id: contactColumnLoader
        sourceComponent: root.rootStore.chatCommunitySectionModule.isCommunity()?
                             communtiyColumnComponent :
                             contactsColumnComponent
    }

    centerPanel: ChatColumnView {
        id: chatColumn
        anchors.fill: parent
        parentModule: root.rootStore.chatCommunitySectionModule
        rootStore: root.rootStore
        contactsStore: root.contactsStore
        pinnedMessagesListPopupComponent: root.pinnedMessagesListPopupComponent
        stickersLoaded: root.stickersLoaded
        emojiPopup: root.emojiPopup
        onOpenStickerPackPopup: {
            Global.openPopup(statusStickerPackClickPopup, {packId: stickerPackId} )
        }
        onOpenAppSearch: {
            root.openAppSearch();
        }
        Loader {
            id: groupChatLoader
            anchors.fill: parent
            active: false
            anchors {
                leftMargin: Style.current.padding
                rightMargin: (headerContent.height + Style.current.padding)
                //move a bit up as we still need the activity button
                topMargin: -(headerContent.height + Style.current.halfPadding)
                bottomMargin: Style.current.halfPadding
            }
            sourceComponent: GroupChatPanel {
                anchors.fill: parent
                maxHeight: parent.height
                rootStore: root.rootStore
                chatContentModule: root.chatContentModule
                sectionModule: root.rootStore.chatCommunitySectionModule
                onPanelClosed: { groupChatLoader.active = false; }
            }
        }
        Keys.onEscapePressed: { groupChatLoader.active = false; }
    }

    showRightPanel: {
        if (root.rootStore.openCreateChat ||
           !localAccountSensitiveSettings.showOnlineUsers ||
           !localAccountSensitiveSettings.expandUsersList) {
            return false
        }

        let chatContentModule = root.rootStore.currentChatContentModule()
        if (!chatContentModule
            || chatContentModule.chatDetails.type === Constants.chatType.publicChat)
        {
            // New communities have no chats, so no chatContentModule or it is a public chat
            return false
        }
        // Check if user list is available as an option for particular chat content module
        return chatContentModule.chatDetails.isUsersListAvailable
    }

    rightPanel: Component {
        id: userListComponent
        UserListPanel {
            rootStore: root.rootStore
            label: qsTr("Members")
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
            emojiPopup: root.emojiPopup
            onOpenProfileClicked: {
                root.profileButtonClicked();
            }

            onOpenAppSearch: {
                root.openAppSearch()
            }
            onImportCommunityClicked: {
                root.importCommunityClicked();
            }
            onCreateCommunityClicked: {
                root.createCommunityClicked();
            }
        }
    }

    Component {
        id: communtiyColumnComponent
        CommunityColumnView {
            communitySectionModule: root.rootStore.chatCommunitySectionModule
            store: root.rootStore
            emojiPopup: root.emojiPopup
            hasAddedContacts: root.hasAddedContacts
            pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
            membershipRequestPopup: root.membershipRequestPopup
            onInfoButtonClicked: root.communityInfoButtonClicked()
            onManageButtonClicked: root.communityManageButtonClicked()
        }
    }

    Component {
        id: groupInfoPopupComponent
        GroupInfoPopup {
            chatSectionModule: root.rootStore.chatCommunitySectionModule
            store: root.rootStore
        }
    }

    Component {
        id: statusStickerPackClickPopup
        StatusStickerPackClickPopup{
            store: root.rootStore
            onClosed: {
                destroy();
            }
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        // % "Remove contact"
        header.title: qsTr("Remove contact")
        confirmationText: qsTr("Are you sure you want to remove this contact?")
        onConfirmButtonClicked: {
            let pk = chatColumn.contactToRemove
            if (Utils.getContactDetailsAsJson(pk).isAdded) {
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
            Global.openProfilePopup(publicKey, null, state)
        }
        onCreateOneToOneChat: {
            Global.changeAppSectionBySectionType(Constants.appSection.chat)
            root.rootStore.chatCommunitySectionModule.createOneToOneChat(communityId, chatId, ensName)
        }
    }

    Component.onCompleted: {
        rootStore.groupInfoPopupComponent = groupInfoPopupComponent;
    }

    ActivityCenterPopup {
        id: activityCenter
        y: 56
        height: (root.height - 56) * 2 // TODO get screen size // Taken from old code top bar height was fixed there to 56
        store: root.rootStore
        chatSectionModule: root.rootStore.currentChatContentModule()
        messageContextMenu: MessageContextMenuView {
            id: contextmenu
            store: root.rootStore
            reactionModel: root.rootStore.emojiReactionsModel
        }
    }
}
