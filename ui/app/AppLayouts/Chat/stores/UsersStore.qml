import QtQuick 2.15

QtObject {
    id: root

    // Required from outside:
    /*required*/property var chatDetails
    /*required*/property var usersModule
    /*required*/property var membersModel // It will contain all the community members

    // PRIVATE API assigned from outsite:
    property QtObject _d: QtObject {
        property bool contentRequiresPermissions: root.chatDetails.requiresPermissions
        property bool contentBelongsToCommunity: root.chatDetails.belongsToCommunity
    }
    // End of PRIVATE API

    // PUBLIC API:
    // TODO: This is a workaround to get users list depending on specific cases and should be done on the backend,
    // the UI just wants a list of users specific for the case it's displaying data
    readonly property var usersModel: {
        if (_d.contentBelongsToCommunity && !_d.contentRequiresPermissions) {
            // It contains all members of the community. Useful for public chats or private ones with no permisisons
            return root.membersModel
        }
        // It contains just the specific members of a chat / channel
        return !!root.usersModule ? root.usersModule.model : null
    }

    // Used when editting
    readonly property var temporaryModel: root.usersModule ? root.usersModule.temporaryModel : null

    function appendTemporaryModel(pubKey, displayName) {
        root.usersModule.appendTemporaryModel(pubKey, displayName)
    }
    function removeFromTemporaryModel(pubKey) {
        root.usersModule.removeFromTemporaryModel(pubKey)
    }
    function resetTemporaryModel() {
        root.usersModule.resetTemporaryModel()
    }
    function updateGroupMembers() {
        root.usersModule.updateGroupMembers()
    }
}
