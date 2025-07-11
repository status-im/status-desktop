import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared
import shared.popups
import shared.status

import AppLayouts.Profile.stores

import "../controls"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    title: qsTr("Fleet")

    property AdvancedStore advancedStore

    property string newFleet: "";

    Column {
        id: column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 0

        ButtonGroup { id: fleetSettings }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.waku_sandbox
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.waku_test
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.status_prod
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.status_staging
            buttonGroup: fleetSettings
        }
    }
}
