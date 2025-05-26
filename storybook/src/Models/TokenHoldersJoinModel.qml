import QtQuick 2.15

import StatusQ 0.1

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
