import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.stores.Messaging.Community 1.0 as CommunityStores

QtObject {
    id: root

    required property var communityId

    readonly property QtObject _d: StatusQUtils.QObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var communitiesModuleInst: communitiesModule

        // Foreach `communityId` there will be the corresponding community module:
        readonly property var currentCommunityModule: {
            d.mainModuleInst.prepareCommunitySectionModuleForCommunityId(root.communityId)
            return d.mainModuleInst.getCommunitySectionModule()
        }
        // Foreach `communityId` there will be the corresponding active chat content module:
        readonly property var currentChatContentModule: {
            d.currentCommunityModule.prepareChatContentModuleForChatId(d.currentCommunityModule.activeItem.id)
            var a =  d.currentCommunityModule.getChatContentModule()
            return a
        }
    }

    readonly property CommunityAccessStore communityAccessStore: CommunityAccessStore {
        isModuleReady: !!d.currentCommunityModule
        allChannelsAreHiddenBecauseNotPermitted: d.currentCommunityModule.allChannelsAreHiddenBecauseNotPermitted &&
                                                 !d.currentCommunityModule.requiresTokenPermissionToJoin
        communityMemberReevaluationStatus: d.currentCommunityModule &&
                                           d.currentCommunityModule.communityMemberReevaluationStatus
        requirementsCheckPending: d.communitiesModuleInst.requirementsCheckPending
        permissionsModel: !!d.communitiesModuleInst.spectatedCommunityPermissionModel ?
                              d.communitiesModuleInst.spectatedCommunityPermissionModel : null
        permissionsCheckOngoing: d.currentCommunityModule.permissionsCheckOngoing

        onAcceptRequestToJoinCommunity: {
            d.currentCommunityModule.acceptRequestToJoinCommunity(requestId, communityId)
        }
        onDeclineRequestToJoinCommunity: {
            d.currentCommunityModule.declineRequestToJoinCommunity(requestId, communityId)
        }
    }
    readonly property CommunityStores.PermissionsStore communityPermissionsStore: CommunityStores.PermissionsStore {
        activeSectionId: d.mainModuleInst.activeSection.id
        activeChannelId: d.currentChatContentModule.chatDetails.id
        permissionsModel: d.currentCommunityModule.permissionsModel
        allTokenRequirementsMet: d.currentCommunityModule.allTokenRequirementsMet

        onCreateOrEditCommunityTokenPermission: {
            d.currentCommunityModule.createOrEditCommunityTokenPermission(activeSection, key,
                                                                          permissionType, holdings,
                                                                          channels, isPrivate)
        }
        onDeleteCommunityTokenPermission: {
            d.currentCommunityModule.deleteCommunityTokenPermission(activeSectionId, key)
        }
    }
}
