import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

RowLayout {
    property string networkName: ""
    property string newNetwork: ""

    ConfirmationDialog {
        id: confirmDialog
        title: qsTr("Warning!")
        confirmationText: qsTr("The account will be logged out. When you unlock it again, the selected network will be used")
        onConfirmButtonClicked: {
            profileModel.network = newNetwork;
        }
        onClosed: profileModel.triggerNetworkChange()
    }

    width: parent.width
    StyledText {
        text: qsTrId(networkName)
        font.pixelSize: 15
    }
    StatusRadioButton {
        id: radioProd
        Layout.alignment: Qt.AlignRight
        ButtonGroup.group: networkSettings
        rightPadding: 0
        checked: profileModel.network  === networkName
        onClicked: {
            if (profileModel.network === networkName) return;
            newNetwork = networkName;
            confirmDialog.open();
        }
    }
}
