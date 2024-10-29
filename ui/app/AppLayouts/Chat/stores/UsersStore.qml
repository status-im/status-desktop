import QtQuick 2.15

QtObject {
    id: root

    property var chatCommunitySectionModule
    property var chatDetails
    property var usersModule

    readonly property var usersModel: {
        if (!chatDetails && !chatCommunitySectionModule) {
            return null
        }
        let isFullCommunityList = !chatDetails.requiresPermissions
        if (chatDetails.belongsToCommunity && isFullCommunityList && !!chatCommunitySectionModule) {
            // Community channel with no permisisons. We can use the section's membersModel
            return chatCommunitySectionModule.membersModel
        }
        return usersModule ? usersModule.model : null
    }
    readonly property var temporaryModel: usersModule ? usersModule.temporaryModel : null

    function appendTemporaryModel(pubKey, displayName) {
        usersModule.appendTemporaryModel(pubKey, displayName)
    }
    function removeFromTemporaryModel(pubKey) {
        usersModule.removeFromTemporaryModel(pubKey)
    }
    function resetTemporaryModel() {
        usersModule.resetTemporaryModel()
    }
    function updateGroupMembers() {
        usersModule.updateGroupMembers()
    }
}
