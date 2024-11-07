import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ.Core.Theme 0.1
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

/// Act as another layer of abstraction to the WalletConnectSDKBase
/// Converts the store requests into WalletConnect standard requests
WalletConnectSDKBase {
    id: root
    
    required property BrowserConnectStore store
    /// Required roles: chainId
    required property var networksModel
    /// Required roles: address
    required property var accountsModel

    projectId: ""

    Connections {
        target: root.store
        enabled: root.enabled

        function onSignRequested(requestId, dappInfoString) {
            try {
                var dappInfo = JSON.parse(dappInfoString)
                var txArgsParams = JSON.parse(dappInfo.txArgs)
                let event = d.buildSessionRequest(requestId, dappInfo.url, dappInfo.chainId, SessionRequest.methods.sendTransaction.name, txArgsParams)

                root.sessionRequestEvent(event)
            } catch (e) {
                console.error("Failed to parse dappInfo for session request", e)
            }
        }

        function onConnectRequested(requestId, dappInfoString) {
            try {
                var dappInfo = JSON.parse(dappInfoString)
                dappInfo.proposal = d.buildSessionProposal(requestId, dappInfo.url, dappInfo.name, dappInfo.icon, SessionRequest.getSupportedMethods())
                d.sessionRequests.set(requestId, dappInfo)
                root.sessionProposal(dappInfo.proposal)
            } catch (e) {
                console.error("Failed to parse dappInfo for connection request", e)
            }
        }

        function onDisconnected(dappInfoString) {
            try {
                let dappItem = JSON.parse(dappInfoString)
                root.sessionDelete(dappItem.url, false)
            } catch (e) {
                console.error("Failed to parse dappInfo for disconnection", e)
            }
        }

        function onApproveTransactionResponse(topic, requestId, error) {
            try {
                const errorStr = error ? "Faled to approve trasnsaction" : ""
                root.sessionRequestUserAnswerResult(topic, requestId, true, errorStr)
            } catch (e) {
                console.error("Failed to approve transaction response", e)
            }
        }

        function onRejectTransactionResponse(topic, requestId, error) {
            try {
                const errorStr = error ? "Faled to reject trasnsaction" : ""
                root.sessionRequestUserAnswerResult(topic, requestId, false, errorStr)
            } catch (e) {
                console.error("Failed to reject transaction response", e)
            }
        }
    }

    approveSession: function(requestId, account, selectedChains) {
        try {
            if (!d.sessionRequests.has(requestId)) {
                console.error("Session request not found")
                return
            }
            const dappInfo = d.sessionRequests.get(requestId)
            root.store.approveConnection(requestId, account, JSON.stringify(selectedChains))
            const newSession = d.buildSession(dappInfo.url, dappInfo.name, dappInfo.icon, requestId, account, selectedChains)
            root.approveSessionResult(requestId, newSession, "")
            d.sessionRequests.delete(requestId)
        } catch (e) {
            console.error("Failed to approve session", e)
        }
    }

    rejectSession: function(requestId) {
        try {
            root.store.rejectConnection(requestId)
            root.rejectSessionResult(requestId, "")
            d.sessionRequests.delete(requestId)
        } catch (e) {
            console.error("Failed to reject session", e)
        }
    }

    acceptSessionRequest: function(topic, requestId, signature) {
        root.store.approveTransaction(topic, requestId, signature)
    }

    rejectSessionRequest: function(topic, requestId, error) {
        root.store.rejectTransaction(topic, requestId, error)
    }

    disconnectSession: function(topic) {
        root.store.disconnect(topic)
    }

    getActiveSessions: function(callback) {
        try {
            const dappsStr = root.store.getDApps()
            const dapps = JSON.parse(dappsStr)
            let activeSessions = {}
            for (let i = 0; i < dapps.length; i++) {
                const dapp = dapps[i]
                activeSessions[dapp.url] = d.buildSession(dapp.url, dapp.name, dapp.iconUrl, "", dapp.sharedAccount, [dapp.chainId])
            }
            callback(activeSessions)
        } catch (e) {
            console.error("Failed to get active sessions", e)
            callback([])
        }
    }

    // We don't expect requests for these. They are here only to spot errors
    pair: function(pairLink) { console.error("ConnectorSDK.pair: not implemented") }
    getPairings: function(callback) { console.error("ConnectorSDK.getPairings: not implemented") }
    disconnectPairing: function(topic) { console.error("ConnectorSDK.disconnectPairing: not implemented") }
    buildApprovedNamespaces: function(params, supportedNamespaces) { console.error("ConnectorSDK.buildApprovedNamespaces: not implemented") }

    QtObject {
        id: d
        readonly property var sessionRequests: new Map()
        function buildSession(dappUrl, dappName, dappIcon, proposalId, account, chains) {
            let sessionTemplate = (dappUrl, dappName, dappIcon, proposalId, eipAccount, eipChains) => {
                return {
                    peer: {
                        metadata: {
                            description: "-",
                            icons: [
                                dappIcon
                            ],
                            name: dappName,
                            url: dappUrl
                        }
                    },
                    namespaces: {
                        eip155: {
                            accounts: [eipAccount],
                            chains: eipChains
                        }
                    },
                    pairingTopic: proposalId,
                    topic: dappUrl
                };
            }

            const eipAccount = account ? `eip155:${account}` : ""
            const eipChains = chains ? chains.map((chain) => `eip155:${chain}`) : []

            return sessionTemplate(dappUrl, dappName, dappIcon, proposalId, eipAccount, eipChains)
        }

        function buildSessionRequest(requestId, topic, chainId, method, txArgs) {
            return {
                id: requestId,
                topic,
                params: {
                    chainId: `eip155:${chainId}`,
                    request: {
                        method: SessionRequest.methods.sendTransaction.name,
                        params: [
                            {
                                from: txArgs.from,
                                to: txArgs.to,
                                value: txArgs.value,
                                gasLimit: txArgs.gas,
                                gasPrice: txArgs.gasPrice,
                                maxFeePerGas: txArgs.maxFeePerGas,
                                maxPriorityFeePerGas: txArgs.maxPriorityFeePerGas,
                                nonce: txArgs.nonce,
                                data: txArgs.data
                            }
                        ]
                    }
                }
            }
        }

        function buildSessionProposal(id, url, name, icon, methods) {
            const supportedNamespaces = DAppsHelpers.buildSupportedNamespacesFromModels(root.networksModel, root.accountsModel, methods)
            const proposal =  {
                id,
                params: {
                    optionalNamespaces: {},
                    proposer: {
                        metadata: {
                            description: "-",
                            icons: [
                                icon
                            ],
                            name,
                            url
                        }
                    },
                    requiredNamespaces: supportedNamespaces
                }
            }
            return proposal
        }
    }
}
