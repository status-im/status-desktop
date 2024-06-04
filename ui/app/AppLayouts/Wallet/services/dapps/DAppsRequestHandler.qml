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

    /// Beware, it will fail if called multiple times before getting an answer
    function authenticate(request) {
        return store.authenticateUser(request.topic, request.id, request.account.address)
    }

    signal sessionRequest(SessionRequestResolved request)
    signal displayToastMessage(string message, bool error)
    signal sessionRequestResult(var payload, bool isSuccess)

    /// Supported methods
    property QtObject methods: QtObject {
        readonly property QtObject personalSign: QtObject {
            readonly property string name: Constants.personal_sign
            readonly property string userString: qsTr("sign")
        }
        readonly property QtObject sendTransaction: QtObject {
            readonly property string name: "eth_sendTransaction"
            readonly property string userString: qsTr("send transaction")
        }
        readonly property var all: [personalSign, sendTransaction]
    }

    function getSupportedMethods() {
        return methods.all.map(function(method) {
            return method.name
        })
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

        function onSessionRequestUserAnswerResult(topic, id, accept, error) {
            var request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for topic", topic, "id", id)
                return
            }
            let methodStr = d.methodToUserString(request.method)
            if (!methodStr) {
                console.error("Error finding user string for method", request.method)
                return
            }

            d.lookupSession(topic, function(session) {
                if (session === null)
                    return
                if (error) {
                    root.displayToastMessage(qsTr("Fail to %1 from %2").arg(methodStr).arg(session.peer.metadata.url), true)
                    // TODO #14757 handle SDK error on user accept/reject
                    console.error(`Error accepting session request for topic: ${topic}, id: ${id}, accept: ${accept}, error: ${error}`)
                    return
                }

                let actionStr = accept ? qsTr("accepted") : qsTr("rejected")
                root.displayToastMessage("%1 %2 %3".arg(session.peer.metadata.url).arg(methodStr).arg(actionStr), false)
                root.sessionRequestApprovalResult()
            })
        }
    }

    Connections {
        target: root.store

        function onUserAuthenticated(topic, id) {
            var request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for topic", topic, "id", id)
                return
            }
            d.executeSessionRequest(request)
        }

        function onUserAuthenticationFailed(topic, id) {
            var request = requests.findRequest(topic, id)
            let methodStr = d.methodToUserString(request.method)
            if (request === null || !methodStr) {
                return
            }
            d.lookupSession(topic, function(session) {
                if (session === null)
                    return
                root.displayToastMessage(qsTr("Failed to authenticate %1 from %2").arg(methodStr).arg(session.peer.metadata.url), true)
            })
        }

        function onSessionRequestExecuted(payload, isSuccess) {
            // TODO #14927 handle this properly
            root.sessionRequestResult(payload, isSuccess)
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
                || method == root.methods.sendTransaction.name) {
                console.error("Unsupported method", method)
                return null
            }

            d.lookupSession(obj.topic, function(session) {
                if (session === null) {
                    console.error("DAppsRequestHandler.lookupSession: error finding session for topic", obj.topic)
                    return
                }
                obj.resolveDappInfoFromSession(session)
                root.sessionRequest(obj)
            })

            return obj
        }

        /// Returns null if the account is not found
        function lookupAccountFromEvent(event, method) {
            if (method === root.methods.personalSign.name) {
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
            if (method === root.methods.personalSign.name) {
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
            if (method === root.methods.personalSign.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                let hexMessage = event.params.request.params[0]
                return {
                    message: Helpers.hexToString(hexMessage)
                }
            }
        }

        function methodToUserString(method) {
            for (let i = 0; i < methods.all.length; i++) {
                if (methods.all[i].name === method) {
                    return methods.all[i].userString
                }
            }
            return ""
        }

        function lookupSession(topicToLookup, callback) {
            sdk.getActiveSessions((res) => {
                Object.keys(res).forEach((topic) => {
                    if (topic === topicToLookup) {
                        let session = res[topic]
                        callback(session)
                    }
                })
            })
        }

        function executeSessionRequest(request) {
            if (request.method === root.methods.personalSign.name) {
                store.signMessage(request.data.message)
                console.debug("TODO #14927 sign message: ", request.data.message)
            } else {
                console.error("Unsupported method to execute: ", request.method)
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