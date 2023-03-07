import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import "views"
import "views/communities"
import "stores"
import "popups/community"

import AppLayouts.Chat.stores 1.0

StackLayout {
    id: root

    property RootStore rootStore
    readonly property var contactsStore: rootStore.contactsStore
    readonly property var permissionsStore: rootStore.permissionsStore

    property var emojiPopup
    property var stickersPopup
    signal importCommunityClicked()
    signal createCommunityClicked()
    signal profileButtonClicked()
    signal openAppSearch()

    onCurrentIndexChanged: {
        Global.closeCreateChatView()
    }

    Component {
        id: membershipRequestPopupComponent
        MembershipRequestsPopup {
            anchors.centerIn: parent
            store: root.rootStore
            communityData: store.mainModuleInst ? store.mainModuleInst.activeSection || {} : {}
            onClosed: {
                destroy()
            }
        }
    }

    Loader {

        readonly property var chatItem: root.rootStore.chatCommunitySectionModule
        sourceComponent: chatItem.isCommunity() && chatItem.requiresTokenPermissionToJoin && !chatItem.amIMember ? joinCommunityViewComponent : chatViewComponent
    }

    Component {
        id: joinCommunityViewComponent
        JoinCommunityView {
            id: joinCommunityView
            readonly property var communityData: root.rootStore.mainModuleInst ? root.rootStore.mainModuleInst.activeSection || {} : {}
            name: communityData.name
            communityDesc: communityData.description
            color: communityData.color
            image: communityData.image
            membersCount: communityData.members.count
            accessType: communityData.access
            joinCommunity: true
            amISectionAdmin: communityData.amISectionAdmin
            communityItemsModel: root.rootStore.communityItemsModel
            requirementsMet: root.permissionsStore.allTokenRequirementsMet
            communityHoldingsModel: root.permissionsStore.permissionsModel
            assetsModel: root.rootStore.assetsModel
            collectiblesModel: root.rootStore.collectiblesModel
            isInvitationPending: root.rootStore.isCommunityRequestPending(communityData.id)

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
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            contactsStore: root.contactsStore
            rootStore: root.rootStore
            membershipRequestPopup: membershipRequestPopupComponent

            onCommunityInfoButtonClicked: root.currentIndex = 1
            onCommunityManageButtonClicked: root.currentIndex = 1

            onImportCommunityClicked: {
                root.importCommunityClicked();
            }
            onCreateCommunityClicked: {
                root.createCommunityClicked();
            }
            onProfileButtonClicked: {
                root.profileButtonClicked()
            }
            onOpenAppSearch: {
                root.openAppSearch()
            }
        }
    }

    Loader {
        active: root.rootStore.chatCommunitySectionModule.isCommunity()

        sourceComponent: CommunitySettingsView {
            rootStore: root.rootStore
            communityStore: CommunitiesStore {}

            hasAddedContacts: root.contactsStore.myContactsModel.count > 0
            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: root.rootStore.mainModuleInst ? root.rootStore.mainModuleInst.activeSection
                                                       || ({}) : ({})

            onBackToCommunityClicked: root.currentIndex = 0

            // TODO: remove me when migration to new settings is done
            onOpenLegacyPopupClicked: Global.openCommunityProfilePopupRequested(root.rootStore, community, chatCommunitySectionModule)
        }
    }
}
