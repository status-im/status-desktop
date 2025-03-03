import QtQuick 2.15
import QtTest 1.15
import QtQml 2.15

import AppLayouts.Wallet.adaptors 1.0

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

Item {
    id: root

    Component {
        id: testComponent

        PaymentRequestAdaptor {
            selectedNetworkChainId: 1
            flatNetworksModel: ListModel {
                Component.onCompleted: append([
                    {
                        chainId: 1,
                        chainName: "Mainnet",
                        blockExplorerURL: "https://etherscan.io/",
                        iconUrl: "network/Network=Ethereum",
                        chainColor: "#627EEA",
                        shortName: "eth",
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        nativeCurrencyDecimals: 18,
                        isTest: false,
                        layer: 1,
                        isRouteEnabled: true,
                        isEnabled: true,
                        isActive: true,
                        isDeactivatable: false,
                    },
                    {
                        chainId: 10,
                        chainName: "Optimism",
                        blockExplorerURL: "https://optimistic.etherscan.io",
                        iconUrl: "network/Network=Optimism",
                        chainColor: "#E90101",
                        shortName: "oeth",
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        nativeCurrencyDecimals: 18,
                        isTest:  false,
                        layer:   2,
                        isRouteEnabled: true,
                        isEnabled: true,
                        isActive: false,
                        isDeactivatable: true,
                    },
                    {
                        chainId: 11155420,
                        chainName: "Optimism Sepolia",
                        blockExplorerURL: "https://sepolia-optimism.etherscan.io/",
                        iconUrl: "network/Network=Optimism-test",
                        chainColor: "#939BA1",
                        shortName: "oeth",
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        nativeCurrencyDecimals: 18,
                        isTest:  true,
                        layer:   2,
                        isRouteEnabled: true,
                        isEnabled: true,
                        isActive: true,
                        isDeactivatable: true,
                    },
                    {
                        chainId: 42161,
                        chainName: "Arbitrum",
                        blockExplorerURL: "https://arbiscan.io/",
                        iconUrl: "network/Network=Arbitrum",
                        chainColor: "#51D0F0",
                        shortName: "arb1",
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        nativeCurrencyDecimals: 18,
                        isTest:  false,
                        layer:   2,
                        isRouteEnabled: true,
                        isEnabled: false,
                        isActive: true,
                        isDeactivatable: true,
                    },
                    {
                        chainId: 421614,
                        chainName: "Arbitrum Sepolia",
                        blockExplorerURL: "https://sepolia-explorer.arbitrum.io/",
                        iconUrl: "network/Network=Arbitrum-test",
                        chainColor: "#939BA1",
                        shortName: "arb1",
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        nativeCurrencyDecimals: 18,
                        isTest:  true,
                        layer:   2,
                        isRouteEnabled: true,
                        isEnabled: false,
                        isActive: true,
                        isDeactivatable: true,
                    },
                ])
            }
            plainTokensBySymbolModel: ListModel {
                Component.onCompleted: append([{
                    key: "ETH",
                    name: "Ether",
                    symbol: "ETH",
                    addressPerChain: [
                        { chainId: 1, address: "0x0000000000000000000000000000000000000000"},
                        { chainId: 5, address: "0x0000000000000000000000000000000000000000"},
                    ],
                    decimals: 18,
                    type: 1,
                    communityId: "",
                    description: "Ethereum is a decentralized, open-source blockchain platform that enables developers to build and deploy smart contracts and decentralized applications (dApps). It runs on a global network of nodes, making it highly secure and resistant to censorship. Ethereum introduced the concept of programmable money, allowing users to interact with the blockchain through self-executing contracts, also known as smart contracts. Ethereum's native currency, Ether (ETH), powers these contracts and facilitates transactions on the network.",
                    websiteUrl: "https://www.ethereum.org/",
                    marketDetails: {},
                    detailsLoading: false,
                    marketDetailsLoading: false,
                },
                {
                    key: "STT",
                    name: "Status Test Token",
                    symbol: "STT",
                    addressPerChain: [
                        {chainId: 5, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"},
                    ],
                    decimals: 18,
                    type: 1,
                    communityId: "",
                    description: "Status Network Token (SNT) is a utility token used within the Status.im platform, which is an open-source messaging and social media platform built on the Ethereum blockchain. SNT is designed to facilitate peer-to-peer communication and interactions within the decentralized Status network.",
                    websiteUrl: "https://status.im/",
                    marketDetails: {},
                    detailsLoading: false,
                    marketDetailsLoading: false,
                },
                {
                    key: "DAI",
                    name: "Dai Stablecoin",
                    symbol: "DAI",
                    addressPerChain: [
                        { chainId: 1, address: "0x6b175474e89094c44da98b954eedeac495271d0f"},
                        { chainId: 5, address: "0xf2edf1c091f683e3fb452497d9a98a49cba84666"},
                    ],
                    decimals: 18,
                    type: 1,
                    communityId: "",
                    description: "Dai (DAI) is a decentralized, stablecoin cryptocurrency built on the Ethereum blockchain. It is designed to maintain a stable value relative to the US Dollar, and is backed by a reserve of collateral-backed tokens and other assets. Dai is an ERC-20 token, meaning it is fully compatible with other networks and wallets that support Ethereum-based tokens, making it an ideal medium of exchange and store of value.",
                    websiteUrl: "https://makerdao.com/",
                    marketDetails: {},
                    detailsLoading: false,
                    marketDetailsLoading: false
                },
                {
                    key: "0x6b175474e89094c44da98b954eedeac495271d0f",
                    name: "Meth",
                    symbol: "MET",
                    addressPerChain: [
                       { chainId: 1, address: "0x6b175474e89094c44da98b954eedeac495271d0f"},
                       { chainId: 5, address: "0x6b175474e89094c44da98b954eedeac495271d0f"}
                    ],
                    decimals: 0,
                    type: 1,
                    communityId: "ddls",
                    description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. ",
                    websiteUrl: "",
                    marketDetails: {},
                    detailsLoading: false,
                    marketDetailsLoading: false
                },
                ])
            }
        }
    }

    TestCase {
        name: "PaymentRequestAdaptor"

        function test_model_contents() {
            const adaptor = createTemporaryObject(testComponent, root)
            verify(adaptor)

            // Community and not selected network are filtered out
            compare(adaptor.outputModel.ModelCount.count, 2)
            compare(adaptor.outputModel.get(0).tokensKey, "DAI")
            compare(adaptor.outputModel.get(1).tokensKey, "ETH")

            adaptor.selectedNetworkChainId = 999
            compare(adaptor.outputModel.ModelCount.count, 0)

            adaptor.selectedNetworkChainId = 5
            compare(adaptor.outputModel.ModelCount.count, 3)
            compare(adaptor.outputModel.get(0).tokensKey, "DAI")
            compare(adaptor.outputModel.get(1).tokensKey, "ETH")
            compare(adaptor.outputModel.get(2).tokensKey, "STT")
        }
    }
}
