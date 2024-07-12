import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1

import StatusQ 0.1
import SortFilterProxyModel 0.2
import AppLayouts.Wallet.controls 1.0
import shared.popups.walletconnect 1.0
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0

import shared.stores 1.0
import utils 1.0

import "types"

// Act as another layer of abstraction to the WalletConnectSDKBase
// Quick hack until the WalletConnectSDKBase could be refactored to a more generic DappProviderBase with API to match
// the UX requirements
WalletConnectSDKBase {
    id: root

    // Nim connector.controller instance
    property var controller
    property bool sdkReady: true
    property bool active: true
    required property WalletConnectService wcService
    property string requestID: ""

    projectId: ""

    implicitWidth: 1
    implicitHeight: 1

    Loader {
        id: connectDappLoader

        active: false

        property var dappChains: []
        property var sessionProposal: null
        property var availableNamespaces: null
        property var sessionTopic: null
        readonly property var proposalMedatada: !!sessionProposal
                                                ? sessionProposal.params.proposer.metadata
                                                : { name: "", url: "", icons: [] }

        sourceComponent: ConnectDAppModal {
            visible: true

            onClosed: connectDappLoader.active = false
            accounts: root.wcService.validAccounts
            property SortFilterProxyModel filteredFlatModel: SortFilterProxyModel {
                sourceModel: networksModule.flatNetworks
                filters: ValueFilter { roleName: "isTest"; value: networksModule.areTestNetworksEnabled }
            }
            flatNetworks: filteredFlatModel
            selectedAccountAddress: root.wcService.selectedAccountAddress

            dAppUrl: proposalMedatada.url
            dAppName: proposalMedatada.name
            dAppIconUrl: !!proposalMedatada.icons && proposalMedatada.icons.length > 0 ? proposalMedatada.icons[0] : ""
            multipleChainSelection: false

            onConnect: {
                connectDappLoader.active = false
                approveSession(root.requestID, selectedAccount.address, selectedChains)
            }

            onDecline: {
                connectDappLoader.active = false
                rejectSession(root.requestID)
            }
        }
    }

    Loader {
        id: sessionRequestLoader

        active: false

        onLoaded: item.open()

        property SessionRequestResolved request: null

        property var dappInfo: null

        sourceComponent: DAppRequestModal {
            account: request.account
            network: request.network

            dappName: request.dappName
            dappUrl: request.dappUrl
            dappIcon: request.dappIcon

            payloadData: request.data
            method: request.method
            maxFeesText: request.maxFeesText
            maxFeesEthText: request.maxFeesEthText
            enoughFunds: request.enoughFunds
            estimatedTimeText: request.estimatedTimeText

            visible: true

            onClosed: sessionRequestLoader.active = false

            onSign: {
                if (!request) {
                    console.error("Error signing: request is null")
                    return
                }
                root.wcService.requestHandler.authenticate(request)
            }

            onReject: {
                sessionRequestLoader.active = false
                controller.rejectTransactionSigning(root.requestID)
            }

            Connections {
                target: root.wcService.requestHandler

                function onMaxFeesUpdated(maxFees, maxFeesWei, haveEnoughFunds, symbol) {
                    maxFeesText = `${maxFees.toFixed(2)} ${symbol}`
                    var ethStr = "?"
                    try {
                        ethStr = globalUtils.wei2Eth(maxFeesWei, 9)
                    } catch (e) {
                        // ignore error in case of tests and storybook where we don't have access to globalUtils
                    }
                    maxFeesEthText = `${ethStr} ETH`
                    enoughFunds = haveEnoughFunds
                }
                function onEstimatedTimeUpdated(minMinutes, maxMinutes) {
                    estimatedTimeText = qsTr("%1-%2mins").arg(minMinutes).arg(maxMinutes)
                }
            }
        }
    }

    Connections {
        target: root.wcService ? root.wcService.requestHandler : null

        function onSessionRequestResult(payload, isSuccess) {
            console.log("----> onSessionRequestResult")

            if (isSuccess) {
                sessionRequestLoader.active = false
                controller.approveTransactionRequest(requestID, "0xcafeeabcbbcbcabcabfacafeeabcbbcbcabcabfacafeeabcbbcbcabcabfaaefe")
            } else {
                // TODO #14762 handle the error case
            }
        }
    }

    Component {
        id: sessionRequestComponent

        SessionRequestResolved {
        }
    }

    Connections {
        target: controller

        // TODO: Feed the request with the correct data
        onDappValidatesTransaction: function(requestID, dappInfoString) {
            var dappsInfo = JSON.parse(dappInfoString)

            let request = sessionRequestComponent.createObject(root, {
                event: null,
                topic: dappsInfo.url,
                id: "1",
                method: "hello",
                account: root.wcService.validAccounts,
                network: null,
                data: dappsInfo.txArgs,
                maxFeesText: "?",
                maxFeesEthText: "?",
                enoughFunds: false,
                estimatedTimeText: "?"
            })

            sessionRequestLoader.active = true
            sessionRequestLoader.request = request
            root.requestID = requestID
        }

        onDappRequestsToConnect: function(requestID, dappInfoString) {
            var dappInfo = JSON.parse(dappInfoString)

            let sessionProposal = {
                "params": {
                    "optionalNamespaces": {},
                    "proposer": {
                        "metadata": {
                            "description": "-",
                            "icons": [
                                dappInfo.icon
                            ],
                            "name": dappInfo.name,
                            "url": dappInfo.url
                        }
                    },
                    "requiredNamespaces": {
                        "eip155": {
                            "chains": [
                                `eip155:${dappInfo.chainId}`
                            ],
                            "events": [],
                            "methods": ["eth_sendTransaction"]
                        }
                    }
                }
            };

            connectDappLoader.sessionProposal = sessionProposal
            connectDappLoader.active = true
            root.requestID = requestID
        }
    }

    approveSession: function(requestID, account, selectedChains) {
        controller.approveDappConnectRequest(requestID, account, JSON.stringify(selectedChains))
    }

    rejectSession: function(requestID) {
        controller.rejectDappConnectRequest(requestID)
    }

    // We don't expect requests for these. They are here only to spot errors
    pair: function(pairLink) { console.error("ConnectorSDK.pair: not implemented") }
    getPairings: function(callback) { console.error("ConnectorSDK.getPairings: not implemented") }
    disconnectPairing: function(topic) { console.error("ConnectorSDK.disconnectPairing: not implemented") }
    buildApprovedNamespaces: function(params, supportedNamespaces) { console.error("ConnectorSDK.buildApprovedNamespaces: not implemented") }
}
