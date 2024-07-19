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
    required property var walletStore
    property string requestId: ""

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

            onClosed: {
                rejectSession(root.requestId)
                connectDappLoader.active = false
            }
            accounts: root.wcService.validAccounts
            flatNetworks: root.walletStore.filteredFlatModel
            selectedAccountAddress: root.wcService.selectedAccountAddress

            dAppUrl: proposalMedatada.url
            dAppName: proposalMedatada.name
            dAppIconUrl: !!proposalMedatada.icons && proposalMedatada.icons.length > 0 ? proposalMedatada.icons[0] : ""
            multipleChainSelection: false

            onConnect: {
                connectDappLoader.active = false
                approveSession(root.requestId, selectedAccount.address, selectedChains)
            }

            onDecline: {
                connectDappLoader.active = false
                rejectSession(root.requestId)
            }
        }
    }

    Connections {
        target: controller

        onDappRequestsToConnect: function(requestId, dappInfoString) {
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
            root.requestId = requestId
        }
    }

    approveSession: function(requestId, account, selectedChains) {
        controller.approveDappConnectRequest(requestId, account, JSON.stringify(selectedChains))
    }

    rejectSession: function(requestId) {
        controller.rejectDappConnectRequest(requestId)
    }

    // We don't expect requests for these. They are here only to spot errors
    pair: function(pairLink) { console.error("ConnectorSDK.pair: not implemented") }
    getPairings: function(callback) { console.error("ConnectorSDK.getPairings: not implemented") }
    disconnectPairing: function(topic) { console.error("ConnectorSDK.disconnectPairing: not implemented") }
    buildApprovedNamespaces: function(params, supportedNamespaces) { console.error("ConnectorSDK.buildApprovedNamespaces: not implemented") }
}
