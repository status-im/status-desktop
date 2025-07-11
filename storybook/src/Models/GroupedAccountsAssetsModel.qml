import QtQuick

ListModel {
    readonly property var data: [
        {
            tokensKey: "DAI",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 10, balance: "559133758939097000" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "0" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155111, balance: "0" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155111, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 42161, balance: "45123456789123456789" },
            ]
        },
        {
            tokensKey: "ETH",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 1, balance: "122082928968121891" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "1013151281976507736" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 421614, balance: "473057568699284613" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155111, balance: "307400931315122839" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "122082928968121891" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 421614, balance: "0" },
            ]
        },
        {
            tokensKey: "STT",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 1, balance: "45123456789123456789" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "999999999998998500000000000016777216" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 10, balance: "1077000000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "122082928968121891" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 421614, balance: "222000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155111, balance: "559133758939097000" }
            ]
        },
        {
            tokensKey: "USDC (EVM)",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 1, balance: "45123456789123456789" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "999999999998998500000000000016777216" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 10, balance: "1077000000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "122082928968121891" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 421614, balance: "222000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155111, balance: "559133758939097000" }
            ]
        },
        {
            tokensKey: "aave",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 10, balance: "559133758939097000" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "0" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155111, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155111, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 42161, balance: "45123456789123456789" },
            ]
        },
        {
            tokensKey: "0x6b175474e89094c44da98b954eedeac495271e0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "100" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "1" }
            ]
        },
        {
            tokensKey: "0x6b175474e89094c44da98b954eedeac495271p0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "20" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "10" }
            ]
        },
        {
            tokensKey: "0x6b175474e89094c44da98b954eedeac495271d0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "1" }
            ]
        },
        {
            tokensKey: "0x6b175474e89094c44da98b954eedeac495271a0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "1" }
            ]
        }
    ]

    Component.onCompleted: append(data)
}
