import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

import "../controls"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    //% "Fleet"
    title: qsTrId("fleet")

    property string newFleet: "";
    
    Column {
        id: column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        ButtonGroup { id: fleetSettings }

        FleetRadioSelector {
            fleetName: Constants.eth_prod
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            fleetName: Constants.eth_staging
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            fleetName: Constants.eth_test
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            fleetName: Constants.waku_prod
            buttonGroup: fleetSettings
        }

        FleetRadioSelector {
            fleetName: Constants.waku_test
            buttonGroup: fleetSettings
        }
    }
}
