import QtQuick 2.15

import SortFilterProxyModel
import QtModelsToolkit

import StatusQ.Core.Utils 0.1 as StatusQUtils

StatusQUtils.QObject {
    id: root

    // **
    // ** Public API for UI region:
    // **

    // All logic from this store will be related to this particular communityId
    required property var communityId

    readonly property CommunityAccessStore communityAccessStore: CommunityAccessStore {
        communityId: root.communityId
        isModuleReady: !!d.currentCommunityModule
        joined: d.communityDetails ? d.communityDetails.joined : false
        allChannelsAreHiddenBecauseNotPermitted: d.currentCommunityModule.allChannelsAreHiddenBecauseNotPermitted &&
                                                 !d.currentCommunityModule.requiresTokenPermissionToJoin
        communityMemberReevaluationStatus: d.currentCommunityModule &&
                                           d.currentCommunityModule.communityMemberReevaluationStatus
        spectatedPermissionsCheckOngoing: d.communitiesModuleInst.requirementsCheckPending
        spectatedPermissionsModel: !!d.communitiesModuleInst.spectatedCommunityPermissionModel ?
                                       d.communitiesModuleInst.spectatedCommunityPermissionModel : null
        communityPermissionsCheckOngoing: !!d.currentCommunityModule ?
                                              d.currentCommunityModule.permissionsCheckOngoing : false
        chatPermissionsCheckOngoing: !!d.currentChatContentModule ?
                                         d.currentChatContentModule.permissionsCheckOngoing : false

        onAcceptRequestToJoinCommunityRequested: (requestId, communityId) => {
            d.currentCommunityModule.acceptRequestToJoinCommunity(requestId, communityId)
        }
        onDeclineRequestToJoinCommunityRequested: (requestId, communityId) => {
            d.currentCommunityModule.declineRequestToJoinCommunity(requestId, communityId)
        }
    }

    readonly property PermissionsStore communityPermissionsStore: PermissionsStore {
        activeSectionId: d.mainModuleInst.activeSection.id
        activeChannelId: d.currentChatContentModule ? d.currentChatContentModule.chatDetails.id : ""
        permissionsModel: d.currentCommunityModule ? d.currentCommunityModule.permissionsModel: null
        allTokenRequirementsMet: d.currentCommunityModule ? d.currentCommunityModule.allTokenRequirementsMet : false

        onCreateOrEditCommunityTokenPermission: (key, permissionType, holdings, channels, isPrivate) => {
            d.currentCommunityModule.createOrEditCommunityTokenPermission(key, permissionType, holdings, channels, isPrivate)
        }
        onDeleteCommunityTokenPermission: (key) => {
            d.currentCommunityModule.deleteCommunityTokenPermission(key)
        }
    }

    // **
    // ** Stores' internal API region:
    // **

    QtObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var communitiesModuleInst: communitiesModule

        // Foreach `communityId` there will be the corresponding community module:
        property var currentCommunityModule: {
            return d.getCurrentCommunityModule(root.communityId)
        }

        // Foreach `communityId` there will be the corresponding active chat content module:
        property var currentChatContentModule: {
            return d.getChatContentModule(d.currentCommunityModule)
        }

        // This is the community section details for this specific `communityId`
        readonly property var communityDetails: d.communityDetailsEntry.item

        readonly property ModelEntry communityDetailsEntry: ModelEntry {
            key: "id"
            sourceModel: d.mainModuleInst.sectionsModel
            value: root.communityId
        }

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
}
