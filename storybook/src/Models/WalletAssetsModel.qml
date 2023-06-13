import QtQuick 2.15

ListModel {
    readonly property var data: [
        {
            totalBalance: 323.3,
            decimals: 2,
            totalCurrencyBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 3.234
            }),
            visibleForNetwork: true,
            symbol: "ETH",
            name: "Ethereum",
            balances: [
                {
                    chainId: "chain_1_id",
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
            totalBalance: 324343.3,
            decimals: 2,
            totalCurrencyBalance: ({
                displayDecimals: true,
                stripTrailingZeroes: true,
                amount: 23333213.234
            }),
            visibleForNetwork: true,
            symbol: "SNT",
            name: "Status",
            balances: [
                {
                    chainId: "chain_1_id",
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
    ]

    Component.onCompleted: append(data)
}
