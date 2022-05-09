import QtQuick 2.13

import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import utils 1.0

import "../../stores"
import "../../controls"

Item {
    id: root

    property WalletStore walletStore

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width

        PermissionsListView {
            id: permissionsList
            width: parent.width
            walletStore: root.walletStore
        }
    }
}
