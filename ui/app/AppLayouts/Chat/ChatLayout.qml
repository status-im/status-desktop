import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared.popups
import shared.stores as SharedStores
import shared.stores.send as SendStores

import "views"

import AppLayouts.Communities.views
import AppLayouts.Communities.popups
import AppLayouts.Communities.helpers
import AppLayouts.Communities.stores as CommunitiesStores

import AppLayouts.Chat.stores as ChatStores
import AppLayouts.Profile.stores as ProfileStores
import AppLayouts.Wallet.stores as WalletStore

import StatusQ
import StatusQ.Core.Utils

import QtModelsToolkit
import SortFilterProxyModel

StackLayout {
    id: root

    property ChatStores.RootStore rootStore
    property ChatStores.CreateChatPropertiesStore createChatPropertiesStore
    readonly property SharedStores.PermissionsStore permissionsStore: rootStore.permissionsStore
    property CommunitiesStores.CommunitiesStore communitiesStore
    required property WalletStore.TokensStore tokensStore
    required property SendStores.TransactionStore transactionStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property SharedStores.CurrenciesStore currencyStore
    required property SharedStores.NetworksStore networksStore
    required property ProfileStores.AdvancedStore advancedStore
    property bool paymentRequestFeatureEnabled
    property Item navBar

    property var mutualContactsModel
    property var sectionItemModel

    readonly property bool isOwner: sectionItemModel.memberRole === Constants.memberRole.owner
    readonly property bool isAdmin: sectionItemModel.memberRole === Constants.memberRole.admin
    readonly property bool isTokenMasterOwner: sectionItemModel.memberRole === Constants.memberRole.tokenMaster
    readonly property bool isControlNode: sectionItemModel.isControlNode
    readonly property bool isPrivilegedUser: isControlNode || isOwner || isAdmin || isTokenMasterOwner
    readonly property int isInvitationPending: root.rootStore.chatCommunitySectionModule.requestToJoinState !== Constants.RequestToJoinState.None

    property bool communitySettingsDisabled

    property bool sendViaPersonalChatEnabled
    property string disabledTooltipText

    property var emojiPopup
    property var stickersPopup

    // Unfurling related data:
    property bool gifUnfurlingEnabled
    property bool neverAskAboutUnfurlingAgain

    // Users related data:
    readonly property bool amIChatAdmin: root.rootStore.amIChatAdmin()
    property var usersModel

    // Users related signals
    signal groupMembersUpdateRequested(string membersPubKeysList)

    signal profileButtonClicked()
    signal openAppSearch()
    signal buyStickerPackRequested(string packId, int price)
    signal tokenPaymentRequested(string recipientAddress, string symbol, string rawAmount, int chainId)

    // Community transfer ownership related props/signals:
    property bool isPendingOwnershipRequest: sectionItemModel.isPendingOwnershipRequest

    // Contacts related data:
    property string myPublicKey

    // Unfurling related requests:
    signal setNeverAskAboutUnfurlingAgain(bool neverAskAgain)

    signal openGifPopupRequest(var params, var cbOnGifSelected, var cbOnClose)

    // Contacts related requests:
    signal changeContactNicknameRequest(string pubKey, string nickname, string displayName, bool isEdit)
    signal removeTrustStatusRequest(string pubKey)
    signal dismissContactRequest(string chatId, string contactRequestId)
    signal acceptContactRequest(string chatId, string contactRequestId)

    onIsPrivilegedUserChanged: if (root.currentIndex === 1) root.currentIndex = 0

    onCurrentIndexChanged: {
        Global.closeCreateChatView()
    }

    Loader {
        id: mainViewLoader
        readonly property var sectionItem: root.rootStore.chatCommunitySectionModule
        readonly property int accessType: sectionItem.requiresTokenPermissionToJoin ? Constants.communityChatOnRequestAccess
                                                                                    : Constants.communityChatPublicAccess

        sourceComponent: {
            if (sectionItem.isCommunity() && !sectionItem.amIMember) {
                if (sectionItemModel.amIBanned) {
                    return communityBanComponent
                } else if (sectionItem.isWaitingOnNewCommunityOwnerToConfirmRequestToRejoin) {
                    return controlNodeOfflineComponent
                } else if (sectionItem.requiresTokenPermissionToJoin) {
                    return joinCommunityViewComponent
                }
            }
            return chatViewComponent
        }
    }

    Connections {
        target: root.rootStore
        function onGoToMembershipRequestsPage() {
            root.currentIndex = 1 // go to settings
            if (communitySettingsLoader.item) {
                communitySettingsLoader.item.goTo(Constants.CommunitySettingsSections.Members, Constants.CommunityMembershipSubSections.MembershipRequests)
            }
        }
    }

    Component {
        id: joinCommunityViewComponent
        JoinCommunityView {
            id: joinCommunityView
            readonly property string communityId: sectionItemModel.id
            navBar: root.navBar
            name: sectionItemModel.name
            introMessage: sectionItemModel.introMessage
            communityDesc: sectionItemModel.description
            color: sectionItemModel.color
            image: sectionItemModel.image
            membersCount: sectionItemModel.joinedMembersCount
            accessType: mainViewLoader.accessType
            joinCommunity: true
            amISectionAdmin: sectionItemModel.memberRole === Constants.memberRole.owner ||
                             sectionItemModel.memberRole === Constants.memberRole.admin ||
                             sectionItemModel.memberRole === Constants.memberRole.tokenMaster
            communityItemsModel: root.rootStore.communityItemsModel
            requirementsMet: root.permissionsStore.allTokenRequirementsMet
            requirementsCheckPending: root.rootStore.permissionsCheckOngoing
            requiresRequest: !sectionItemModel.amIMember
            communityHoldingsModel: root.permissionsStore.becomeMemberPermissionsModel
            viewOnlyHoldingsModel: root.permissionsStore.viewOnlyPermissionsModel
            viewAndPostHoldingsModel: root.permissionsStore.viewAndPostPermissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            requestToJoinState: root.rootStore.chatCommunitySectionModule.requestToJoinState
            notificationCount: activityCenterStore.unreadNotificationsCount
            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
            openCreateChat: rootStore.openCreateChat
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
            onRequestToJoinClicked: {
                Global.communityIntroPopupRequested(joinCommunityView.communityId, sectionItemModel.name,
                                                    sectionItemModel.introMessage, sectionItemModel.image,
                                                    root.isInvitationPending)
            }
            onInvitationPendingClicked: {
                Global.communityIntroPopupRequested(joinCommunityView.communityId, sectionItemModel.name, sectionItemModel.introMessage,
                                                    sectionItemModel.image, root.isInvitationPending)
            }
        }
    }

    Component {
        id: chatViewComponent
        ChatView {
            id: chatView

            readonly property var sectionItem: root.rootStore.chatCommunitySectionModule
            readonly property string communityId: root.sectionItemModel.id

            objectName: "chatViewComponent"
            navBar: root.navBar

            rootStore: root.rootStore
            createChatPropertiesStore: root.createChatPropertiesStore
            communitiesStore: root.communitiesStore
            walletAssetsStore: root.walletAssetsStore
            currencyStore: root.currencyStore

            mutualContactsModel: root.mutualContactsModel

            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            sectionItemModel: root.sectionItemModel
            joinedMembersCount: sectionItemModel.joinedMembersCount
            areTestNetworksEnabled: root.networksStore.areTestNetworksEnabled
            amIChatAdmin: root.rootStore.amIChatAdmin()
            amIMember: sectionItem.amIMember
            amISectionAdmin: root.sectionItemModel.memberRole === Constants.memberRole.owner ||
                             root.sectionItemModel.memberRole === Constants.memberRole.admin ||
                             root.sectionItemModel.memberRole === Constants.memberRole.tokenMaster
            hasViewOnlyPermissions: root.permissionsStore.viewOnlyPermissionsModel.count > 0
            sendViaPersonalChatEnabled: root.sendViaPersonalChatEnabled
            disabledTooltipText: root.disabledTooltipText
            paymentRequestFeatureEnabled: root.paymentRequestFeatureEnabled

            hasUnrestrictedViewOnlyPermission: {
                viewOnlyUnrestrictedPermissionHelper.revision

                const model = root.permissionsStore.viewOnlyPermissionsModel
                const count = model.rowCount()

                for (let i = 0; i < count; i++) {
                    const holdings = ModelUtils.get(model, i, "holdingsListModel")

                    if (holdings.rowCount() === 0)
                        return true
                }

                return false
            }

            Instantiator {
                id: viewOnlyUnrestrictedPermissionHelper

                model: root.permissionsStore.viewOnlyPermissionsModel

                property int revision: 0

                delegate: QObject {
                    ModelChangeTracker {
                        model: model.holdingsListModel

                        onRevisionChanged: viewOnlyUnrestrictedPermissionHelper.revision++
                    }
                }
            }

            ModelChangeTracker {
                model: root.permissionsStore.viewOnlyPermissionsModel
                onRevisionChanged: viewOnlyUnrestrictedPermissionHelper.revision++
            }

            hasViewAndPostPermissions: root.permissionsStore.viewAndPostPermissionsModel.count > 0
            viewOnlyPermissionsModel: root.permissionsStore.viewOnlyPermissionsModel
            viewAndPostPermissionsModel: root.permissionsStore.viewAndPostPermissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            requestToJoinState: sectionItem.requestToJoinState

            isPendingOwnershipRequest: root.isPendingOwnershipRequest

            // Unfurling related data:
            gifUnfurlingEnabled: root.gifUnfurlingEnabled
            neverAskAboutUnfurlingAgain: root.neverAskAboutUnfurlingAgain

            // Users related data:
            usersModel: root.usersModel

            // Contacts related data:
            myPublicKey: root.myPublicKey

            onGroupMembersUpdateRequested: root.groupMembersUpdateRequested(membersPubKeysList)

            onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(communityId)
            onCommunityInfoButtonClicked: root.currentIndex = 1
            onCommunityManageButtonClicked: root.currentIndex = 1

            onProfileButtonClicked: {
                root.profileButtonClicked()
            }
            onOpenAppSearch: {
                root.openAppSearch()
            }
            onRequestToJoinClicked: {
                Global.communityIntroPopupRequested(communityId, root.sectionItemModel.name, root.sectionItemModel.introMessage,
                                                    root.sectionItemModel.image, root.isInvitationPending)
            }
            onInvitationPendingClicked: {
                Global.communityIntroPopupRequested(communityId, root.sectionItemModel.name, root.sectionItemModel.introMessage,
                                                    root.sectionItemModel.image, root.isInvitationPending)
            }

            onBuyStickerPackRequested: root.buyStickerPackRequested(packId, price)
            onTokenPaymentRequested: root.tokenPaymentRequested(recipientAddress, symbol, rawAmount, chainId)

            // Unfurling related requests:
            onSetNeverAskAboutUnfurlingAgain: root.setNeverAskAboutUnfurlingAgain(neverAskAgain)

            onOpenGifPopupRequest: root.openGifPopupRequest(params, cbOnGifSelected, cbOnClose)

            // Contacts related requests:
            onChangeContactNicknameRequest: root.changeContactNicknameRequest(pubKey, nickname, displayName, isEdit)
            onRemoveTrustStatusRequest: root.removeTrustStatusRequest(pubKey)
            onDismissContactRequest: root.dismissContactRequest(chatId, contactRequestId)
            onAcceptContactRequest: root.acceptContactRequest(chatId, contactRequestId)
        }
    }

    Loader {
        id: communitySettingsLoader
        active: root.rootStore.chatCommunitySectionModule.isCommunity() &&
                root.isPrivilegedUser &&
                (root.currentIndex === 1 || !!communitySettingsLoader.item) // lazy load and preserve state after loading
        asynchronous: false // It's false on purpose. We want to load the component synchronously

        sourceComponent: CommunitySettingsView {
            id: communitySettingsView
            navBar: root.navBar

            rootStore: root.rootStore
            walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
            enabledChainIds: root.networksStore.networkFilters
            onEnableNetwork: root.networksStore.enableNetwork(chainId)
            activeNetworks: root.networksStore.activeNetworks
            tokensStore: root.tokensStore
            transactionStore: root.transactionStore
            advancedStore: root.advancedStore

            isPendingOwnershipRequest: root.isPendingOwnershipRequest

            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: root.sectionItemModel
            communitySettingsDisabled: root.communitySettingsDisabled

            onLoadMembersRequested: rootStore.loadMembersForSectionId(root.sectionItemModel.id)

            onCommunitySettingsDisabledChanged: if (communitySettingsDisabled) goTo(Constants.CommunitySettingsSections.Overview)

            onBackToCommunityClicked: root.currentIndex = 0
            onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(community.id)
        }
    }

    Component {
        id: controlNodeOfflineComponent
        ControlNodeOfflineCommunityView {
            id: controlNodeOfflineView
            navBar: root.navBar
            name: root.sectionItemModel.name
            communityDesc: root.sectionItemModel.description
            color: root.sectionItemModel.color
            image: root.sectionItemModel.image
            membersCount: sectionItemModel.joinedMembersCount
            communityItemsModel: root.rootStore.communityItemsModel
            notificationCount: activityCenterStore.unreadNotificationsCount
            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
        }
    }

    Component {
        id: communityBanComponent
        BannedMemberCommunityView {
            id: communityBanView
            readonly property var communityData: sectionItemModel
            navBar: root.navBar
            name: root.sectionItemModel.name
            communityDesc: root.sectionItemModel.description
            color: root.sectionItemModel.color
            image: root.sectionItemModel.image
            membersCount: sectionItemModel.joinedMembersCount
            communityItemsModel: root.rootStore.communityItemsModel
            notificationCount: activityCenterStore.unreadNotificationsCount
            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
        }
    }
}
