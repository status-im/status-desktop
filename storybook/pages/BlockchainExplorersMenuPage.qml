import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Popups

import shared.popups

import Storybook
import Models

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
