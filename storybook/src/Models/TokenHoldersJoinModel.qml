import QtModelsToolkit 1.0

LeftJoinModel {
    id: root

    leftModel: RolesRenamingModel {
        sourceModel: TokenHoldersModel {}
        mapping: [
            RoleRename {
                from: "contactId"
                to: "pubKey"
            }
        ]
    }
    rightModel: UsersModel {}
    joinRole: "pubKey"
}
