import QtQml 2.15

import SortFilterProxyModel 0.2
import utils 1.0

QtObject {
    id: root

    required property string activeSectionId
    required property string activeChannelId
    required property var chatCommunitySectionModuleInst

    // all permissions model
    readonly property var permissionsModel:
        chatCommunitySectionModuleInst.permissionsModel

    readonly property var becomeMemberPermissionsModel: SortFilterProxyModel {
        id: becomeMemberPermissionsModel
        sourceModel: root.permissionsModel
        function filterPredicate(modelData) {
            return (modelData.permissionType == Constants.permissionType.member) &&
                (modelData.tokenCriteriaMet || !modelData.isPrivate)
        }
        filters: [
            ExpressionFilter {
                expression: becomeMemberPermissionsModel.filterPredicate(model)
            }
        ]
    }

    readonly property var viewOnlyPermissionsModel: SortFilterProxyModel {
        id: viewOnlyPermissionsModel
        sourceModel: root.permissionsModel

        function filterPredicate(modelData) {
            return (modelData.permissionType == Constants.permissionType.read) && 
                root.permissionsModel.belongsToChat(modelData.id, root.activeChannelId) &&
                (modelData.tokenCriteriaMet || !modelData.isPrivate)
        }
        filters: [
            ExpressionFilter {
                expression: {
                    root.activeChannelId // ensure predicate is re-triggered when activeChannelId changes
                    viewOnlyPermissionsModel.filterPredicate(model)
                }
            }
        ]
    }

    readonly property var viewAndPostPermissionsModel: SortFilterProxyModel {
        id: viewAndPostPermissionsModel
        sourceModel: root.permissionsModel
        function filterPredicate(modelData) {
            return (modelData.permissionType == Constants.permissionType.viewAndPost) && 
                root.permissionsModel.belongsToChat(modelData.id, root.activeChannelId) &&
                (modelData.tokenCriteriaMet || !modelData.isPrivate)
        }
        filters: [
            ExpressionFilter {
                expression: {
                    root.activeChannelId // ensure predicate is re-triggered when activeChannelId changes
                    viewAndPostPermissionsModel.filterPredicate(model)
                }
            }
        ]
    }

    readonly property bool isOwner: false

    readonly property bool allTokenRequirementsMet: chatCommunitySectionModuleInst.allTokenRequirementsMet

    readonly property QtObject _d: QtObject {
        id: d

        function createPermissionEntry(holdings, permissionType, isPrivate,
                                       channels) {
            return {
                holdingsListModel: holdings,
                channelsListModel: channels,
                permissionType,
                isPrivate
            }
        }

        function createOrEdit(key, holdings, permissionType, isPrivate,
                              channels) {

            root.chatCommunitySectionModuleInst.createOrEditCommunityTokenPermission(
                        root.activeSectionId, key,
                        permissionType,
                        JSON.stringify(holdings),
                        channels.map(c => c.key).join(","),
                        isPrivate)
        }
    }

    function createPermission(holdings, permissionType, isPrivate, channels) {
        d.createOrEdit("", holdings, permissionType, isPrivate, channels)
    }

    function editPermission(key, holdings, permissionType, channels, isPrivate) {
        d.createOrEdit(key, holdings, permissionType, isPrivate, channels)
    }

    function removePermission(key) {
        root.chatCommunitySectionModuleInst.deleteCommunityTokenPermission(
                    root.activeSectionId, key)
    }
}
