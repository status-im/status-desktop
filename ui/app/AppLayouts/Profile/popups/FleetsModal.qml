import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0

import "../controls"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    title: qsTr("Fleet")

    property var advancedStore

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
            fleetName: Constants.eth_prod
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.eth_staging
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.eth_test
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.waku_prod
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.waku_test
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.status_test
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            advancedStore: popup.advancedStore
            fleetName: Constants.status_prod
            buttonGroup: fleetSettings
        }
    }
}
