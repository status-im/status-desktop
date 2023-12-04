import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.popups 1.0

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
        readonly property var chatItem: root.rootStore.chatCommunitySectionModule

        sourceComponent: {
            if (chatItem.isCommunity() && !chatItem.amIMember) {
                if (chatItem.isWaitingOnNewCommunityOwnerToConfirmRequestToRejoin) {
                    return controlNodeOfflineComponent
                } else if (chatItem.requiresTokenPermissionToJoin) {
                    return joinCommunityViewComponent
                }
            }
            return chatViewComponent
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
            loginType: root.rootStore.loginType
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
            onRevealAddressClicked: {
                Global.openPopup(communityIntroDialogPopup, {
                    communityId: joinCommunityView.communityId,
                    isInvitationPending: joinCommunityView.isInvitationPending,
                    name: communityData.name,
                    introMessage: communityData.introMessage,
                    imageSrc: communityData.image,
                    accessType: communityData.access
                })
            }
            onInvitationPendingClicked: {
                root.rootStore.cancelPendingRequest(communityId)
                joinCommunityView.isInvitationPending = root.rootStore.isMyCommunityRequestPending(communityId)
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

            readonly property var chatItem: root.rootStore.chatCommunitySectionModule
            readonly property string communityId: root.sectionItemModel.id

            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            contactsStore: root.contactsStore
            rootStore: root.rootStore
            createChatPropertiesStore: root.createChatPropertiesStore
            communitiesStore: root.communitiesStore
            sectionItemModel: root.sectionItemModel
            amIMember: chatItem.amIMember
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
            onRevealAddressClicked: {
                Global.openPopup(communityIntroDialogPopup, {
                    communityId: chatView.communityId,
                    isInvitationPending: root.rootStore.isMyCommunityRequestPending(chatView.communityId),
                    name: root.sectionItemModel.name,
                    introMessage: root.sectionItemModel.introMessage,
                    imageSrc: root.sectionItemModel.image,
                    accessType: root.sectionItemModel.access
                })
            }
            onInvitationPendingClicked: {
                root.rootStore.cancelPendingRequest(chatView.communityId)
                chatView.isInvitationPending = root.rootStore.isMyCommunityRequestPending(chatView.communityId)
            }
        }
    }

    Loader {
        id: communitySettingsLoader
        active: root.rootStore.chatCommunitySectionModule.isCommunity() && root.isPrivilegedUser

        sourceComponent: CommunitySettingsView {
            id: communitySettingsView
            rootStore: root.rootStore
            walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
            tokensStore: root.tokensStore
            sendModalPopup: root.sendModalPopup

            isPendingOwnershipRequest: root.isPendingOwnershipRequest

            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: sectionItemModel
            communitySettingsDisabled: root.communitySettingsDisabled
            onCommunitySettingsDisabledChanged: if (communitySettingsDisabled) goTo(Constants.CommunitySettingsSections.Overview)

            onBackToCommunityClicked: root.currentIndex = 0
            onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(community.id)

            Connections {
                target: root.rootStore
                function onGoToMembershipRequestsPage() {
                    root.currentIndex = 1 // go to settings
                    communitySettingsView.goTo(Constants.CommunitySettingsSections.Members, Constants.CommunityMembershipSubSections.MembershipRequests)
                }
            }
        }
    }

    Component {
        id: controlNodeOfflineComponent
        ControlNodeOfflineCommunityView {
            id: controlNodeOfflineView
            readonly property var communityData: sectionItemModel
            readonly property string communityId: communityData.id
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
        id: communityIntroDialogPopup
        CommunityIntroDialog {
            id: communityIntroDialog

            property string communityId

            loginType: root.rootStore.loginType
            walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
            requirementsCheckPending: root.rootStore.requirementsCheckPending
            permissionsModel: {
                root.rootStore.prepareTokenModelForCommunity(communityIntroDialog.communityId)
                return root.rootStore.permissionsModel
            }
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel

            onPrepareForSigning: {
                root.rootStore.prepareKeypairsForSigning(communityIntroDialog.communityId, communityIntroDialog.name, sharedAddresses, airdropAddress)

                communityIntroDialog.keypairSigningModel = root.rootStore.communitiesModuleInst.keypairsSigningModel
            }

            onSignSharedAddressesForAllNonKeycardKeypairs: {
                root.rootStore.signSharedAddressesForAllNonKeycardKeypairs()
            }

            onSignSharedAddressesForKeypair: {
                root.rootStore.signSharedAddressesForKeypair(keyUid)
            }

            onJoinCommunity: {
                root.rootStore.joinCommunityOrEditSharedAddresses()
            }

            onCancelMembershipRequest: {
                root.rootStore.cancelPendingRequest(communityIntroDialog.communityId)
                mainViewLoader.item.isInvitationPending = root.rootStore.isMyCommunityRequestPending(communityIntroDialog.communityId)
            }

            onSharedAddressesUpdated: {
                root.rootStore.updatePermissionsModel(communityIntroDialog.communityId, sharedAddresses)
            }

            onClosed: {
                destroy()
            }

            Connections {
                target: root.rootStore.communitiesModuleInst

                function onSharedAddressesForAllNonKeycardKeypairsSigned() {
                    if (!!communityIntroDialog.replaceItem) {
                        communityIntroDialog.replaceLoader.item.sharedAddressesForAllNonKeycardKeypairsSigned()
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
