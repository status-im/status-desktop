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

    function getShortChainName(chainId) {
        if(chainId === root.ethNet)
            return "eth"

        if(chainId === root.optimismNet)
            return "oeth"

        if(chainId === root.arbitrumNet)
            return "arb1"

        if(chainId === root.hermezNet)
            return "her"

        if(chainId === root.testnetNet)
            return "goe"

        if(chainId === root.customNet)
            return "cus"
    }

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

    readonly property var flatNetworks: ListModel {
        Component.onCompleted: append([
            {
                chainId: 1,
                chainName: "Mainnet",
                blockExplorerUrl: "https://etherscan.io/",
                iconUrl: "network/Network=Ethereum",
                chainColor: "#627EEA",
                shortName: "eth",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest: false,
                layer: 1,
                isRouteEnabled: true,
            },
            {
                chainId: 11155111,
                chainName: "Sepolia Mainnet",
                blockExplorerUrl: "https://sepolia.etherscan.io/",
                iconUrl: "network/Network=Ethereum",
                chainColor: "#627EEA",
                shortName: "eth",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest: true,
                layer: 1,
                isRouteEnabled: true,
            },
            {
                chainId: 10,
                chainName: "Optimism",
                blockExplorerUrl: "https://optimistic.etherscan.io",
                iconUrl: "network/Network=Optimism",
                chainColor: "#E90101",
                shortName: "oeth",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  false,
                layer:   2,
                isRouteEnabled: true,
            },
            {
                chainId: 420,
                chainName: "Optimism Goerli Testnet",
                blockExplorerUrl: "https://goerli-optimism.etherscan.io/",
                iconUrl: "network/Network=Optimism",
                chainColor: "#939BA1",
                shortName: "goOpt",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  true,
                layer:   2,
                isRouteEnabled: true,
            },
            {
                chainId: 42161,
                chainName: "Arbitrum",
                blockExplorerUrl: "https://arbiscan.io/",
                iconUrl: "network/Network=Arbitrum",
                chainColor: "#51D0F0",
                shortName: "arb1",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  false,
                layer:   2,
                isRouteEnabled: true,
            },
            {
                chainId: 421613,
                chainName: "Arbitrum Goerli",
                blockExplorerUrl: "https://goerli.arbiscan.io/",
                iconUrl: "network/Network=Arbitrum",
                chainColor: "#939BA1",
                shortName: "goArb",
                nativeCurrencyName: "Ether",
                nativeCurrencySymbol: "ETH",
                nativeCurrencyDecimals: 18,
                isTest:  true,
                layer:   2,
                isRouteEnabled: true,
            }]
        )
    }

    readonly property var sendFromNetworks: ListModel {
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
                       isRouteEnabled: true,
                       isRoutePreferred: true,
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
                        isRouteEnabled: true,
                        isRoutePreferred: true,
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
                        shortName: "ARB",
                        chainColor: "purple",
                        layer: 2,
                        nativeCurrencyDecimals: 18,
                        nativeCurrencyName: "Ether",
                        nativeCurrencySymbol: "ETH",
                        isRouteEnabled: true,
                        isRoutePreferred: true,
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

    readonly property var sendToNetworks: ListModel {
        function updateRoutePreferredChains(chainIds) {
            for( let i=0; i<count; i++) {
                get(i).isRoutePreferred = false
                get(i).isRouteEnabled = false
                if(chainIds.length === 0) {
                    if(get(i).layer() === 1) {
                        get(i).isRoutePreferred = true
                        get(i).isRouteEnabled = true
                    }
                }
                else {
                    for (let k =0;k<chainIds.split(":").length;k++) {
                        if(get(i).chainId.toString() === chainIds[k].toString()) {
                            get(i).isRoutePreferred = true
                            get(i).isRouteEnabled = true
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
                       isRouteEnabled: true,
                       isRoutePreferred: true,
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
                        isRouteEnabled: true,
                        isRoutePreferred: true,
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
                        isRouteEnabled: true,
                        isRoutePreferred: true,
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
