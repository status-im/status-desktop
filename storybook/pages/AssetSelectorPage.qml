import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Wallet.controls 1.0
import StatusQ.Core.Theme 0.1
import utils 1.0

Pane {
    readonly property var assetsData: [
        {
            tokensKey: "stt_key",
            communityId: "",
            name: "Status Test Token",
            currencyBalanceAsString: "42,23 USD",
            symbol: "STT",
            iconSource: Constants.tokenIcon("STT"),

            balances: [
                {
                    balanceAsString: "0,56",
                    iconUrl: "network/Network=Ethereum"
                }
            ],

            sectionText: "My assets on Mainnet"
        },
        {
            tokensKey: "eth_key",
            communityId: "",
            name: "Ether",
            currencyBalanceAsString: "4 276,86 USD",
            symbol: "ETH",
            iconSource: Constants.tokenIcon("ETH"),

            balances: [
                {
                    balanceAsString: "0,12",
                    iconUrl: "network/Network=Ethereum"
                }
            ],

            sectionText: "My assets on Mainnet"
        },
        {
            tokensKey: "dai_key",
            communityId: "",
            name: "Dai Stablecoin",
            currencyBalanceAsString: "45,92 USD",
            symbol: "DAI",
            iconSource: Constants.tokenIcon("DAI"),
            balances: [],

            sectionText: "Popular assets"
        },
        {
            tokensKey: "zrx_key",
            communityId: "",
            name: "0x",
            currencyBalanceAsString: "41,22 USD",
            symbol: "ZRX",
            iconSource: Constants.tokenIcon("ZRX"),
            balances: [],

            sectionText: "Popular assets"
        }
    ]

    ListModel {
        id: assetsModel

        Component.onCompleted: append(assetsData)
    }

    background: Rectangle {
        color: Theme.palette.baseColor3
    }

    AssetSelector {
        id: panel

        anchors.centerIn: parent

        model: assetsModel
        sectionProperty: "sectionText"

        onSelected: console.log("asset selected:", key)
    }

    Button {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        text: "reset"

        onClicked: panel.reset()
    }
}

// category: Controls
