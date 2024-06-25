import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property var data: [
        {
            name: "helloworld",
            emoji: "😋",
            colorId: Constants.walletAccountColors.primary,
            color: "#2A4AF5",
            address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
            walletType: "",
            position: 0,
            assets: [
                {
                    symbol: "socks",
                    enabledNetworkBalance: {
                        displayDecimals: 2,
                        stripTrailingZeroes: true,
                        amount: 15.0,
                        symbol: "SOX"
                    }
                },
                {
                    symbol: "snt",
                    enabledNetworkBalance: {
                        displayDecimals: 2,
                        stripTrailingZeroes: true,
                        amount: 670.2345,
                        symbol: "SNT"
                    }
                },
                {
                    symbol: "zrx",
                    enabledNetworkBalance: {
                        displayDecimals: 4,
                        stripTrailingZeroes: true,
                        amount: 7.456000,
                        symbol: "ZRX"
                    }
                }
            ],
            preferredSharingChainIds: "5:420:421613",
            currencyBalance: ({amount: 1.25,
                                  symbol: "USD",
                                  displayDecimals: 2,
                                  stripTrailingZeroes: false}),
            migratedToKeycard: true
        },
        {
            name: "Hot wallet (generated)",
            emoji: "🚗",
            colorId: Constants.walletAccountColors.army,
            color: "#216266",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
            walletType: Constants.generatedWalletType,
            position: 3,
            assets: [
                {
                    symbol: "deadbeef",
                    enabledNetworkBalance: {
                        displayDecimals: 1,
                        stripTrailingZeroes: true,
                        amount: 1,
                        symbol: "DBF"
                    }
                }
            ],
            preferredSharingChainIds: "5:420:421613",
            currencyBalance: ({amount: 10,
                                  symbol: "USD",
                                  displayDecimals: 2,
                                  stripTrailingZeroes: false}),
            migratedToKeycard: false
        },
        {
            name: "Family (seed)",
            emoji: "🎨",
            colorId: Constants.walletAccountColors.magenta,
            color: "#EC266C",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
            walletType: Constants.seedWalletType,
            position: 1,
            assets: [
                {
                    symbol: "Aave",
                    enabledNetworkBalance: {
                        displayDecimals: 6,
                        stripTrailingZeroes: true,
                        amount: 42,
                        symbol: "AAVE"
                    }
                },
                {
                    symbol: "dai",
                    enabledNetworkBalance: {
                        displayDecimals: 2,
                        stripTrailingZeroes: true,
                        amount: 120.123,
                        symbol: "DAI"
                    }
                }
            ],
            preferredSharingChainIds: "5:420:421613",
            currencyBalance: ({amount: 110.05,
                                  symbol: "USD",
                                  displayDecimals: 2,
                                  stripTrailingZeroes: false}),
            migratedToKeycard: false
        },
        {
            name: "Tag Heuer (watch)",
            emoji: "⌚",
            colorId: Constants.walletAccountColors.copper,
            color: "#CB6256",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
            walletType: Constants.watchWalletType,
            position: 2,
            assets: [
            ],
            preferredSharingChainIds: "5:420:421613",
            currencyBalance: ({amount: 3,
                                  symbol: "USD",
                                  displayDecimals: 2,
                                  stripTrailingZeroes: false}),
            migratedToKeycard: false
        },
        {
            name: "Fab (key)",
            emoji: "🔑",
            colorId: Constants.walletAccountColors.camel,
            color: "#C78F67",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8884",
            walletType: Constants.keyWalletType,
            position: 4,
            assets: [
                {
                    symbol: "socks",
                    enabledNetworkBalance: {
                        displayDecimals: 2,
                        stripTrailingZeroes: false,
                        amount: 3.5,
                        symbol: "SOX"
                    }
                }
            ],
            preferredSharingChainIds: "5:420:421613",
            currencyBalance: ({amount: 999,
                                  symbol: "USD",
                                  displayDecimals: 2,
                                  stripTrailingZeroes: false}),
            migratedToKeycard: false
        }
    ]

    Component.onCompleted: append(data)
}
