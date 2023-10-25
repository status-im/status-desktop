pragma Singleton

import QtQuick 2.15

QtObject {
    id: root

    readonly property int ethNet: 1
    readonly property int optimismNet: 10
    readonly property int arbitrumNet: 42161
    readonly property int hermezNet: 4
    readonly property int testnetNet: 5
    readonly property int customNet: 6

    function getChainName(chainId) {
        if(chainId === root.ethNet)
            return "Mainnet"

        if(chainId === root.optimismNet)
            return "Optimism"

        if(chainId === root.arbitrumNet)
            return "Arbitrum"

        if(chainId === root.hermezNet)
            return "Hermez"

        if(chainId === root.testnetNet)
            return "Goerli"

        if(chainId === root.customNet)
            return "Custom"
    }

    component CustomNetworkModel: ListModel {
        // Simulate Nim's way of providing access to data
        function rowData(index, propName) {
            return get(index)[propName]
        }
    }

    readonly property var layer1Networks: CustomNetworkModel {
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

    readonly property var layer2Networks: CustomNetworkModel {
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

    readonly property var testNetworks: CustomNetworkModel {
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

    readonly property var enabledNetworks: CustomNetworkModel {
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

    readonly property var allNetworks: CustomNetworkModel {
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

    readonly property var mainNetworks: CustomNetworkModel {
        Component.onCompleted: append([
                   {
                       chainId: 1,
                       chainName: "Ethereum Mainnet",
                       iconUrl: ModelsData.networks.ethereum,
                       isActive: true,
                       isEnabled: true,
                       shortName: "ETH",
                       chainColor: "blue",
                       layer: 1,
                       isTest: false
                   },
                   {
                       chainId: 10,
                       chainName: "Optimism",
                       iconUrl: ModelsData.networks.optimism,
                       isActive: false,
                       isEnabled: true,
                       shortName: "OPT",
                       chainColor: "red",
                       layer: 2,
                       isTest: false
                   },
                   {
                       chainId: 42161,
                       chainName: "Arbitrum",
                       iconUrl: ModelsData.networks.arbitrum,
                       isActive: false,
                       isEnabled: true,
                       shortName: "ARB",
                       chainColor: "purple",
                       layer: 2,
                       isTest: false
                   }
               ])
    }

    readonly property var sendFromNetworks: CustomNetworkModel {
        function updateFromNetworks(paths){
            reset()
            for(let i=0; i<paths.length; i++) {
                for(let k=0; k<count; k++) {
                    if(paths[i].fromNetwork.toString() === get(k).chainId.toString()) {
                        get(k).amountIn = paths[i].amountIn
                        get(k).toNetworks = get(k).toNetworks + ":" + paths[i].toNetwork
                        get(k).hasGas = true
                        get(k).locked = paths[i].amountInLocked
                    }
                }
            }
        }
        function reset() {
            for( let j=0; j<count; j++) {
                get(j).amountIn = ""
                get(j).toNetworks = ""
                get(j).hasGas = true
                get(j).locked = false
            }
        }
        Component.onCompleted: append([
                   {
                       chainId: 1,
                       chainName: "Ethereum Mainnet",
                       iconUrl: ModelsData.networks.ethereum,
                       chainColor: "blue",
                       shortName: "ETH",
                       layer: 1,
                       nativeCurrencyDecimals: 18,
                       nativeCurrencyName: "Ether",
                       nativeCurrencySymbol: "ETH",
                       isEnabled: true,
                       isPreferred: true,
                       hasGas: true,
                       tokenBalance: ({
                            displayDecimals: true,
                            stripTrailingZeroes: true,
                            amount: 23333213.234
                       }),
                       locked: false,
                       lockedAmount: "",
                       amountIn: "",
                       amountOut: "",
                       toNetworks: ""
                    },
                   {
                        chainId: 10,
                        chainName: "Optimism",
                        iconUrl: ModelsData.networks.optimism,
                        chainColor: "red",
                        shortName: "OPT",
                        layer: 2,
                        nativeCurrencyDecimals: 18,
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        isEnabled: true,
                        isPreferred: true,
                        hasGas: true,
                        tokenBalance: ({
                            displayDecimals: true,
                            stripTrailingZeroes: true,
                            amount: 23333213.234
                        }),
                        locked: false,
                        lockedAmount: "",
                        amountIn: "",
                        amountOut: "",
                        toNetworks: ""
                   },
                   {
                        chainId: 42161,
                        chainName: "Arbitrum",
                        iconUrl: ModelsData.networks.arbitrum,
                        isActive: false,
                        isEnabled: true,
                        shortName: "ARB",
                        chainColor: "purple",
                        layer: 2,
                        nativeCurrencyDecimals: 18,
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        isEnabled: true,
                        isPreferred: true,
                        hasGas: true,
                        tokenBalance: ({
                            displayDecimals: true,
                            stripTrailingZeroes: true,
                            amount: 23333213.234
                        }),
                        locked: false,
                        lockedAmount: "",
                        amountIn: "",
                        amountOut: "",
                        toNetworks: ""
                    }
               ])
    }

    readonly property var sendToNetworks: CustomNetworkModel {
        function updateRoutePreferredChains(chainIds) {
            for( let i=0; i<count; i++) {
                get(i).isPreferred = false
                get(i).isEnabled = false
                if(chainIds.length === 0) {
                    if(get(i).layer() === 1) {
                        get(i).isPreferred = true
                        get(i).isEnabled = true
                    }
                }
                else {
                    for (let k =0;k<chainIds.split(":").length;k++) {
                        if(get(i).chainId.toString() === chainIds[k].toString()) {
                            get(i).isPreferred = true
                            get(i).isEnabled = true
                        }
                    }
                }
            }
        }
        function updateToNetworks(paths){
            reset()
            for(let i=0;i<paths.length;i++) {
                for( let k=0; k<count; k++) {
                    if(paths[i].toNetwork.toString() === get(k).chainId.toString()) {
                        if(!!get(k).amountOut) {
                            let res = parseInt(get(k).amountOut) + parseInt(paths[i].amountOut)
                            get(k).amountOut = res.toString()
                        }
                        else {
                            get(k).amountOut = paths[i].amountOut
                        }
                    }
                }
            }
        }
        function reset() {
            for( let j=0; j<count; j++) {
                get(j).amountOut = ""
            }
        }
        Component.onCompleted: append([
                   {
                       chainId: 1,
                       chainName: "Ethereum Mainnet",
                       iconUrl: ModelsData.networks.ethereum,
                       chainColor: "blue",
                       shortName: "ETH",
                       layer: 1,
                       nativeCurrencyDecimals: 18,
                       nativeCurrencyName: "Ether",
                       nativeCurrencySymbol: "ETH",
                       isEnabled: true,
                       isPreferred: true,
                       hasGas: true,
                       tokenBalance: ({
                            displayDecimals: true,
                            stripTrailingZeroes: true,
                            amount: 23333213.234
                       }),
                       locked: false,
                       lockedAmount: "",
                       amountIn: "",
                       amountOut: "",
                       toNetworks: ""
                    },
                   {
                        chainId: 10,
                        chainName: "Optimism",
                        iconUrl: ModelsData.networks.optimism,
                        chainColor: "red",
                        shortName: "OPT",
                        layer: 2,
                        nativeCurrencyDecimals: 18,
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        isEnabled: true,
                        isPreferred: true,
                        hasGas: true,
                        tokenBalance: ({
                            displayDecimals: true,
                            stripTrailingZeroes: true,
                            amount: 23333213.234
                        }),
                        locked: false,
                        lockedAmount: "",
                        amountIn: "",
                        amountOut: "",
                        toNetworks: ""
                   },
                   {
                        chainId: 42161,
                        chainName: "Arbitrum",
                        iconUrl: ModelsData.networks.arbitrum,
                        isActive: false,
                        isEnabled: true,
                        shortName: "ARB",
                        chainColor: "purple",
                        layer: 2,
                        nativeCurrencyDecimals: 18,
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        isEnabled: true,
                        isPreferred: true,
                        hasGas: true,
                        tokenBalance: ({
                            displayDecimals: true,
                            stripTrailingZeroes: true,
                            amount: 23333213.234
                        }),
                        locked: false,
                        lockedAmount: "",
                        amountIn: "",
                        amountOut: "",
                        toNetworks: ""
                    }
               ])
    }
}
