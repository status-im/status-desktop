import QtQml

import SortFilterProxyModel

import StatusQ

import utils

QtObject {
    id: root

    required property string activeSectionId
    required property string activeChannelId
    required property bool allTokenRequirementsMet
    required property var permissionsModel

    readonly property var selectedChannelPermissionsModel: SortFilterProxyModel {
        id: selectedChannelPermissionsModel
        sourceModel: root.permissionsModel

        function filterPredicate(modelData) {
            return root.permissionsModel.belongsToChat(modelData.id, root.activeChannelId) &&
                    (modelData.tokenCriteriaMet || !modelData.isPrivate)
        }
        filters: [
            FastExpressionFilter {
                expression: {
                    root.activeChannelId // ensure predicate is re-triggered when activeChannelId changes
                    selectedChannelPermissionsModel.filterPredicate(model)
                }
                expectedRoles: ["id", "tokenCriteriaMet", "isPrivate"]
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
            FastExpressionFilter {
                expression: {
                    root.activeChannelId // ensure predicate is re-triggered when activeChannelId changes
                    viewOnlyPermissionsModel.filterPredicate(model)
                }
                expectedRoles: ["id", "tokenCriteriaMet", "isPrivate", "permissionType"]
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
            FastExpressionFilter {
                expression: {
                    root.activeChannelId // ensure predicate is re-triggered when activeChannelId changes
                    viewAndPostPermissionsModel.filterPredicate(model)
                }
                expectedRoles: ["id", "tokenCriteriaMet", "isPrivate", "permissionType"]
            }
        ]
    }

    readonly property var becomeMemberPermissionsModel: SortFilterProxyModel {
        id: becomeMemberPermissionsModel
        sourceModel: root.permissionsModel
        function filterPredicate(permissionType) {
            return (permissionType === Constants.permissionType.member ||
                    permissionType === Constants.permissionType.admin ||
                    permissionType === Constants.permissionType.becomeTokenMaster)
        }
        filters: [
            FastExpressionFilter {
                expression: { return becomeMemberPermissionsModel.filterPredicate(model.permissionType) }
                expectedRoles: ["permissionType"]
            }
        ]
    }

    readonly property bool isOwner: false

    signal createOrEditCommunityTokenPermission(string key, int permissionType, var holdings, var channels, bool isPrivate)
    signal deleteCommunityTokenPermission(string key)

    function createPermission(holdings, permissionType, isPrivate, channels) {
        root.createOrEditCommunityTokenPermission(
                    "",
                    permissionType,
                    JSON.stringify(holdings),
                    channels.map(c => c.key).join(","),
                    isPrivate)
    }

    function editPermission(key, holdings, permissionType, channels, isPrivate) {
        root.createOrEditCommunityTokenPermission(
                    key,
                    permissionType,
                    JSON.stringify(holdings),
                    channels.map(c => c.key).join(","),
                    isPrivate)
    }

    function removePermission(key) {
        root.deleteCommunityTokenPermission(key)
    }
}
