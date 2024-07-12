import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1

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

    projectId: ""

    implicitWidth: 1
    implicitHeight: 1

    Connections {
        target: controller
        onDappRequestsToConnect: function(dappInfo) {
            root.sessionProposal(JSON.parse(`{
                "id": ${dappInfo.id},
                "params": {
                    "id": ${dappInfo.id},
                    "optionalNamespaces": {},
                    "proposer": {
                        "metadata": {
                            "description": "-",
                            "icons": [
                                "${dappInfo.icon}"
                            ],
                            "name": "${dappInfo.name}",
                            "url": "${dappInfo.url}"
                        }
                    },
                    "requiredNamespaces": {
                        "eip155": {
                            "chains": [
                                "eip155:${dappInfo.chainId}"
                            ],
                            "events": [],
                            "methods": ["eth_sendTransaction"]
                        }
                    }
                }
            }`));
        }
    }

    getActiveSessions: function(callback) {
        let sessionTemplate = (dappUrl, dappName, dappIcon) => {
            return JSON.parse(`{
                        "peer": {
                            "metadata": {
                                "description": "-",
                                "icons": [
                                    "${dappIcon}"
                                ],
                                "name": "${dappName}",
                                "url": "${dappUrl}"
                            }
                        },
                        "topic": "dappUrl"
                    }`)
        }
        let dapps = JSON.parse(controller.getDappsJson())
        var sessions = []
        for (let i = 0; i < dapps.length; i++) {
            let dapp = dapps[i]
            let session = sessionTemplate(dapp.url, dapp.name, dapp.icon)
            sessions.push(session)
        }
        callback(sessions.push(session))
    }

    disconnectSession: function(topic) {
        controller.disconnectDapp(topic)
    }

    approveSession: function(sessionProposal, supportedNamespaces) {
        // TODO extract the account from the sessionProposal
        controller.approveDappConnectRequest()
    }

    rejectSession: function(id) {
        // TODO: ensure id is propagated
        controller.rejectDappConnectRequest(id)
    }

    acceptSessionRequest: function(topic, id, signature) {
        // TODO propagate to controller
    }

    rejectSessionRequest: function(topic, id, error) {
        // TODO propagate to controller
    }

    // We don't expect requests for these. They are here only to spot errors
    pair: function(pairLink) { console.error("ConnectorSDK.pair: not implemented") }
    getPairings: function(callback) { console.error("ConnectorSDK.getPairings: not implemented") }
    disconnectPairing: function(topic) { console.error("ConnectorSDK.disconnectPairing: not implemented") }
    buildApprovedNamespaces: function(params, supportedNamespaces) { console.error("ConnectorSDK.buildApprovedNamespaces: not implemented") }
}
