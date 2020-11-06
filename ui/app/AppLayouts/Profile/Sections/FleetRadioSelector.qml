import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

RowLayout {
    property string fleetName: ""
    property string newFleet: ""

    ConfirmationDialog {
        id: confirmDialog
        title: qsTr("Warning!")
        confirmationText: qsTr("Change fleet to %1").arg(newFleet)
        onConfirmButtonClicked: profileModel.fleets.setFleet(newFleet)
        onClosed: profileModel.fleets.triggerFleetChange()
    }


    width: parent.width
    StyledText {
        text: fleetName
        font.pixelSize: 15
    }
    StatusRadioButton {
        id: radioProd
        Layout.alignment: Qt.AlignRight
        ButtonGroup.group: fleetSettings
        rightPadding: 0
        checked: profileModel.fleets.fleet === fleetName
        onClicked: {
            if (profileModel.fleets.fleet === fleetName) return;
            newFleet = fleetName;
            confirmDialog.open();
        }
    }
}
