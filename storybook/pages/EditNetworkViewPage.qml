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

        property var network: [{
                prod: {
                    chainId: 1,
                    nativeCurrencyDecimals: 18,
                    layer: 1,
                    chainName: "Mainnet",
                    rpcURL: "https://eth-archival.gateway.pokt.network/v1/lb/7178a5d77466455882b2fb60",
                    fallbackURL: "https://eth-archival.gateway.pokt.network/v1/lb/7178a5d77466455882b2fb60",
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
                    chainName: "Mainnet",
                    rpcURL: "https://goerli-archival.gateway.pokt.network/v1/lb/7178a5d77466455882b2fb60",
                    fallbackURL: "https://eth-archival.gateway.pokt.network/v1/lb/7178a5d77466455882b2fb60",
                    blockExplorerURL: "https://goerli.etherscan.io/",
                    iconURL: "network/Network=Ethereum",
                    nativeCurrencyName: "Ether",
                    nativeCurrencySymbol: "ETH",
                    isTest: true,
                    enabled: true,
                    chainColor: "#939BA1",
                    shortName: "eth",
                    relatedChainId: 1
                }
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

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            EditNetworkView {
                width: 560
                combinedNetwork: d.network[0]
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
