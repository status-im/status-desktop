import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import shared.popups 1.0
import shared.controls 1.0

RadioButtonSelector {
    id: root

    property string network: ""
    property string networkName: ""
    property string newNetwork: ""
    property var store

    title: networkName === "" ? Utils.getNetworkName(network) : networkName

    checked: root.store.currentNetwork === root.network

    onCheckedChanged: {
        if (checked) {
            if (root.store.currentNetwork === root.network) return;
            root.newNetwork = root.network;
            openPopup(confirmDialogComponent)
        }
    }

    Component {
        id: confirmDialogComponent
        ConfirmationDialog {
            id: confirmDialog
            //% "Warning!"
            header.title: qsTrId("close-app-title")
            //% "The account will be logged out. When you unlock it again, the selected network will be used"
            confirmationText: qsTrId("logout-app-content")
            onConfirmButtonClicked: root.store.changeNetwork(root.newNetwork)
            onClosed: {
                root.store.networkModuleInst.triggerNetworkChange()
                destroy()
            }
        }
    }
}
