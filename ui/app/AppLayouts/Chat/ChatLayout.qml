import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.popups 1.0

import "views"
import AppLayouts.Communities.views 1.0
import "stores"
import AppLayouts.Communities.popups 1.0

import AppLayouts.Chat.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

StackLayout {
    id: root

    property RootStore rootStore
    property var createChatPropertiesStore
    readonly property var contactsStore: rootStore.contactsStore
    readonly property var permissionsStore: rootStore.permissionsStore

    property var sectionItemModel

    property bool communitySettingsDisabled

    property var emojiPopup
    property var stickersPopup
    signal profileButtonClicked()
    signal openAppSearch()

    onCurrentIndexChanged: {
        Global.closeCreateChatView()
    }

    Loader {
        id: mainViewLoader
        readonly property var chatItem: root.rootStore.chatCommunitySectionModule
        sourceComponent: chatItem.isCommunity() && chatItem.requiresTokenPermissionToJoin && !chatItem.amIMember ? joinCommunityViewComponent : chatViewComponent
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
                             communityData.memberRole === Constants.memberRole.admin
            communityItemsModel: root.rootStore.communityItemsModel
            requirementsMet: root.permissionsStore.allTokenRequirementsMet
            requiresRequest: !communityData.amIMember
            communityHoldingsModel: root.permissionsStore.becomeMemberPermissionsModel
            viewOnlyHoldingsModel: root.permissionsStore.viewOnlyPermissionsModel
            viewAndPostHoldingsModel: root.permissionsStore.viewAndPostPermissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            isInvitationPending: root.rootStore.isCommunityRequestPending(communityData.id)
            notificationCount: activityCenterStore.unreadNotificationsCount
            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
            openCreateChat: rootStore.openCreateChat
            loginType: root.rootStore.loginType
            onNotificationButtonClicked: Global.openActivityCenterPopup()
            onAdHocChatButtonClicked: rootStore.openCloseCreateChatView()
            onRevealAddressClicked: {
                Global.openPopup(communityIntroDialogPopup, {
                    communityId: communityData.id,
                    isInvitationPending: joinCommunityView.isInvitationPending,
                    name: communityData.name,
                    introMessage: communityData.introMessage,
                    imageSrc: communityData.image,
                    accessType: communityData.access
                })
            }
            onInvitationPendingClicked: {
                root.rootStore.cancelPendingRequest(communityData.id)
                joinCommunityView.isInvitationPending = root.rootStore.isCommunityRequestPending(communityData.id)
            }

            Connections {
                target: root.rootStore.communitiesModuleInst
                function onCommunityAccessRequested(communityId: string) {
                    if (communityId === joinCommunityView.communityData.id) {
                        joinCommunityView.isInvitationPending = root.rootStore.isCommunityRequestPending(communityData.id)
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
            sectionItemModel: root.sectionItemModel
            amIMember: chatItem.amIMember
            amISectionAdmin: root.sectionItemModel.memberRole === Constants.memberRole.owner ||
                             root.sectionItemModel.memberRole === Constants.memberRole.admin
            hasViewOnlyPermissions: root.permissionsStore.viewOnlyPermissionsModel.count > 0
            hasViewAndPostPermissions: root.permissionsStore.viewAndPostPermissionsModel.count > 0
            viewOnlyPermissionsModel: root.permissionsStore.viewOnlyPermissionsModel
            viewAndPostPermissionsModel: root.permissionsStore.viewAndPostPermissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            isInvitationPending: root.rootStore.isCommunityRequestPending(chatView.communityId)

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
                    isInvitationPending: root.rootStore.isCommunityRequestPending(chatView.communityId),
                    name: root.sectionItemModel.name,
                    introMessage: root.sectionItemModel.introMessage,
                    imageSrc: root.sectionItemModel.image,
                    accessType: root.sectionItemModel.access
                })
            }
            onInvitationPendingClicked: {
                root.rootStore.cancelPendingRequest(chatView.communityId)
                chatView.isInvitationPending = root.rootStore.isCommunityRequestPending(chatView.communityId)
            }
        }
    }

    Loader {
        id: communitySettingsLoader
        active: root.rootStore.chatCommunitySectionModule.isCommunity()

        sourceComponent: CommunitySettingsView {
            id: communitySettingsView
            rootStore: root.rootStore

            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: sectionItemModel
            communitySettingsDisabled: root.communitySettingsDisabled
            onCommunitySettingsDisabledChanged: if (communitySettingsDisabled) goTo(Constants.CommunitySettingsSections.Overview)

            onBackToCommunityClicked: root.currentIndex = 0

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
        id: communityIntroDialogPopup
        CommunityIntroDialog {
            id: communityIntroDialog

            property string communityId

            loginType: root.rootStore.loginType
            walletAccountsModel: WalletStore.RootStore.receiveAccounts
            permissionsModel: root.permissionsStore.permissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel

            onJoined: {
                root.rootStore.requestToJoinCommunityWithAuthentication(root.rootStore.userProfileInst.name, sharedAddresses, airdropAddress)
            }

            onCancelMembershipRequest: {
                root.rootStore.cancelPendingRequest(communityIntroDialog.communityId)
                mainViewLoader.item.isInvitationPending = root.rootStore.isCommunityRequestPending(communityIntroDialog.communityId)
            }

            onClosed: {
                destroy()
            }
        }
    }

    Connections {
        target: root.rootStore
        enabled: mainViewLoader.item
        function onCommunityAccessRequested(communityId: string) {
            if (communityId === mainViewLoader.item.communityId) {
                mainViewLoader.item.isInvitationPending = root.rootStore.isCommunityRequestPending(communityId)
            }
        }
    }

}
