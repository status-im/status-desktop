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
    function groupMembersUpdateRequested(membersPubKeysList) {
        root.usersModule.groupMembersUpdateRequested(membersPubKeysList)
    }
}
