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
    property var createChatPropertiesStore
    property var sectionItemModel

    property var emojiPopup
    property var stickersPopup
    property bool stickersLoaded: false

    readonly property var chatContentModule: root.rootStore.currentChatContentModule() || null
    readonly property bool viewOnlyPermissionsSatisfied: chatContentModule.viewOnlyPermissionsSatisfied
    readonly property bool viewAndPostPermissionsSatisfied: chatContentModule.viewAndPostPermissionsSatisfied
    property bool hasViewOnlyPermissions: false
    property bool hasViewAndPostPermissions: false
    property bool amIMember: false
    property bool amISectionAdmin: false

    property bool isInvitationPending: false

    property var viewOnlyPermissionsModel
    property var viewAndPostPermissionsModel
    property var assetsModel
    property var collectiblesModel

    readonly property bool contentLocked: {
        if (!rootStore.chatCommunitySectionModule.isCommunity()) {
            return false
        }
        if (!amIMember) {
            return hasViewAndPostPermissions || hasViewOnlyPermissions
        }
        if (amISectionAdmin) {
            return false
        }
        if (!hasViewAndPostPermissions && hasViewOnlyPermissions) {
            return !viewOnlyPermissionsSatisfied
        }
        if (hasViewAndPostPermissions && !hasViewOnlyPermissions) {
            return !viewAndPostPermissionsSatisfied
        }
        if (hasViewOnlyPermissions && hasViewAndPostPermissions) {
            return !viewOnlyPermissionsSatisfied && !viewAndPostPermissionsSatisfied
        }
        return false
    }

    signal communityInfoButtonClicked()
    signal communityManageButtonClicked()
    signal profileButtonClicked()
    signal openAppSearch()

    signal revealAddressClicked
    signal invitationPendingClicked

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

    onNotificationButtonClicked: Global.openActivityCenterPopup()
    notificationCount: activityCenterStore.unreadNotificationsCount
    hasUnseenNotifications: activityCenterStore.hasUnseenNotifications

    headerContent: Loader {
        id: headerContentLoader
        sourceComponent: root.contentLocked ? joinCommunityHeaderPanelComponent : chatHeaderContentViewComponent
    }

    leftPanel: Loader {
        id: contactColumnLoader
        sourceComponent: root.rootStore.chatCommunitySectionModule.isCommunity()?
                             communtiyColumnComponent :
                             contactsColumnComponent
    }

    centerPanel: Loader {
        anchors.fill: parent
        sourceComponent: root.contentLocked ? joinCommunityCenterPanelComponent : chatColumnViewComponent
    }

    showRightPanel: {
        if (root.contentLocked) {
            return false
        }

        if (root.rootStore.openCreateChat ||
           !localAccountSensitiveSettings.showOnlineUsers ||
           !localAccountSensitiveSettings.expandUsersList) {
            return false
        }

        let chatContentModule = root.rootStore.currentChatContentModule()
        if (!chatContentModule) {
            return false
        }
        // Check if user list is available as an option for particular chat content module
        return chatContentModule.chatDetails.isUsersListAvailable
    }

    rightPanel: Component {
        id: userListComponent
        UserListPanel {
            anchors.fill: parent
            store: root.rootStore
            label: qsTr("Members")
            usersModel: {
                let chatContentModule = root.rootStore.currentChatContentModule()
                if (!chatContentModule || !chatContentModule.usersModule) {
                    // New communities have no chats, so no chatContentModule
                    return null
                }
                return chatContentModule.usersModule.model
            }
        }
    }

    Component {
        id: chatHeaderContentViewComponent
        ChatHeaderContentView {
            visible: !!root.rootStore.currentChatContentModule()
            rootStore: root.rootStore
            emojiPopup: root.emojiPopup
            onSearchButtonClicked: root.openAppSearch()
        }
    }

    Component {
        id: joinCommunityHeaderPanelComponent
        JoinCommunityHeaderPanel {
            readonly property var chatContentModule: root.rootStore.currentChatContentModule() || null
            joinCommunity: false
            color: chatContentModule.chatDetails.color
            channelName: chatContentModule.chatDetails.name
            channelDesc: chatContentModule.chatDetails.description
        }
    }

    Component {
        id: chatColumnViewComponent

        ChatColumnView {
            parentModule: root.rootStore.chatCommunitySectionModule
            rootStore: root.rootStore
            createChatPropertiesStore: root.createChatPropertiesStore
            contactsStore: root.contactsStore
            stickersLoaded: root.stickersLoaded
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            viewAndPostHoldingsModel: root.viewAndPostPermissionsModel
            viewAndPostPermissionsSatisfied: !root.rootStore.chatCommunitySectionModule.isCommunity() || root.amISectionAdmin || root.viewAndPostPermissionsSatisfied
            amISectionAdmin: root.amISectionAdmin
            onOpenStickerPackPopup: {
                Global.openPopup(statusStickerPackClickPopup, {packId: stickerPackId, store: root.stickersPopup.store} )
            }
        }
    }

    Component {
        id: joinCommunityCenterPanelComponent

        JoinCommunityCenterPanel {
            joinCommunity: false
            name: sectionItemModel.name
            channelName: root.chatContentModule.chatDetails.name
            viewOnlyHoldingsModel: root.viewOnlyPermissionsModel
            viewAndPostHoldingsModel: root.viewAndPostPermissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            isInvitationPending: root.isInvitationPending
            requiresRequest: !root.amIMember
            requirementsMet: (viewOnlyPermissionsSatisfied && viewOnlyPermissionsModel.count > 0) ||
                             (viewAndPostPermissionsSatisfied && viewAndPostPermissionsModel.count > 0)
            onRevealAddressClicked: root.revealAddressClicked()
            onInvitationPendingClicked: root.invitationPendingClicked()
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
            onAddRemoveGroupMemberClicked: {
                if (headerContentLoader.item && headerContentLoader.item instanceof ChatHeaderContentView) {
                    headerContentLoader.item.addRemoveGroupMember()
                }
            }
        }
    }

    Component {
        id: communtiyColumnComponent
        CommunityColumnView {
            communitySectionModule: root.rootStore.chatCommunitySectionModule
            communityData: sectionItemModel
            store: root.rootStore
            emojiPopup: root.emojiPopup
            hasAddedContacts: root.hasAddedContacts
            onInfoButtonClicked: root.communityInfoButtonClicked()
            onManageButtonClicked: root.communityManageButtonClicked()
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
}
