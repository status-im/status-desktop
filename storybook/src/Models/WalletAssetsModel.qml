import QtQuick 2.15

ListModel {
    readonly property var data: [
        {
            totalRawBalance: "32330",
            totalBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 323.3,
                symbol: "ETH"
            }),
            decimals: 18,
            totalCurrencyBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 3.234
            }),
            symbol: "ETH",
            name: "Ethereum",
            balances: [
                {
                    chainId: "1",
                    balance: {
                        displayDecimals: true,
                        stripTrailingZeroes: true,
                        amount: 3.234
                    }
                }
            ],
            checked: true,
            allChecked: true
        },
        {
            totalRawBalance: "32434330",
            totalBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 324343.3,
                symbol: "SNT"
            }),
            decimals: 18,
            totalCurrencyBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 23333213.234
            }),
            symbol: "SNT",
            name: "Status",
            balances: [
                {
                    chainId: "1",
                    balance: {
                        displayDecimals: true,
                        stripTrailingZeroes: true,
                        amount: 324343.3
                    }
                }
            ],
            checked: true,
            allChecked: true
        },
        {
            totalRawBalance: "12434330",
            totalBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 124343.3,
                symbol: "DAI"
            }),
            decimals: 18,
            totalCurrencyBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 53333213.234
            }),
            symbol: "DAI",
            name: "DAI Stablecoin",
            balances: [
                {
                    chainId: "1",
                    balance: {
                        displayDecimals: true,
                        stripTrailingZeroes: true,
                        amount: 124343.3
                    }
                }
            ],
            checked: true,
            allChecked: true
        }
    ]

    Component.onCompleted: append(data)
}
