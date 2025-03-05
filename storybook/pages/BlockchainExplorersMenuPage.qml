import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Popups 0.1

import shared.popups 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    orientation: Qt.Vertical

    Item {

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Column {
            anchors.centerIn: parent
            Button {
                text: "Reopen menuItem"

                onClicked: menuItem.open()
            }

            spacing: 10
            
            Button {
                text: "Reopen popup"

                onClicked: popup.open()
            }
        }
    }

    StatusMenu {
        id: menuItem
        anchors.centerIn: parent
        modal: false
        visible: false

        BlockchainExplorersMenu {
            flatNetworks: NetworksModel.flatNetworks
            onNetworkClicked: {
                console.log("Network clicked: ", chainId, index)
            }
        }
    }

    BlockchainExplorersMenu {
        id: popup
        anchors.centerIn: parent
        modal: false
        visible: false

        flatNetworks: NetworksModel.flatNetworks
        onNetworkClicked: {
            console.log("Network clicked: ", chainId, index)
        }
    }
}

// category: Popups

// https://www.figma.com/design/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=27895-379508&m=dev
