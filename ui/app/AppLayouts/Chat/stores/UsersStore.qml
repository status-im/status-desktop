import QtQuick 2.15

QtObject {
    id: root

    // External properties:
    required property var chatCommunitySectionModule
    required property var usersModule
    required property bool isFullCommunityMembers

    // Public API:
    readonly property var usersModel: {
        if (root.isFullCommunityMembers) {
            // Community channel with no permisisons. We can use the section's membersModel
            return root.chatCommunitySectionModule ? root.chatCommunitySectionModule.membersModel : null
        }
        return root.usersModule ? root.usersModule.model : null
    }

    // Used for editing:
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
