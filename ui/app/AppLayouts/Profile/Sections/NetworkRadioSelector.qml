import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

StatusRadioButtonRow {
    property string network: ""
    property string networkName: ""
    property string newNetwork: ""
    id: radioProd
    text: networkName == "" ? Utils.getNetworkName(network) : networkName
    buttonGroup: networkSettings
    checked: profileModel.network.current  === network
    onRadioCheckedChanged: {
        if (checked) {
            if (profileModel.network.current === network) return;
            newNetwork = network;
            confirmDialog.open();
        }
    }

    ConfirmationDialog {
        id: confirmDialog
        //% "Warning!"
        title: qsTrId("close-app-title")
        //% "The account will be logged out. When you unlock it again, the selected network will be used"
        confirmationText: qsTrId("logout-app-content")
        onConfirmButtonClicked: {
            profileModel.network.current = newNetwork;
        }
        onClosed: profileModel.network.triggerNetworkChange()
    }
}
