pragma Singleton

import QtQuick 2.15

QtObject {

    readonly property var layer1Networks: ListModel {
        Component.onCompleted:
            append([
                       {
                           chainId: 1,
                           chainName: "Ethereum Mainnet",
                           iconUrl: ModelsData.networks.ethereum,
                           isActive: true,
                           isEnabled: true,
                           shortName: "ETH",
                           chainColor: "blue"
                       }
                   ])
    }

    readonly property var layer2Networks: ListModel {
        Component.onCompleted:
            append([
                       {
                           chainId: 2,
                           chainName: "Optimism",
                           iconUrl: ModelsData.networks.optimism,
                           isActive: false,
                           isEnabled: true,
                           shortName: "OPT",
                           chainColor: "red"
                       },
                       {
                           chainId: 3,
                           chainName: "Arbitrum",
                           iconUrl: ModelsData.networks.arbitrum,
                           isActive: false,
                           isEnabled: true,
                           shortName: "ARB",
                           chainColor: "purple"
                       }
                   ])
    }

    readonly property var testNetworks: ListModel {
        Component.onCompleted:
            append([
                       {
                           chainId: 4,
                           chainName: "Hermez",
                           iconUrl: ModelsData.networks.hermez,
                           isActive: false,
                           isEnabled: true,
                           shortName: "HEZ",
                           chainColor: "orange"
                       },
                       {
                           chainId: 5,
                           chainName: "Testnet",
                           iconUrl: ModelsData.networks.testnet,
                           isActive: false,
                           isEnabled: true,
                           shortName: "TNET",
                           chainColor: "lightblue"
                       },
                       {
                           chainId: 6,
                           chainName: "Custom",
                           iconUrl: ModelsData.networks.custom,
                           isActive: false,
                           isEnabled: true,
                           shortName: "CUSTOM",
                           chainColor: "orange"
                       }
                   ])
    }

    readonly property var enabledNetworks: ListModel {
        Component.onCompleted:
            append([
                       {
                           chainId: 1,
                           chainName: "Ethereum Mainnet",
                           iconUrl: ModelsData.networks.ethereum,
                           isActive: true,
                           isEnabled: true,
                           shortName: "ETH",
                           chainColor: "blue"
                       },
                       {
                           chainId: 2,
                           chainName: "Optimism",
                           iconUrl: ModelsData.networks.optimism,
                           isActive: false,
                           isEnabled: true,
                           shortName: "OPT",
                           chainColor: "red"
                       },
                       {
                           chainId: 3,
                           chainName: "Arbitrum",
                           iconUrl: ModelsData.networks.arbitrum,
                           isActive: false,
                           isEnabled: true,
                           shortName: "ARB",
                           chainColor: "purple"
                       },
                       {
                           chainId: 4,
                           chainName: "Hermez",
                           iconUrl: ModelsData.networks.hermez,
                           isActive: false,
                           isEnabled: true,
                           shortName: "HEZ",
                           chainColor: "orange"
                       },
                       {
                           chainId: 5,
                           chainName: "Testnet",
                           iconUrl: ModelsData.networks.testnet,
                           isActive: false,
                           isEnabled: true,
                           shortName: "TNET",
                           chainColor: "lightblue"
                       },
                       {
                           chainId: 6,
                           chainName: "Custom",
                           iconUrl: ModelsData.networks.custom,
                           isActive: false,
                           isEnabled: true,
                           shortName: "CUSTOM",
                           chainColor: "orange"
                       }
                   ])
    }
}
