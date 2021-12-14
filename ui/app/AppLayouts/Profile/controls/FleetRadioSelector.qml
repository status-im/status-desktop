import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.popups 1.0
import shared.controls 1.0

RadioButtonSelector {
    id: root

    property var advancedStore

    property string fleetName: ""
    property string newFleet: ""

    title: fleetName
    checked: root.advancedStore.fleet === root.fleetName

    onCheckedChanged: {
        if (checked) {
            if (root.advancedStore.fleet === root.fleetName)
                return

            root.newFleet = root.fleetName;
            Global.openPopup(confirmDialogComponent)
        }
    }

    Component {
        id: confirmDialogComponent
        ConfirmationDialog {
            //% "Warning!"
            header.title: qsTrId("close-app-title")
            //% "Change fleet to %1"
            confirmationText: qsTrId("change-fleet-to--1").arg(root.newFleet)
            onConfirmButtonClicked: {
                root.advancedStore.setFleet(root.newFleet)
            }
            onClosed: {
                destroy();
            }
        }
    }
}
