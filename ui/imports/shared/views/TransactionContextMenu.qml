import QtQuick

import StatusQ.Popups

StatusMenu {
    id: root

    required property string networkExplorerName

    signal viewTxOnExplorerRequested
    signal copyTxHashRequested

    StatusAction {
        objectName: "viewTxOnExplorerItem"
        text: qsTr("View on %1").arg(networkExplorerName)
        icon.name: "link"
        onTriggered: root.viewTxOnExplorerRequested()
    }
    StatusSuccessAction {
        objectName: "copyTxHashItem"
        text: qsTr("Copy transaction hash")
        successText: qsTr("Copied")
        icon.name: "copy"
        onTriggered: root.copyTxHashRequested()
    }
}
