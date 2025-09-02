import QtQuick

import SortFilterProxyModel
import QtModelsToolkit

import StatusQ.Core.Utils as StatusQUtils

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
        chatPermissionsCheckOngoing: !!d.currentChannelItem ? d.currentChannelItem.permissionsCheckOngoing : false

        onAcceptRequestToJoinCommunityRequested: (requestId, communityId) => {
            d.currentCommunityModule.acceptRequestToJoinCommunity(requestId, communityId)
        }
        onDeclineRequestToJoinCommunityRequested: (requestId, communityId) => {
            d.currentCommunityModule.declineRequestToJoinCommunity(requestId, communityId)
        }
    }

    readonly property PermissionsStore communityPermissionsStore: PermissionsStore {
        activeSectionId: d.mainModuleInst.activeSection.id
        activeChannelId: d.currentChannelItem ? d.currentChannelItem.id : ""
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

        // This will contain the active channel content item:
        property var currentChannelItem: d.currentCommunityModule ? d.currentCommunityModule.activeItem : null

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
    }
}
