import QtQuick 2.15

import utils 1.0

ListModel {
    readonly property string uniswap: "uniswap" //SourceOfTokensModel.uniswap
    readonly property string status: "status" //SourceOfTokensModel.status
    readonly property string custom: "custom" //SourceOfTokensModel.custom
    readonly property string nativeSource: "native" //SourceOfTokensModel.custom

    readonly property var data: [
        {
            key: "ETH",
            name: "Ether",
            symbol: "ETH",
            sources: ";" + nativeSource + ";",
            addressPerChain: [
                { chainId: 1, address: "0x0000000000000000000000000000000000000000"},
                { chainId: 5, address: "0x0000000000000000000000000000000000000000"},
                { chainId: 10, address: "0x0000000000000000000000000000000000000000"},
                { chainId: 420, address: "0x0000000000000000000000000000000000000000"},
                { chainId: 42161, address: "0x0000000000000000000000000000000000000000"},
                { chainId: 421613, address: "0x0000000000000000000000000000000000000000"},
                { chainId: 11155111, address: "0x0000000000000000000000000000000000000000"},
            ],
            decimals: 18,
            type: 1,
            communityId: "",
            description: "Ethereum is a decentralized, open-source blockchain platform that enables developers to build and deploy smart contracts and decentralized applications (dApps). It runs on a global network of nodes, making it highly secure and resistant to censorship. Ethereum introduced the concept of programmable money, allowing users to interact with the blockchain through self-executing contracts, also known as smart contracts. Ethereum's native currency, Ether (ETH), powers these contracts and facilitates transactions on the network.",
            websiteUrl: "https://www.ethereum.org/",
            marketDetails: {
                marketCap: ({amount: 250980621528.3937, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 2090.658790484828, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 2059.795033958552, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0.3655439934313061,
                changePctDay: 1.19243897022671,
                changePct24hour: 0.05209315257442912,
                change24hour: 0.9121310349524345,
                currencyPrice: ({amount: 2098.790000016801, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false,
        },
        {
            key: "STT",
            name: "Status Test Token",
            symbol: "STT",
            sources: ";" + status + ";",
            addressPerChain: [
                {chainId: 5, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"}
            ],
            decimals: 18,
            type: 1,
            communityId: "",
            description: "Status Network Token (SNT) is a utility token used within the Status.im platform, which is an open-source messaging and social media platform built on the Ethereum blockchain. SNT is designed to facilitate peer-to-peer communication and interactions within the decentralized Status network.",
            websiteUrl: "https://status.im/",
            marketDetails: {
                marketCap: ({amount: 289140007.5701632, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 0.04361387720794776, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 0.0405415571067135, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0.7372177058415699,
                changePctDay: 4.094492504074038,
                changePct24hour: 5.038796965532456,
                change24hour: 0.002038287801810013,
                currencyPrice: ({amount: 0.04258000295521924, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false,
        },
        {
            key: "DAI",
            name: "Dai Stablecoin",
            symbol: "DAI",
            sources: ";" + uniswap + ";" + status + ";",
            addressPerChain: [
                { chainId: 1, address: "0x6b175474e89094c44da98b954eedeac495271d0f"},
                { chainId: 10, address: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1"},
                { chainId: 42161, address: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1"},
                { chainId: 5, address: "0xf2edf1c091f683e3fb452497d9a98a49cba84666"},
                { chainId: 11155111, address: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1"},
            ],
            decimals: 18,
            type: 1,
            communityId: "",
            description: "Dai (DAI) is a decentralized, stablecoin cryptocurrency built on the Ethereum blockchain. It is designed to maintain a stable value relative to the US Dollar, and is backed by a reserve of collateral-backed tokens and other assets. Dai is an ERC-20 token, meaning it is fully compatible with other networks and wallets that support Ethereum-based tokens, making it an ideal medium of exchange and store of value.",
            websiteUrl: "https://makerdao.com/",
            marketDetails: {
                marketCap: ({amount: 3641953745.413845, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 1.000069852130498, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 0.9989457077643417, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0.003162399421324529,
                changePctDay: 0.0008257482387743841,
                changePct24hour: 0.04426443627508443,
                change24hour: 0.0004424433543155981,
                currencyPrice: ({amount: 0.9999000202515163, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false
        },
        {
            key: "0x6b175474e89094c44da98b954eedeac495271e0f",
            name: "0x",
            symbol: "ZRX",
            sources: ";" + custom + ";",
            addressPerChain: [
                { chainId: 420, address: "0x6b175474e89094c44da98b954eedeac495271e0f"}
            ],
            decimals: 0,
            type: 1,
            communityId: "ddls",
            description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout." ,
            websiteUrl: "",
            marketDetails: {
                marketCap: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0,
                changePctDay: 0,
                changePct24hour: 0,
                change24hour: 0,
                currencyPrice: ({amount: 0.07, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false
        },
        {
            key: "0x6b175474e89094c44da98b954eedeac495271p0f",
            name: "Omg",
            symbol: "OMG",
            sources: ";" + custom + ";",
            addressPerChain: [
                { chainId: 420, address: "0x6b175474e89094c44da98b954eedeac495271p0f"}
            ],
            decimals: 0,
            type: 1,
            communityId: "sox",
            description: "",
            websiteUrl: "",
            marketDetails: {
                marketCap: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0,
                changePctDay: 0,
                changePct24hour: 0,
                change24hour: 0,
                currencyPrice: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false
        },
        {
            key: "0x6b175474e89094c44da98b954eedeac495271d0f",
            name: "Meth",
            symbol: "MET",
            sources: ";" + custom + ";",
            addressPerChain: [
                { chainId: 420, address: "0x6b175474e89094c44da98b954eedeac495271d0f"}
            ],
            decimals: 0,
            type: 1,
            communityId: "ddls",
            description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. ",
            websiteUrl: "",
            marketDetails: {
                marketCap: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0,
                changePctDay: 0,
                changePct24hour: 0,
                change24hour: 0,
                currencyPrice: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false
        },
        {
            key: "0x6b175474e89094c44da98b954eedeac495271a0f",
            name: "Ast",
            symbol: "AST",
            sources: ";" + custom + ";",
            addressPerChain: [
                { chainId: 420, address: "0x6b175474e89094c44da98b954eedeac495271a0f"}
            ],
            decimals: 0,
            type: 1,
            communityId: "ast",
            description: "",
            websiteUrl: "",
            marketDetails: {
                marketCap: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                highDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                lowDay: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                changePctHour: 0,
                changePctDay: 0,
                changePct24hour: 0,
                change24hour: 0,
                currencyPrice: ({amount: 0, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
            },
            detailsLoading: false,
            marketDetailsLoading: false
        }
    ]

    Component.onCompleted: append(data)
}
