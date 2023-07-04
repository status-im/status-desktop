import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property var data: [
        {
            name: "helloworld",
            emoji: "😋",
            colorId: "primary",
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
            ]
        },
        {
            name: "Hot wallet (generated)",
            emoji: "🚗",
            colorId: "army",
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
            ]
        },
        {
            name: "Family (seed)",
            emoji: "🎨", colorId: "magenta",
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
            ]
        },
        {
            name: "Tag Heuer (watch)",
            emoji: "⌚",
            colorId: "copper",
            address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
            walletType: Constants.watchWalletType,
            position: 2,
            assets: [
            ]
        },
        {
            name: "Fab (key)",
            emoji: "⌚",
            colorId: Constants.walletAccountColors.camel,
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
            ]
        }
    ]

    Component.onCompleted: append(data)
}
