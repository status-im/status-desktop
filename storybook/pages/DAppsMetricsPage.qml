import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Components 0.1

import Models 1.0
import Storybook 1.0

import utils 1.0

import shared.stores 1.0
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.controls 1.0

Item {
    id: root

    property string mixpanelToken: ""

    component MethodsPicker: StatusListPicker {
        id: methodsPicker
        multiSelection: true
        inputList: ListModel {
            ListElement {
                key: 0
                name: "personal_sign"
                shortName: "personal_sign"
                category: ""
                selected: true
            }
            ListElement {
                key: 1
                name: "eth_signTypedData"
                shortName: "eth_signTypedData"
                category: ""
                selected: false
            }
            ListElement {
                key: 2
                name: "eth_sign"
                shortName: "eth_sign"
                category: ""
                selected: false
            }
            ListElement {
                key: 3
                name: "eth_sendTransaction"
                shortName: "eth_sendTransaction"
                category: ""
                selected: false
            }
        }

        function getSelection() {
            var selection = []
            for (var i = 0; i < inputList.count; i++) {
                if (inputList.get(i).selected) {
                    selection.push(inputList.get(i).name)
                }
            }
            return selection
        }
    }

    DAppsMetrics {
        id: metrics

        metricsStore: MetricsStore {
            id: metricsStore
            function addCentralizedMetricIfEnabled(eventName, eventValue = null) {
                if (root.mixpanelToken !== "") {
                    var http = new XMLHttpRequest()
                    var url = "https://api.mixpanel.com/track";
                    eventValue.token = root.mixpanelToken
                    const strEvent = JSON.stringify(eventValue)
                    var event = `[{"properties":${strEvent},"event":"${eventName}"}]`
                    http.open("POST", url, true);

                    // Send the proper header information along with the request
                    http.setRequestHeader("Content-type", "application/json");
                    http.setRequestHeader("accept", "text/plain");

                    http.onreadystatechange = function() { // Call a function when the state changes.
                                if (http.readyState == 4) {
                                    if (http.status == 200) {
                                        console.log("ok")
                                    } else {
                                        console.log("error: " + http.status)
                                    }
                                }
                            }
                    logs.logEvent("Sending Mixpanel event", ["eventName", "eventValue"], arguments)
                    http.send(event);
                    return
                }
                logs.logEvent("Mixpanel simulated event", ["eventName", "eventValue"], arguments)
            }
        }
    }

    Logs { id: logs }

    ColumnLayout {
        anchors.fill: parent
        ColumnLayout {
            z: 10
            spacing: 10

            Pane {
                Layout.fillWidth: true
                background: Rectangle {
                    border.width: 2
                    border.color: "black"
                }
                ColumnLayout {
                    Label {
                        text: "Warning! Configuring the mixpanel token will send the events to Mixpanel"
                        font.bold: true
                    }
                    RowLayout {
                        Label {
                            text: "Mixpanel Config"
                        }
                        TextField {
                            id: mixpanelToken
                            placeholderText: "Mixpanel Token"
                        }
                        Button {
                            text: "Set Mixpanel Token"
                            onClicked: root.mixpanelToken = mixpanelToken.text
                        }
                        Button {
                            text: "Remove Mixpanel Token"
                            onClicked: root.mixpanelToken = ""
                        }
                    }
                }
            }

            Pane {
                Layout.fillWidth: true
                background: Rectangle {
                    border.width: 2
                    border.color: "black"
                }
                ColumnLayout {
                    Label {
                        text: "DApps Health Events"
                    }

                    RowLayout {
                        spacing: 10

                        Button {
                            id: logHealthEvent
                            text: "Log Health Event"
                            onClicked: metrics.logHealthEvent(healthState.currentIndex, error.text)
                        }

                        ComboBox {
                            id: healthState
                            model: ["WC Available", "WC Unavailable", "Chains Down", "Network Down", "Pair Error", "Connect Error", "Sign Error", "undefined"]
                        }

                        TextField {
                            id: error
                            placeholderText: "Error"
                        }
                    }
                }
            }

            Pane {
                Layout.fillWidth: true
                background: Rectangle {
                    border.width: 2
                    border.color: "black"
                }
                ColumnLayout {
                    Label {
                        text: "DApps Navigation Events"
                    }

                    RowLayout {
                        spacing: 10

                        Button {
                            id: logNavigation
                            text: "Log Navigation Event"
                            onClicked: metrics.logNavigationEvent(navigationAction.currentIndex, connector.currentIndex)
                        }

                        ComboBox {
                            id: navigationAction
                            Layout.fillWidth: true
                            model: ["DApp List Opened", "DApp Connect Initiated", "DApp Disconnect Initiated", "DApp Pair Initiated", "undefined"]
                        }

                        ComboBox {
                            id: connector
                            currentIndex: 1
                            model: ["undefined", "WalletConnect", "BrowserConnect"]
                        }
                    }
                }
            }

            Pane {
                id: connectionProposal
                z: 10
                Layout.fillWidth: true
                background: Rectangle {
                    border.width: 2
                    border.color: "black"
                }
                ColumnLayout {
                    Label {
                        text: "Connection Proposal"
                    }

                    RowLayout {
                        spacing: 10
                        z: 10

                        TextField {
                            id: dappProposal
                            text: "https://dapp.com"
                        }

                        ComboBox {
                            id: proposalConnector
                            currentIndex: 1
                            model: ["undefined", "WalletConnect", "BrowserConnect"]
                        }
                        NetworkFilter {
                            id: networkFilter
                            flatNetworks: NetworksModel.flatNetworks
                        }
                        MethodsPicker {
                            id: methodsPicker
                        }
                    }

                    RowLayout {
                        spacing: 10
                        Button {
                            id: logConnectionProposal
                            text: "Log Connection Proposal"
                            onClicked: metrics.logConnectionProposal(networkFilter.selection.map(String), methodsPicker.getSelection(), dappProposal.text, proposalConnector.currentIndex)
                        }
                        Button {
                            text: "Log SIWE Connection rejected"
                            onClicked: metrics.logSiweConnectionProposal(networkFilter.selection.map(String), dappProposal.text, proposalConnector.currentIndex)
                        }
                        Button {
                            text: "Log Connection accepted"
                            onClicked: metrics.logConnectionProposalAccepted(dappProposal.text, networkFilter.selection.map(String), proposalConnector.currentIndex)
                        }

                        Button {
                            text: "Log Connection rejected"
                            onClicked: metrics.logConnectionProposalRejected(dappProposal.text, proposalConnector.currentIndex)
                        }

                        Button {
                            text: "Log dapp connected"
                            onClicked: metrics.logDAppConnected(dappProposal.text, proposalConnector.currentIndex)
                        }

                        Button {
                            text: "Log dapp disconnected"
                            onClicked: metrics.logDAppDisconnected(dappProposal.text, proposalConnector.currentIndex)
                        }
                    }
                }
            }

            Pane {
                Layout.fillWidth: true
                background: Rectangle {
                    border.width: 2
                    border.color: "black"
                }

                ColumnLayout {
                    Label {
                        text: "DApps Sign Events"
                    }

                    RowLayout {
                        spacing: 10

                        TextField {
                            id: dappSign
                            text: "https://dapp.com"
                        }

                        ComboBox {
                            id: connectorSign
                            currentIndex: 1
                            model: ["undefined", "WalletConnect", "BrowserConnect"]
                        }
                        NetworkFilter {
                            id: networkFilterSign
                            flatNetworks: NetworksModel.flatNetworks
                            multiSelection: false
                        }
                        MethodsPicker {
                            id: methodsPickerSign
                            multiSelection: false
                        }
                    }

                    RowLayout {
                        spacing: 10
                        Button {
                            id: logSignEvent
                            text: "Log Sign Event"
                            onClicked: metrics.logSignRequestReceived(connectorSign.currentIndex, methodsPickerSign.getSelection()[0], networkFilterSign.singleSelectionItemData.chainId, dappSign.text)
                        }

                        Button {
                            text: "Log Sign Request Accepted"
                            onClicked: metrics.logSignRequestAccepted(connectorSign.currentIndex, methodsPickerSign.getSelection()[0], networkFilterSign.singleSelectionItemData.chainId, dappSign.text)
                        }

                        Button {
                            text: "Log Sign Request Rejected"
                            onClicked: metrics.logSignRequestRejected(connectorSign.currentIndex, methodsPickerSign.getSelection()[0], networkFilterSign.singleSelectionItemData.chainId, dappSign.text)
                        }
                    }
                }
            }
        }
        
        Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            background: Rectangle {
                border.width: 2
                border.color: "black"
            }
            LogsView {
                id: logsAndControlsPanel
                anchors.fill: parent
                logText: logs.logText
            }
        }
    }
}

// category: Wallet
