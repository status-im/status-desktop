import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import "../../../../shared/controls"
import "../../../../shared/popups"

RadioButtonSelector {
    id: root

    property string fleetName: ""
    property string newFleet: ""

    title: fleetName
    checked: profileModel.fleets.fleet === root.fleetName

    onCheckedChanged: {
        if (checked) {
            if (profileModel.fleets.fleet === root.fleetName) return;
            root.newFleet = root.fleetName;
            openPopup(confirmDialogComponent)
        }
    }

    Component {
        id: confirmDialogComponent
        ConfirmationDialog {
            //% "Warning!"
            header.title: qsTrId("close-app-title")
            //% "Change fleet to %1"
            confirmationText: qsTrId("change-fleet-to--1").arg(root.newFleet)
            onConfirmButtonClicked: profileModel.fleets.setFleet(root.newFleet)
            onClosed: {
                profileModel.fleets.triggerFleetChange()
                destroy();
            }
        }
    }
}
