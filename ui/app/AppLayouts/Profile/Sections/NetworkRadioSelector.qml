import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

RowLayout {
    property string network: ""
    property string networkName: ""
    property string newNetwork: ""

    ConfirmationDialog {
        id: confirmDialog
        title: qsTr("Warning!")
        confirmationText: qsTr("The account will be logged out. When you unlock it again, the selected network will be used")
        onConfirmButtonClicked: {
            profileModel.network.current = newNetwork;
        }
        onClosed: profileModel.network.triggerNetworkChange()
    }

    width: parent.width
    StyledText {
        text: networkName == "" ? Utils.getNetworkName(network) : networkName
        font.pixelSize: 15
    }
    StatusRadioButton {
        id: radioProd
        Layout.alignment: Qt.AlignRight
        ButtonGroup.group: networkSettings
        rightPadding: 0
        checked: profileModel.network.current  === network
        onClicked: {
            if (profileModel.network.current === network) return;
            newNetwork = network;
            confirmDialog.open();
        }
    }
}
