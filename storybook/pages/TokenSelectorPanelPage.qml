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
            ]
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
            ]
        },
        {
            tokensKey: "key_2",
            communityId: "",
            name: "Dai Stablecoin",
            currencyBalanceAsString: "45,92 USD",
            symbol: "DAI",
            iconSource: Constants.tokenIcon("DAI"),
            tokensKey: "DAI",

            balances: [
                {
                    balanceAsString: "45,12",
                    iconUrl: "network/Network=Arbitrum"
                },
                {
                    balanceAsString: "0,56",
                    iconUrl: "network/Network=Optimism"
                },
                {
                    balanceAsString: "0,12",
                    iconUrl: "network/Network=Ethereum"
                }
            ]
        }
    ]

    readonly property var collectiblesData: [
        {
            groupName: "My community",
            icon: Constants.tokenIcon("BQX"),
            type: "community",
            subitems: [
                {
                    key: "my_community_key_1",
                    name: "My token",
                    balance: 1,
                    icon: Constants.tokenIcon("CFI"),
                }
            ]
        },
        {
            groupName: "Crypto Kitties",
            icon: Constants.tokenIcon("ENJ"),
            type: "other",
            subitems: [
                {
                    key: "collection_1_key_1",
                    name: "Furbeard",
                    balance: 1,
                    icon: Constants.tokenIcon("FUEL"),
                },
                {
                    key: "collection_1_key_2",
                    name: "Magicat",
                    balance: 1,
                    icon: Constants.tokenIcon("ENJ"),
                },
                {
                    key: "collection_1_key_3",
                    name: "Happy Meow",
                    balance: 1,
                    icon: Constants.tokenIcon("FUN"),
                }
            ]
        },
        {
            groupName: "Super Rare",
            icon: Constants.tokenIcon("CVC"),
            type: "other",
            subitems: [
                {
                    key: "collection_2_key_1",
                    name: "Unicorn 1",
                    balance: 12,
                    icon: Constants.tokenIcon("CVC")
                },
                {
                    key: "collection_2_key_2",
                    name: "Unicorn 2",
                    balance: 1,
                    icon: Constants.tokenIcon("CVC")
                }
            ]
        },
        {
            groupName: "Unicorn",
            icon: Constants.tokenIcon("ELF"),
            type: "other",
            subitems: [
                {
                    key: "collection_3_key_1",
                    name: "Unicorn",
                    balance: 1,
                    icon: Constants.tokenIcon("ELF")
                }
            ]
        }
    ]

    ListModel {
        id: assetsModel

        Component.onCompleted: append(assetsData)
    }

    ListModel {
        id: collectiblesModel

        Component.onCompleted: append(collectiblesData)
    }

    Rectangle {
        anchors.fill: panel
        anchors.margins: -1

        color: "transparent"
        border.color: "lightgray"
    }

    TokenSelectorPanel {
        id: panel

        anchors.centerIn: parent

        width: 350

        assetsModel: assetsModelCheckBox.checked ? assetsModel : null
        collectiblesModel: collectiblesModelCheckBox.checked
                           ? collectiblesModel : null

        onCollectibleSelected: {
            highlightedKey = key
            console.log("collectible selected:", key)
        }

        onCollectionSelected: {
            highlightedKey = key
            console.log("collection selected:", key)
        }

        onAssetSelected: {
            highlightedKey = key
            console.log("asset selected:", key)
        }
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            text: "Select assets tab"

            onClicked: panel.currentTab = TokenSelectorPanel.Tabs.Assets
        }

        Button {
            text: "Select collectibles tab"

            onClicked: panel.currentTab = TokenSelectorPanel.Tabs.Collectibles
        }

        CheckBox {
            id: assetsModelCheckBox

            checked: true
            text: "Assets model assigned"
        }

        CheckBox {
            id: collectiblesModelCheckBox

            checked: true
            text: "Collectibles model assigned"
        }
    }
}

// category: Controls
