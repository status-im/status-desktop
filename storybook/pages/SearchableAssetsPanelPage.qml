import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import AppLayouts.Wallet.panels 1.0
import utils 1.0

Pane {
    readonly property var assetsData: [
        {
            tokensKey: "key_1",
            communityId: "",
            name: "Status Test Token",
            currencyBalanceAsString: "42,23 USD",
            symbol: "STT",
            iconSource: Constants.tokenIcon("STT"),
            tokensKey: "STT",
            balances: [
                {
                    balanceAsString: "0,56",
                    iconUrl: "network/Network=Ethereum"
                },
                {
                    balanceAsString: "0,22",
                    iconUrl: "network/Network=Arbitrum"
                },
                {
                    balanceAsString: "0,12",
                    iconUrl: "network/Network=Optimism"
                }
            ],

            sectionText: ""
        },
        {
            tokensKey: "key_2",
            communityId: "",
            name: "Ether",
            currencyBalanceAsString: "4 276,86 USD",
            symbol: "ETH",
            iconSource: Constants.tokenIcon("ETH"),
            tokensKey: "ETH",
            balances: [
                {
                    balanceAsString: "1,01",
                    iconUrl: "network/Network=Optimism"
                },
                {
                    balanceAsString: "0,47",
                    iconUrl: "network/Network=Arbitrum"
                },
                {
                    balanceAsString: "0,12",
                    iconUrl: "network/Network=Ethereum"
                }
            ],

            sectionText: ""
        },
        {
            tokensKey: "key_2",
            communityId: "",
            name: "Dai Stablecoin",
            currencyBalanceAsString: "45,92 USD",
            symbol: "DAI",
            iconSource: Constants.tokenIcon("DAI"),
            tokensKey: "DAI",
            balances: [],

            sectionText: "Popular assets"
        },
        {
            tokensKey: "key_3",
            communityId: "",
            name: "0x",
            currencyBalanceAsString: "41,22 USD",
            symbol: "ZRX",
            iconSource: Constants.tokenIcon("ZRX"),
            tokensKey: "ZRX",
            balances: [],

            sectionText: "Popular assets"
        }
    ]

    ListModel {
        id: assetsModel

        Component.onCompleted: append(assetsData)
    }

    Rectangle {
        anchors.fill: panel
        anchors.margins: -1

        color: "transparent"
        border.color: "lightgray"
    }

    SearchableAssetsPanel {
        id: panel

        anchors.centerIn: parent

        width: 350

        model: assetsModel
        sectionProperty: "sectionText"
    }
}

// category: Panels
