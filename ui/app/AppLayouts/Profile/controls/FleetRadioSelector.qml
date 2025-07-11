import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared.popups
import shared.controls

import AppLayouts.Profile.stores

RadioButtonSelector {
    id: root

    property AdvancedStore advancedStore

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
            headerSettings.title: qsTr("Warning!")
            confirmationText: qsTr("Change fleet to %1").arg(root.newFleet)
            onConfirmButtonClicked: {
                root.advancedStore.setFleet(root.newFleet)
            }
            onClosed: {
                destroy();
            }
        }
    }
}
