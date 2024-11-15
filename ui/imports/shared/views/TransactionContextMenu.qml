import QtQuick 2.15

import StatusQ.Popups 0.1

StatusMenu {
    id: root

    required property string networkExplorerName

    signal viewTxOnExplorerRequested
    signal copyTxHashRequested

    StatusAction {
        objectName: "viewTxOnExplorerItem"
        text: qsTr("View on ") + networkExplorerName
        icon.name: "link"
        onTriggered: root.viewTxOnExplorerRequested()
    }
    StatusAction {
        objectName: "copyTxHashItem"
        text: qsTr("Copy transaction hash")
        icon.name: "copy"
        onTriggered: root.copyTxHashRequested()
    }
}
