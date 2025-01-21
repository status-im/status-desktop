import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views.wallet 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }


    QtObject {
        id: d

        readonly property var mainnetProviders: ListModel {
            Component.onCompleted: append([
                    {
                        name: "Embedded Mainnet #1",
                        url: "https://mainnet.infura.io/v3/",
                        isEnabled: true,
                        providerType: "embedded-proxy",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    },
                    {
                        name: "Embedded Mainnet #2",
                        url: "https://mainnet.alchemy.io/v3/",
                        isEnabled: true,
                        providerType: "embedded-direct",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    },
                    {
                        name: "User Mainnet #1",
                        url: "https://mainnet.mynode.io/1/",
                        isEnabled: true,
                        providerType: "user",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    },
                    {
                        name: "User Mainnet #2",
                        url: "https://mainnet.mynode.io/2/",
                        isEnabled: false,
                        providerType: "user",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    }
                ]
            )
        }

        readonly property var testnetProviders: ListModel {
            Component.onCompleted: append([
                    {
                        name: "Embedded Sepolia #1",
                        url: "https://sepolia.infura.io/v3/",
                        isEnabled: true,
                        providerType: "embedded-proxy",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    },
                    {
                        name: "Embedded Sepolia #2",
                        url: "https://sepolia.alchemy.io/v3/",
                        isEnabled: true,
                        providerType: "embedded-direct",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    },
                    {
                        name: "User Sepolia #1",
                        url: "https://sepolia.mynode.io/1/",
                        isEnabled: false,
                        providerType: "user",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    },
                    {
                        name: "User Sepolia #2",
                        url: "https://sepolia.mynode.io/2/",
                        isEnabled: true,
                        providerType: "user",
                        authType: "none",
                        authLogin: "",
                        authPassword: "",
                        authToken: ""
                    }
                ]
            )
        }

        property var network: [{
                prod: {
                    chainId: 1,
                    nativeCurrencyDecimals: 18,
                    layer: 1,
                    chainName: "Mainnet",
                    rpcProviders: d.mainnetProviders,
                    blockExplorerURL: "https://etherscan.io/",
                    iconURL: "network/Network=Ethereum",
                    nativeCurrencyName: "Ether",
                    nativeCurrencySymbol: "ETH",
                    isTest: false,
                    enabled: true,
                    chainColor: "#627EEA",
                    shortName: "eth",
                    relatedChainId: 5,
                },
                test: {
                    chainId: 5,
                    nativeCurrencyDecimals: 18,
                    layer: 1,
                    chainName: "Testnet",
                    rpcProviders: d.testnetProviders,
                    blockExplorerURL: "https://sepolia.etherscan.io/",
                    iconURL: "network/Network=Ethereum",
                    nativeCurrencyName: "Ether",
                    nativeCurrencySymbol: "ETH",
                    isTest: true,
                    enabled: true,
                    chainColor: "#939BA1",
                    shortName: "eth",
                    relatedChainId: 1
                },
                layer: 1
            }]


        property var timer: Timer {
            interval: 1000
            onTriggered: {
                let state  = checkbox.checked ? EditNetworkForm.Verified: EditNetworkForm.InvalidURL
                networkModule.urlVerified(networkModule.url, state)
            }
        }
    }

    property var networkModule: QtObject {
        id: networkModule
        signal urlVerified(string url, int status)
        property string url

        function evaluateRpcEndPoint(url, isMainUrl) {
            networkModule.url = url
            d.timer.restart()
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ScrollView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            EditNetworkView {
                width: 560
                prodNetwork: d.network[0].prod
                testNetwork: d.network[0].test
                onEvaluateRpcEndPoint: networkModule.evaluateRpcEndPoint(url)
                networksModule: networkModule
                onUpdateNetworkValues: console.error(String("Updated network with chainId %1 with new main rpc url = %2 and faalback rpc =%3").arg(chainId).arg(newMainRpcInput).arg(newFailoverRpcUrl))
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: childrenRect.height

            logsView.logText: logs.logText

            CheckBox {
                id: checkbox
                text: "valid url"
                checked: true
            }
        }
    }
}

// category: Views
