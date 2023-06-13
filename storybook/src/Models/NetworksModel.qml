pragma Singleton

import QtQuick 2.15

QtObject {

    readonly property int ethNet: 1
    readonly property int optimismNet: 2
    readonly property int arbitrumNet: 3
    readonly property int hermezNet: 4
    readonly property int testnetNet: 5
    readonly property int customNet: 6

    readonly property var layer1Networks: ListModel {
        function rowData(index, propName) {
            return get(index)[propName]
        }

        Component.onCompleted:
            append([
                       {
                           chainId: ethNet,
                           chainName: "Ethereum Mainnet",
                           iconUrl: ModelsData.networks.ethereum,
                           isActive: true,
                           isEnabled: true,
                           shortName: "ETH",
                           chainColor: "blue",
                           isTest: false
                       }
                   ])
    }

    readonly property var layer2Networks: ListModel {
        Component.onCompleted:
            append([
                       {
                           chainId: optimismNet,
                           chainName: "Optimism",
                           iconUrl: ModelsData.networks.optimism,
                           isActive: false,
                           isEnabled: true,
                           shortName: "OPT",
                           chainColor: "red",
                           isTest: false
                       },
                       {
                           chainId: arbitrumNet,
                           chainName: "Arbitrum",
                           iconUrl: ModelsData.networks.arbitrum,
                           isActive: false,
                           isEnabled: true,
                           shortName: "ARB",
                           chainColor: "purple",
                           isTest: false
                       }
                   ])
    }

    readonly property var testNetworks: ListModel {
        Component.onCompleted:
            append([
                       {
                           chainId: hermezNet,
                           chainName: "Hermez",
                           iconUrl: ModelsData.networks.hermez,
                           isActive: false,
                           isEnabled: true,
                           shortName: "HEZ",
                           chainColor: "orange",
                           isTest: true
                       },
                       {
                           chainId: testnetNet,
                           chainName: "Testnet",
                           iconUrl: ModelsData.networks.testnet,
                           isActive: false,
                           isEnabled: true,
                           shortName: "TNET",
                           chainColor: "lightblue",
                           isTest: true
                       },
                       {
                           chainId: customNet,
                           chainName: "Custom",
                           iconUrl: ModelsData.networks.custom,
                           isActive: false,
                           isEnabled: true,
                           shortName: "CUSTOM",
                           chainColor: "orange",
                           isTest: true
                       }
                   ])
    }

    readonly property var enabledNetworks: ListModel {
        // Simulate Nim's way of providing access to data
        function rowData(index, propName) {
            return get(index)[propName]
        }

        Component.onCompleted:
            append([
                       {
                            chainId: 1,
                            layer: 1,
                            chainName: "Ethereum Mainnet",
                            iconUrl: ModelsData.networks.ethereum,
                            isActive: true,
                            isEnabled: false,
                            shortName: "ETH",
                            chainColor: "blue",
                            isTest: false
                       },
                       {
                            chainId: 2,
                            layer: 2,
                            chainName: "Optimism",
                            iconUrl: ModelsData.networks.optimism,
                            isActive: false,
                            isEnabled: true,
                            shortName: "OPT",
                            chainColor: "red",
                            isTest: false
                       },
                       {
                            chainId: 3,
                            layer: 2,
                            chainName: "Arbitrum",
                            iconUrl: ModelsData.networks.arbitrum,
                            isActive: false,
                            isEnabled: true,
                            shortName: "ARB",
                            chainColor: "purple",
                            isTest: false
                       },
                       {
                            chainId: 4,
                            layer: 2,
                            chainName: "Hermez",
                            iconUrl: ModelsData.networks.hermez,
                            isActive: false,
                            isEnabled: true,
                            shortName: "HEZ",
                            chainColor: "orange",
                            isTest: false
                       },
                       {
                            chainId: 5,
                            layer: 1,
                            chainName: "Testnet",
                            iconUrl: ModelsData.networks.testnet,
                            isActive: false,
                            isEnabled: true,
                            shortName: "TNET",
                            chainColor: "lightblue",
                            isTest: true
                       },
                       {
                            chainId: 6,
                            layer: 1,
                            chainName: "Custom",
                            iconUrl: ModelsData.networks.custom,
                            isActive: false,
                            isEnabled: true,
                            shortName: "CUSTOM",
                            chainColor: "orange",
                            isTest: false
                       }
                   ])
    }

    readonly property var allNetworks: ListModel {
        // Simulate Nim's way of providing access to data
        function rowData(index, propName) {
            return get(index)[propName]
        }

        Component.onCompleted: append([
            {
                chainId: 1,
                chainName: "Ethereum Mainnet",
                blockExplorerUrl: "https://etherscan.io/",
                iconUrl: "network/Network=Ethereum",
                chainColor: "#627EEA",
                shortName: "eth",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest: false,
                layer: 1,
                isEnabled: true,
            },
            {
                chainId: 5,
                chainName: "Goerli",
                blockExplorerUrl: "https://goerli.etherscan.io/",
                iconUrl: "network/Network=Testnet",
                chainColor: "#939BA1",
                shortName: "goEth",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest: true,
                layer: 1,
                isEnabled: true,
            },
            {
                chainId: 10,
                chainName: "Optimism",
                blockExplorerUrl: "https://optimistic.etherscan.io",
                iconUrl: "network/Network=Optimism",
                chainColor: "#E90101",
                shortName: "opt",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  false,
                layer:   2,
                isEnabled: true,
            },
            {
                chainId: 420,
                chainName: "Optimism Goerli Testnet",
                blockExplorerUrl: "https://goerli-optimism.etherscan.io/",
                iconUrl: "network/Network=Testnet",
                chainColor: "#939BA1",
                shortName: "goOpt",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  true,
                layer:   2,
                isEnabled: true,
            },
            {
                chainId: 42161,
                chainName: "Arbitrum",
                blockExplorerUrl: "https://arbiscan.io/",
                iconUrl: "network/Network=Arbitrum",
                chainColor: "#51D0F0",
                shortName: "arb",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  false,
                layer:   2,
                isEnabled: true,
            },
            {
                chainId: 421613,
                chainName: "Arbitrum Goerli",
                blockExplorerUrl: "https://goerli.arbiscan.io/",
                iconUrl: "network/Network=Testnet",
                chainColor: "#939BA1",
                shortName: "goArb",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  true,
                layer:   2,
                isEnabled: false,
            }]
        )
    }
}
