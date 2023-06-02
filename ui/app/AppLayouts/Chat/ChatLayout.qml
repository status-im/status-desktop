import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.popups 1.0

import "views"
import "views/communities"
import "stores"
import "popups/community"

import AppLayouts.Chat.stores 1.0

StackLayout {
    id: root

    property RootStore rootStore
    property var createChatPropertiesStore
    readonly property var contactsStore: rootStore.contactsStore
    readonly property var permissionsStore: rootStore.permissionsStore

    property var sectionItemModel

    property var emojiPopup
    property var stickersPopup
    signal profileButtonClicked()
    signal openAppSearch()

    onCurrentIndexChanged: {
        Global.closeCreateChatView()
    }

    Loader {
        readonly property var chatItem: root.rootStore.chatCommunitySectionModule
        sourceComponent: chatItem.isCommunity() && chatItem.requiresTokenPermissionToJoin && !chatItem.amIMember ? joinCommunityViewComponent : chatViewComponent
    }

    Component {
        id: joinCommunityViewComponent
        JoinCommunityView {
            id: joinCommunityView
            readonly property var communityData: sectionItemModel
            name: communityData.name
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
            communityHoldingsModel: root.permissionsStore.permissionsModel
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
                communityIntroDialog.open()
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

            CommunityIntroDialog {
                id: communityIntroDialog

                isInvitationPending: joinCommunityView.isInvitationPending
                name: communityData.name
                introMessage: communityData.introMessage
                imageSrc: communityData.image
                accessType: communityData.access

                onJoined: {
                    root.rootStore.requestToJoinCommunityWithAuthentication(communityData.id, root.rootStore.userProfileInst.name)
                }

                onCancelMembershipRequest: {
                    root.rootStore.cancelPendingRequest(communityData.id)
                    joinCommunityView.isInvitationPending = root.rootStore.isCommunityRequestPending(communityData.id)
                }
            }
        }


    }

    Component {
        id: chatViewComponent
        ChatView {
            id: chatView
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            contactsStore: root.contactsStore
            rootStore: root.rootStore
            createChatPropertiesStore: root.createChatPropertiesStore
            sectionItemModel: root.sectionItemModel

            onCommunityInfoButtonClicked: root.currentIndex = 1
            onCommunityManageButtonClicked: root.currentIndex = 1

            onProfileButtonClicked: {
                root.profileButtonClicked()
            }
            onOpenAppSearch: {
                root.openAppSearch()
            }
        }
    }

    Loader {
        id: communitySettingsLoader
        active: root.rootStore.chatCommunitySectionModule.isCommunity()

        sourceComponent: CommunitySettingsView {
            id: communitySettingsView
            rootStore: root.rootStore

            hasAddedContacts: root.contactsStore.myContactsModel.count > 0
            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: sectionItemModel

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
}
