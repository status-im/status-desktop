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

    title: networkName == "" ? Utils.getNetworkName(network) : networkName

    onCheckedChanged: {
        if (checked) {
            if (profileModel.network.current === root.network) return;
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
            onConfirmButtonClicked: {
                profileModel.network.current = root.newNetwork;
            }
            onClosed: {
                profileModel.network.triggerNetworkChange()
                destroy()
            }
        }
    }
}
