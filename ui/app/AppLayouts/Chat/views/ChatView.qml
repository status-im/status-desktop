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
        }
    }

    notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList && headerContent.membersButton.visible ? 0 : 14
    onNotificationButtonClicked: Global.openActivityCenterPopup()
    notificationCount: activityCenterStore.unreadNotificationsCount

    headerContent: ChatHeaderContentView {
        id: headerContent
        visible: !!root.rootStore.currentChatContentModule()
        rootStore: root.rootStore
        emojiPopup: root.emojiPopup
        onSearchButtonClicked: root.openAppSearch()
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
        stickersLoaded: root.stickersLoaded
        emojiPopup: root.emojiPopup
        onOpenStickerPackPopup: {
            Global.openPopup(statusStickerPackClickPopup, {packId: stickerPackId} )
        }
        onOpenAppSearch: {
            root.openAppSearch();
        }
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
            label: qsTr("Members")
            messageContextMenu: quickActionMessageOptionsMenu
            usersModel: {
                let chatContentModule = root.rootStore.currentChatContentModule()
                if (!chatContentModule || !chatContentModule.usersModule) {
                    // New communities have no chats, so no chatContentModule
                    return 0
                }
                return chatContentModule.usersModule.model
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
            membershipRequestPopup: root.membershipRequestPopup
            onInfoButtonClicked: root.communityInfoButtonClicked()
            onManageButtonClicked: root.communityManageButtonClicked()
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

    MessageContextMenuView {
        id: quickActionMessageOptionsMenu
        store: root.rootStore

        onOpenProfileClicked: {
            Global.openProfilePopup(publicKey, null)
        }
        onCreateOneToOneChat: {
            Global.changeAppSectionBySectionType(Constants.appSection.chat)
            root.rootStore.chatCommunitySectionModule.createOneToOneChat(communityId, chatId, ensName)
        }
    }
}
