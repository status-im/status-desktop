import QtQml 2.15

QtObject {
    id: root

    required property string activeSectionId
    required property var chatCommunitySectionModuleInst

    readonly property var permissionsModel:
        chatCommunitySectionModuleInst.permissionsModel

    readonly property bool isOwner: false

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
