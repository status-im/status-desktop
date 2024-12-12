import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores
import shared.views.chat 1.0
import shared.stores.send 1.0 as SendStores
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.stores 1.0 as CommunitiesStores
import AppLayouts.Communities.views 1.0

import AppLayouts.Profile.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

import AppLayouts.Chat.stores 1.0 as ChatStores

import "../controls"
import "../helpers"
import "../panels"
import "../popups"

StatusSectionLayout {
    id: root

    property ContactsStore contactsStore
    property SharedStores.RootStore sharedRootStore
    property SharedStores.UtilsStore utilsStore
    property ChatStores.RootStore rootStore
    property ChatStores.CreateChatPropertiesStore createChatPropertiesStore
    property CommunitiesStores.CommunitiesStore communitiesStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property SharedStores.CurrenciesStore currencyStore

    property var mutualContactsModel

    property var sectionItemModel
    property int joinedMembersCount
    property bool areTestNetworksEnabled

    property var emojiPopup
    property var stickersPopup
    property bool stickersLoaded: false

    readonly property var chatContentModule: rootStore.currentChatContentModule() || null
    readonly property bool canView: chatContentModule.chatDetails.canView
    readonly property bool canPost: chatContentModule.chatDetails.canPost
    readonly property bool missingEncryptionKey: chatContentModule.chatDetails.missingEncryptionKey

    property bool hasViewOnlyPermissions: false
    property bool hasUnrestrictedViewOnlyPermission: false

    property bool hasViewAndPostPermissions: false
    property bool amIMember: false
    property bool amISectionAdmin: false
    readonly property bool allChannelsAreHiddenBecauseNotPermitted: rootStore.allChannelsAreHiddenBecauseNotPermitted

    property int requestToJoinState: Constants.RequestToJoinState.None

    property var viewOnlyPermissionsModel
    property var viewAndPostPermissionsModel
    property var assetsModel
    property var collectiblesModel

    property bool sendViaPersonalChatEnabled
    property bool paymentRequestFeatureEnabled

    readonly property bool contentLocked: {
        if (!rootStore.chatCommunitySectionModule.isCommunity()) {
            return false
        }
        if (!amIMember) {
            if (hasUnrestrictedViewOnlyPermission)
                return false

            return hasViewAndPostPermissions || hasViewOnlyPermissions
        }
        if (amISectionAdmin) {
            return false
        }
        if (!hasViewAndPostPermissions && hasViewOnlyPermissions) {
            return !canView
        }
        if (hasViewAndPostPermissions && !hasViewOnlyPermissions) {
            return !canPost
        }
        if (hasViewOnlyPermissions && hasViewAndPostPermissions) {
            return !canView && !canPost
        }
        return false
    }

    // Community transfer ownership related props:
    required property bool isPendingOwnershipRequest
    signal finaliseOwnershipClicked

    signal communityInfoButtonClicked()
    signal communityManageButtonClicked()
    signal profileButtonClicked()
    signal openAppSearch()

    signal requestToJoinClicked
    signal invitationPendingClicked

    signal buyStickerPackRequested(string packId, int price)
    signal tokenPaymentRequested(string recipientAddress, string symbol, string rawAmount, int chainId)

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
        visible: !root.allChannelsAreHiddenBecauseNotPermitted
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
        sourceComponent: (root.allChannelsAreHiddenBecauseNotPermitted || root.contentLocked) ?
                             joinCommunityCenterPanelComponent : chatColumnViewComponent
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

        if (!root.chatContentModule) {
            return false
        }
        // Check if user list is available as an option for particular chat content module
        return root.chatContentModule.chatDetails.isUsersListAvailable
    }

    rightPanel: Component {
        id: userListComponent
        UserListPanel {
            readonly property var usersStore: ChatStores.UsersStore {
                usersModule: !!root.chatContentModule ? root.chatContentModule.usersModule : null
                chatDetails: !!root.chatContentModule ? root.chatContentModule.chatDetails : null
                chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            }

            anchors.fill: parent

            chatType: root.chatContentModule.chatDetails.type
            isAdmin: root.chatContentModule.amIChatAdmin()

            label: qsTr("Members")
            communityMemberReevaluationStatus: root.rootStore.communityMemberReevaluationStatus

            usersModel: SortFilterProxyModel {
                sourceModel: usersStore.usersModel

                proxyRoles: FastExpressionRole {
                    name: "emojiHash"
                    expression: root.utilsStore.getEmojiHash(model.pubKey)
                    expectedRoles: ["pubKey"]
                }
            }

            onOpenProfileRequested: Global.openProfilePopup(pubKey, null)
            onReviewContactRequestRequested: Global.openReviewContactRequestPopup(pubKey, null)
            onSendContactRequestRequested: Global.openContactRequestPopup(pubKey, null)
            onEditNicknameRequested: Global.openNicknamePopupRequested(pubKey, null)
            onBlockContactRequested: Global.blockContactRequested(pubKey)
            onUnblockContactRequested: Global.unblockContactRequested(pubKey)
            onMarkAsUntrustedRequested: Global.markAsUntrustedRequested(pubKey)
            onRemoveContactRequested: Global.removeContactRequested(pubKey)

            onRemoveNicknameRequested: {
                const oldName = ModelUtils.getByKey(usersModel, "pubKey", pubKey, "localNickname")
                root.contactsStore.changeContactNickname(pubKey, "", oldName, true)
            }

            onCreateOneToOneChatRequested: {
                Global.changeAppSectionBySectionType(Constants.appSection.chat)
                root.rootStore.chatCommunitySectionModule.createOneToOneChat("", pubKey, "")
            }

            onRemoveTrustStatusRequested: root.contactsStore.removeTrustStatus(pubKey)
            onRemoveContactFromGroupRequested: root.rootStore.removeMemberFromGroupChat(pubKey)

            onMarkAsTrustedRequested: Global.openMarkAsIDVerifiedPopup(pubKey, null)
            onRemoveTrustedMarkRequested: Global.openRemoveIDVerificationDialog(pubKey, null)
        }
    }

    Component {
        id: chatHeaderContentViewComponent
        ChatHeaderContentView {
            visible: !!root.rootStore.currentChatContentModule()

            rootStore: root.rootStore
            mutualContactsModel: root.mutualContactsModel
            emojiPopup: root.emojiPopup

            onSearchButtonClicked: root.openAppSearch()
            onDisplayEditChannelPopup: {
                Global.openPopup(contactColumnLoader.item.createChannelPopup, {
                    isEdit: true,
                    chatId: chatId,
                    channelName: chatName,
                    channelDescription: chatDescription,
                    channelEmoji: chatEmoji,
                    channelColor: chatColor,
                    categoryId: chatCategoryId,
                    channelPosition: channelPosition,
                    deleteChatConfirmationDialog: deleteDialog,
                    hideIfPermissionsNotMet: hideIfPermissionsNotMet
                });
            }
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
            sharedRootStore: root.sharedRootStore
            utilsStore: root.utilsStore
            rootStore: root.rootStore
            areTestNetworksEnabled: root.areTestNetworksEnabled
            createChatPropertiesStore: root.createChatPropertiesStore
            contactsStore: root.contactsStore
            stickersLoaded: root.stickersLoaded
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            viewAndPostHoldingsModel: root.viewAndPostPermissionsModel
            canPost: !root.rootStore.chatCommunitySectionModule.isCommunity() || root.canPost
            amISectionAdmin: root.amISectionAdmin
            sendViaPersonalChatEnabled: root.sendViaPersonalChatEnabled
            paymentRequestFeatureEnabled: root.paymentRequestFeatureEnabled
            onOpenStickerPackPopup: {
                Global.openPopup(statusStickerPackClickPopup, {packId: stickerPackId, store: root.stickersPopup.store} )
            }
            onTokenPaymentRequested: root.tokenPaymentRequested(recipientAddress, symbol, rawAmount, chainId)
        }
    }

    Component {
        id: joinCommunityCenterPanelComponent

        JoinCommunityCenterPanel {
            joinCommunity: false
            allChannelsAreHiddenBecauseNotPermitted: root.allChannelsAreHiddenBecauseNotPermitted
            name: sectionItemModel.name
            channelName: root.chatContentModule.chatDetails.name
            viewOnlyHoldingsModel: root.viewOnlyPermissionsModel
            viewAndPostHoldingsModel: root.viewAndPostPermissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            requestToJoinState: root.requestToJoinState
            requiresRequest: !root.amIMember
            requirementsMet: root.missingEncryptionKey ||
                             (root.canView && viewOnlyPermissionsModel.count > 0) ||
                             (root.canPost && viewAndPostPermissionsModel.count > 0)
            requirementsCheckPending: root.chatContentModule.permissionsCheckOngoing
            missingEncryptionKey: root.missingEncryptionKey
            onRequestToJoinClicked: root.requestToJoinClicked()
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
            communityData: root.sectionItemModel
            joinedMembersCount: root.joinedMembersCount
            store: root.rootStore
            communitiesStore: root.communitiesStore
            walletAssetsStore: root.walletAssetsStore
            currencyStore: root.currencyStore
            emojiPopup: root.emojiPopup
            isPendingOwnershipRequest: root.isPendingOwnershipRequest
            onInfoButtonClicked: root.communityInfoButtonClicked()
            onManageButtonClicked: root.communityManageButtonClicked()
            onFinaliseOwnershipClicked: root.finaliseOwnershipClicked()
        }
    }

    Component {
        id: statusStickerPackClickPopup
        StatusStickerPackClickPopup{
            onBuyClicked: root.buyStickerPackRequested(packId, price)
            onClosed: destroy()
        }
    }
}
