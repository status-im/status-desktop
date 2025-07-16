import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as StatusQUtils

QtObject {
    id: root

    required property var communityId

    readonly property QtObject _d: StatusQUtils.QObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var communitiesModuleInst: communitiesModule

        // Foreach `communityId` there will be the corresponding community module:
        property var currentCommunityModule: d.getCurrentCommunityModule(root.communityId)

        // Foreach `communityId` there will be the corresponding active chat content module:
        property var currentChatContentModule: d.getChatContentModule(d.currentCommunityModule)

        function getCurrentCommunityModule(communityId) {
            if (!communityId) {
                console.warn("CommunityRootStore: No communityId set")
                return null
            }
            d.mainModuleInst.prepareCommunitySectionModuleForCommunityId(communityId)
            return d.mainModuleInst.getCommunitySectionModule()
        }

        function getChatContentModule(communityModule) {
            if (communityModule && communityModule.activeItem) {
                communityModule.prepareChatContentModuleForChatId(
                    communityModule.activeItem.id
                )
                return communityModule.getChatContentModule()
            } else {
                console.warn("No active item for chat content module")
            }
            return null
        }
    }

    readonly property CommunityAccessStore communityAccessStore: CommunityAccessStore {
        isModuleReady: !!d.currentCommunityModule
        joined: d.currentCommunityModule ? d.currentCommunityModule.joined : false
        allChannelsAreHiddenBecauseNotPermitted: d.currentCommunityModule.allChannelsAreHiddenBecauseNotPermitted &&
                                                 !d.currentCommunityModule.requiresTokenPermissionToJoin
        communityMemberReevaluationStatus: d.currentCommunityModule &&
                                           d.currentCommunityModule.communityMemberReevaluationStatus
        spectatedPermissionsCheckOngoing: d.communitiesModuleInst.requirementsCheckPending
        spectatedPermissionsModel: !!d.communitiesModuleInst.spectatedCommunityPermissionModel ?
                                       d.communitiesModuleInst.spectatedCommunityPermissionModel : null
        communityPermissionsCheckOngoing: d.currentCommunityModule.permissionsCheckOngoing
        chatPermissionsCheckOngoing: d.currentChatContentModule.permissionsCheckOngoing

        onAcceptRequestToJoinCommunity: {
            d.currentCommunityModule.acceptRequestToJoinCommunity(requestId, communityId)
        }
        onDeclineRequestToJoinCommunity: {
            d.currentCommunityModule.declineRequestToJoinCommunity(requestId, communityId)
        }
    }
    readonly property PermissionsStore communityPermissionsStore: PermissionsStore {
        activeSectionId: d.mainModuleInst.activeSection.id
        activeChannelId: d.currentChatContentModule ? d.currentChatContentModule.chatDetails.id : ""
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
