import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0

import StatusQ.Core.Utils 0.1

import shared.stores 1.0
import utils 1.0

import "types"

QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property var walletStore
    required property DAppsStore store

    property alias requestsModel: requests

    function rejectSessionRequest(request, userRejected) {
        let error = userRejected ? false : true
        sdk.rejectSessionRequest(request.topic, request.id, error)
    }

    signal sessionRequest(SessionRequestResolved request)

    /// Supported methods
    property QtObject methods: QtObject {
        readonly property string personalSign: Constants.personal_sign
        readonly property string sendTransaction: "eth_sendTransaction"
    }

    function getSupportedMethods() {
        return [root.methods.personalSign, root.methods.sendTransaction]
    }

    Connections {
        target: sdk

        function onSessionRequestEvent(event) {
            let obj = d.resolveAsync(event)
            if (obj === null) {
                let error = true
                sdk.rejectSessionRequest(event.topic, event.id, error)
                return
            }
            requests.enqueue(obj)
        }
    }

    QObject {
        id: d

        function resolveAsync(event) {
            let method = event.params.request.method
            let account = lookupAccountFromEvent(event, method)
            let network = lookupNetworkFromEvent(event, method)
            let data = extractMethodData(event, method)
            let obj = sessionRequestComponent.createObject(null, {
                event,
                topic: event.topic,
                id: event.id,
                method,
                account,
                network,
                data
            })
            if (obj === null) {
                console.error("Error creating SessionRequestResolved for event")
                return null
            }

            // Check later to have a valid request object
            if (!getSupportedMethods().includes(method)
                // TODO  #14927: support method eth_sendTransaction
                || method == "eth_sendTransaction") {
                console.error("Unsupported method", method)
                return null
            }

            sdk.getActiveSessions((res) => {
                Object.keys(res).forEach((topic) => {
                    if (topic === obj.topic) {
                        let session = res[topic]
                        obj.resolveDappInfoFromSession(session)
                        root.sessionRequest(obj)
                    }
                })
            })

            return obj
        }

        /// Returns null if the account is not found
        function lookupAccountFromEvent(event, method) {
            if (method === root.methods.personalSign) {
                if (event.params.request.params.length < 2) {
                    return null
                }
                var address = event.params.request.params[1]
                for (let i = 0; i < walletStore.ownAccounts.count; i++) {
                    let acc = ModelUtils.get(walletStore.ownAccounts, i)
                    if (acc.address === address) {
                        return acc
                    }
                }
            }
            return null
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (method === root.methods.personalSign) {
                let chainId = Helpers.chainIdFromEip155(event.params.chainId)
                for (let i = 0; i < walletStore.flatNetworks.count; i++) {
                    let network = ModelUtils.get(walletStore.flatNetworks, i)
                    if (network.chainId === chainId) {
                        return network
                    }
                }
            }
            return null
        }

        function extractMethodData(event, method) {
            if (method === root.methods.personalSign) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                let hexMessage = event.params.request.params[0]
                return {
                    message: Helpers.hexToString(hexMessage)
                }
            }
        }
    }

    /// The queue is used to ensure that the events are processed in the order they are received but they could be
    /// processed handled randomly on user intervention through activity center
    SessionRequestsModel {
        id: requests
    }

    Component {
        id: sessionRequestComponent

        SessionRequestResolved {
        }
    }
}