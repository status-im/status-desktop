import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.stores.send 1.0

import "views"
import "stores"

import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.helpers 1.0

import AppLayouts.Chat.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

import StatusQ.Core.Utils 0.1

StackLayout {
    id: root

    property RootStore rootStore
    property var createChatPropertiesStore
    readonly property var contactsStore: rootStore.contactsStore
    readonly property var permissionsStore: rootStore.permissionsStore
    property var communitiesStore
    required property WalletStore.TokensStore tokensStore
    required property TransactionStore transactionStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property CurrenciesStore currencyStore

    property var sectionItemModel
    property var sendModalPopup

    readonly property bool isOwner: sectionItemModel.memberRole === Constants.memberRole.owner
    readonly property bool isAdmin: sectionItemModel.memberRole === Constants.memberRole.admin
    readonly property bool isTokenMasterOwner: sectionItemModel.memberRole === Constants.memberRole.tokenMaster
    readonly property bool isControlNode: sectionItemModel.isControlNode
    readonly property bool isPrivilegedUser: isControlNode || isOwner || isAdmin || isTokenMasterOwner

    property bool communitySettingsDisabled

    property var emojiPopup
    property var stickersPopup
    signal profileButtonClicked()
    signal openAppSearch()

    // Community transfer ownership related props/signals:
    property bool isPendingOwnershipRequest: sectionItemModel.isPendingOwnershipRequest

    onIsPrivilegedUserChanged: if (root.currentIndex === 1) root.currentIndex = 0

    onCurrentIndexChanged: {
        Global.closeCreateChatView()
    }

    Loader {
        id: mainViewLoader
        readonly property var sectionItem: root.rootStore.chatCommunitySectionModule

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
            readonly property var communityData: sectionItemModel
            readonly property string communityId: communityData.id
            name: communityData.name
            introMessage: communityData.introMessage
            communityDesc: communityData.description
            color: communityData.color
            image: communityData.image
            membersCount: communityData.members.count
            accessType: communityData.access
            joinCommunity: true
            amISectionAdmin: communityData.memberRole === Constants.memberRole.owner ||
                             communityData.memberRole === Constants.memberRole.admin ||
                             communityData.memberRole === Constants.memberRole.tokenMaster
            communityItemsModel: root.rootStore.communityItemsModel
            requirementsMet: root.permissionsStore.allTokenRequirementsMet
            requirementsCheckPending: root.rootStore.permissionsCheckOngoing
            requiresRequest: !communityData.amIMember
            communityHoldingsModel: root.permissionsStore.becomeMemberPermissionsModel
            viewOnlyHoldingsModel: root.permissionsStore.viewOnlyPermissionsModel
            viewAndPostHoldingsModel: root.permissionsStore.viewAndPostPermissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            isInvitationPending: root.rootStore.isMyCommunityRequestPending(communityId)
            notificationCount: activityCenterStore.unreadNotificationsCount
            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
            openCreateChat: rootStore.openCreateChat
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
            onRequestToJoinClicked: {
                Global.openPopup(communityMembershipSetupDialogComponent, {
                    communityId: joinCommunityView.communityId,
                    isInvitationPending: joinCommunityView.isInvitationPending,
                    communityName: communityData.name,
                    introMessage: communityData.introMessage,
                    communityIcon: communityData.image,
                    accessType: communityData.access
                })
            }
            onInvitationPendingClicked: {
                Global.openPopup(communityMembershipSetupDialogComponent, {
                                     communityId: joinCommunityView.communityId,
                                     isInvitationPending: joinCommunityView.isInvitationPending,
                                     communityName: communityData.name,
                                     introMessage: communityData.introMessage,
                                     communityIcon: communityData.image,
                                     accessType: communityData.access
                                 })
            }

            Connections {
                target: root.rootStore.communitiesModuleInst
                function onCommunityAccessRequested(communityId: string) {
                    if (communityId === joinCommunityView.communityId) {
                        joinCommunityView.isInvitationPending = root.rootStore.isMyCommunityRequestPending(communityId)
                    }
                }
            }
        }
    }

    Component {
        id: chatViewComponent
        ChatView {
            id: chatView

            readonly property var sectionItem: root.rootStore.chatCommunitySectionModule
            readonly property string communityId: root.sectionItemModel.id

            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            contactsStore: root.contactsStore
            rootStore: root.rootStore
            transactionStore: root.transactionStore
            createChatPropertiesStore: root.createChatPropertiesStore
            communitiesStore: root.communitiesStore
            walletAssetsStore: root.walletAssetsStore
            currencyStore: root.currencyStore
            sectionItemModel: root.sectionItemModel
            amIMember: sectionItem.amIMember
            amISectionAdmin: root.sectionItemModel.memberRole === Constants.memberRole.owner ||
                             root.sectionItemModel.memberRole === Constants.memberRole.admin ||
                             root.sectionItemModel.memberRole === Constants.memberRole.tokenMaster
            hasViewOnlyPermissions: root.permissionsStore.viewOnlyPermissionsModel.count > 0
            hasViewAndPostPermissions: root.permissionsStore.viewAndPostPermissionsModel.count > 0
            viewOnlyPermissionsModel: root.permissionsStore.viewOnlyPermissionsModel
            viewAndPostPermissionsModel: root.permissionsStore.viewAndPostPermissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            isInvitationPending: root.rootStore.isMyCommunityRequestPending(chatView.communityId)

            isPendingOwnershipRequest: root.isPendingOwnershipRequest

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
                Global.openPopup(communityMembershipSetupDialogComponent, {
                    communityId: chatView.communityId,
                    isInvitationPending: root.rootStore.isMyCommunityRequestPending(chatView.communityId),
                    communityName: root.sectionItemModel.name,
                    introMessage: root.sectionItemModel.introMessage,
                    communityIcon: root.sectionItemModel.image,
                    accessType: root.sectionItemModel.access
                })
            }
            onInvitationPendingClicked: {
                Global.openPopup(communityMembershipSetupDialogComponent, {
                    communityId: chatView.communityId,
                    isInvitationPending: root.rootStore.isMyCommunityRequestPending(chatView.communityId),
                    communityName: root.sectionItemModel.name,
                    introMessage: root.sectionItemModel.introMessage,
                    communityIcon: root.sectionItemModel.image,
                    accessType: root.sectionItemModel.access
                })
            }
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
            rootStore: root.rootStore
            walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
            tokensStore: root.tokensStore
            sendModalPopup: root.sendModalPopup
            transactionStore: root.transactionStore

            isPendingOwnershipRequest: root.isPendingOwnershipRequest

            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: sectionItemModel
            communitySettingsDisabled: root.communitySettingsDisabled
            onCommunitySettingsDisabledChanged: if (communitySettingsDisabled) goTo(Constants.CommunitySettingsSections.Overview)

            onBackToCommunityClicked: root.currentIndex = 0
            onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(community.id)
        }
    }

    Component {
        id: controlNodeOfflineComponent
        ControlNodeOfflineCommunityView {
            id: controlNodeOfflineView
            readonly property var communityData: sectionItemModel
            name: communityData.name
            communityDesc: communityData.description
            color: communityData.color
            image: communityData.image
            membersCount: communityData.members.count
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
            name: communityData.name
            communityDesc: communityData.description
            color: communityData.color
            image: communityData.image
            membersCount: communityData.members.count
            communityItemsModel: root.rootStore.communityItemsModel
            notificationCount: activityCenterStore.unreadNotificationsCount
            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
        }
    }

    Component {
        id: communityMembershipSetupDialogComponent

        CommunityMembershipSetupDialog {
            id: dialogRoot

            property string communityId

            walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
            canProfileProveOwnershipOfProvidedAddressesFn: WalletStore.RootStore.canProfileProveOwnershipOfProvidedAddresses

            walletAssetsModel: walletAssetsStore.groupedAccountAssetsModel
            requirementsCheckPending: root.rootStore.requirementsCheckPending
            permissionsModel: {
                root.rootStore.prepareTokenModelForCommunity(dialogRoot.communityId)
                return root.rootStore.permissionsModel
            }
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel

            getCurrencyAmount: function (balance, symbol){
                return currencyStore.getCurrencyAmount(balance, symbol)
            }

            onPrepareForSigning: {
                root.rootStore.prepareKeypairsForSigning(dialogRoot.communityId, dialogRoot.name, sharedAddresses, airdropAddress)

                dialogRoot.keypairSigningModel = root.rootStore.communitiesModuleInst.keypairsSigningModel
            }

            onSignProfileKeypairAndAllNonKeycardKeypairs: {
                root.rootStore.signProfileKeypairAndAllNonKeycardKeypairs()
            }

            onSignSharedAddressesForKeypair: {
                root.rootStore.signSharedAddressesForKeypair(keyUid)
            }

            onJoinCommunity: {
                root.rootStore.joinCommunityOrEditSharedAddresses()
            }

            onCancelMembershipRequest: {
                root.rootStore.cancelPendingRequest(dialogRoot.communityId)
                mainViewLoader.item.isInvitationPending = root.rootStore.isMyCommunityRequestPending(dialogRoot.communityId)
            }

            onSharedAddressesUpdated: {
                root.rootStore.updatePermissionsModel(dialogRoot.communityId, sharedAddresses)
            }

            onClosed: {
                root.rootStore.cleanJoinEditCommunityData()
            }

            Connections {
                target: root.rootStore.communitiesModuleInst

                function onAllSharedAddressesSigned() {
                    if (dialogRoot.profileProvesOwnershipOfSelectedAddresses) {
                        dialogRoot.joinCommunity()
                        dialogRoot.close()
                        return
                    }

                    if (dialogRoot.allAddressesToRevealBelongToSingleNonProfileKeypair) {
                        dialogRoot.joinCommunity()
                        dialogRoot.close()
                        return
                    }

                    if (!!dialogRoot.replaceItem) {
                        dialogRoot.replaceLoader.item.allSigned()
                    }
                }
            }
        }
    }

    Connections {
        target: root.rootStore
        enabled: mainViewLoader.item
        function onCommunityAccessRequested(communityId: string) {
            if (communityId === mainViewLoader.item.communityId) {
                mainViewLoader.item.isInvitationPending = root.rootStore.isMyCommunityRequestPending(communityId)
            }
        }
    }
}
