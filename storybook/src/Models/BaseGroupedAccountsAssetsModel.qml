import QtQuick

import utils

ListModel {

    readonly property var data: [
        {
            key: Constants.daiGroupKey,
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.daiGroupKey, tokenKey: "1-0x6b175474e89094c44da98b954eedeac495271d0f", chainId: 1, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271d0f", balance: "0" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.daiGroupKey, tokenKey: "10-0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", chainId: 10, tokenAddress: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", balance: "987654321000000000" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.daiGroupKey, tokenKey: "42161-0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", chainId: 42161, tokenAddress: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", balance: "0" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.daiGroupKey, tokenKey: "11155111-0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6", chainId: 11155111, tokenAddress: "0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6", balance: "0" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.daiGroupKey, tokenKey: "1-0x6b175474e89094c44da98b954eedeac495271d0f", chainId: 1, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271d0f", balance: "0" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.daiGroupKey, tokenKey: "10-0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", chainId: 10, tokenAddress: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.daiGroupKey, tokenKey: "11155111-0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6", chainId: 11155111, tokenAddress: "0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6", balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.daiGroupKey, tokenKey: "42161-0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", chainId: 42161, tokenAddress: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1", balance: "45123456789123456789" },
            ]
        },
        {
            key: Constants.ethGroupKey,
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.ethGroupKey, tokenKey: "1-0x0000000000000000000000000000000000000000", chainId: 1, tokenAddress: "0x0000000000000000000000000000000000000000", balance: "122082928968121891" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.ethGroupKey, tokenKey: "11155420-0x0000000000000000000000000000000000000000", chainId: 11155420, tokenAddress: "0x0000000000000000000000000000000000000000", balance: "1013151281976507736" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.ethGroupKey, tokenKey: "421614-0x0000000000000000000000000000000000000000", chainId: 421614, tokenAddress: "0x0000000000000000000000000000000000000000", balance: "473057568699284613" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.ethGroupKey, tokenKey: "11155111-0x0000000000000000000000000000000000000000", chainId: 11155111, tokenAddress: "0x0000000000000000000000000000000000000000", balance: "307400931315122839" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.ethGroupKey, tokenKey: "11155420-0x0000000000000000000000000000000000000000", chainId: 11155420, tokenAddress: "0x0000000000000000000000000000000000000000", balance: "122082928968121891" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.ethGroupKey, tokenKey: "421614-0x0000000000000000000000000000000000000000", chainId: 421614, tokenAddress: "0x0000000000000000000000000000000000000000", balance: "0" },
            ]
        },
        {
            key: Constants.sttGroupKey,
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.sttGroupKey, tokenKey: "11155111-0xe452027cdef746c7cd3db31cb700428b16cd8e51", chainId: 11155111, tokenAddress: "0xe452027cdef746c7cd3db31cb700428b16cd8e51", balance: "45123456789123456789" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.sttGroupKey, tokenKey: "11155420-0x0b5dad18b8791ddb24252b433ec4f21f9e6e5ed0", chainId: 11155420, tokenAddress: "0x0b5dad18b8791ddb24252b433ec4f21f9e6e5ed0", balance: "999999999998998500000000000016777216" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.sttGroupKey, tokenKey: "84532-0xfdb3b57944943a7724fcc0520ee2b10659969a06", chainId: 84532, tokenAddress: "0xfdb3b57944943a7724fcc0520ee2b10659969a06", balance: "1077000000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.sttGroupKey, tokenKey: "11155420-0x0b5dad18b8791ddb24252b433ec4f21f9e6e5ed0", chainId: 11155420, tokenAddress: "0x0b5dad18b8791ddb24252b433ec4f21f9e6e5ed0", balance: "122082928968121891" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.sttGroupKey, tokenKey: "84532-0xfdb3b57944943a7724fcc0520ee2b10659969a06", chainId: 84532, tokenAddress: "0xfdb3b57944943a7724fcc0520ee2b10659969a06", balance: "222000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.sttGroupKey, tokenKey: "11155111-0xe452027cdef746c7cd3db31cb700428b16cd8e51", chainId: 11155111, tokenAddress: "0xe452027cdef746c7cd3db31cb700428b16cd8e51", balance: "559133758939097000" }
            ]
        },
        {
            key: Constants.usdcGroupKeyEvm,
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.usdcGroupKeyEvm, tokenKey: "1-0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", chainId: 1, tokenAddress: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", balance: "45123456789123456789" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.usdcGroupKeyEvm, tokenKey: "11155420-0x5fd84259d66cd46123540766be93dfe6d43130d7", chainId: 11155420, tokenAddress: "0x5fd84259d66cd46123540766be93dfe6d43130d7", balance: "999999999998998500000000000016777216" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.usdcGroupKeyEvm, tokenKey: "10-0x0b2c639c533813f4aa9d7837caf62653d097ff85", chainId: 10, tokenAddress: "0x0b2c639c533813f4aa9d7837caf62653d097ff85", balance: "1077000000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.usdcGroupKeyEvm, tokenKey: "11155420-0x5fd84259d66cd46123540766be93dfe6d43130d7", chainId: 11155420, tokenAddress: "0x5fd84259d66cd46123540766be93dfe6d43130d7", balance: "122082928968121891" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.usdcGroupKeyEvm, tokenKey: "421614-0x75faf114eafb1bdbe2f0316df893fd58ce46aa4d", chainId: 421614, tokenAddress: "0x75faf114eafb1bdbe2f0316df893fd58ce46aa4d", balance: "222000000000000000" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.usdcGroupKeyEvm, tokenKey: "11155111-0x1c7d4b196cb0c7b01d743fbc6116a902379c7238", chainId: 11155111, tokenAddress: "0x1c7d4b196cb0c7b01d743fbc6116a902379c7238", balance: "559133758939097000" }
            ]
        },
        {
            key: Constants.aaveGroupKey,
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.aaveGroupKey, tokenKey: "10-0x76fb31fb4af56892a25e32cfc43de717950c9278", chainId: 10, tokenAddress: "0x76fb31fb4af56892a25e32cfc43de717950c9278", balance: "559133758939097000" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.aaveGroupKey, tokenKey: "42161-0xba5ddd1f9d7f570dc94a51479a000e3bce967196", chainId: 42161, tokenAddress: "0xba5ddd1f9d7f570dc94a51479a000e3bce967196", balance: "0" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: Constants.aaveGroupKey, tokenKey: "1-0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9", chainId: 1, tokenAddress: "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9", balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.aaveGroupKey, tokenKey: "10-0x76fb31fb4af56892a25e32cfc43de717950c9278", chainId: 10, tokenAddress: "0x76fb31fb4af56892a25e32cfc43de717950c9278", balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.aaveGroupKey, tokenKey: "1-0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9", chainId: 1, tokenAddress: "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9", balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: Constants.aaveGroupKey, tokenKey: "42161-0xba5ddd1f9d7f570dc94a51479a000e3bce967196", chainId: 42161, tokenAddress: "0xba5ddd1f9d7f570dc94a51479a000e3bce967196", balance: "45123456789123456789" },
            ]
        },
        {
            key: "11155420-0x6b175474e89094c44da98b954eedeac495271e0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: "11155420-0x6b175474e89094c44da98b954eedeac495271e0f", tokenKey: "11155420-0x6b175474e89094c44da98b954eedeac495271e0f", chainId: 11155420, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271e0f", balance: "100" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: "11155420-0x6b175474e89094c44da98b954eedeac495271e0f", tokenKey: "11155420-0x6b175474e89094c44da98b954eedeac495271e0f", chainId: 11155420, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271e0f", balance: "1" }
            ]
        },
        {
            key: "11155420-0x6b175474e89094c44da98b954eedeac495271p0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: "11155420-0x6b175474e89094c44da98b954eedeac495271p0f", tokenKey: "11155420-0x6b175474e89094c44da98b954eedeac495271p0f", chainId: 11155420, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271p0f", balance: "20" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: "11155420-0x6b175474e89094c44da98b954eedeac495271p0f", tokenKey: "11155420-0x6b175474e89094c44da98b954eedeac495271p0f", chainId: 11155420, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271p0f", balance: "10" }
            ]
        },
        {
            key: "11155420-0x6b175474e89094c44da98b954eedeac495271a0f",
            balances: [
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", groupKey: "11155420-0x6b175474e89094c44da98b954eedeac495271a0f", tokenKey: "11155420-0x6b175474e89094c44da98b954eedeac495271a0f", chainId: 11155420, tokenAddress: "0x6b175474e89094c44da98b954eedeac495271a0f", balance: "1" }
            ]
        },
        {
            key: "ddls-community-token",
            balances: [
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", groupKey: "ddls-community-token", tokenKey: "11155420-ddls-token", chainId: 11155420, tokenAddress: "0x00000000000000000000000000000000000000dd", balance: "2500000000000000000" }
            ]
        }
    ]

    Component.onCompleted: append(data)
}
