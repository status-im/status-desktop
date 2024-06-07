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
    signal sessionRequestResult(/*model entry of SessionRequestResolved*/ var request, var payload, bool isSuccess)

    /// Supported methods
    property QtObject methods: QtObject {
        readonly property QtObject personalSign: QtObject {
            readonly property string name: Constants.personal_sign
            readonly property string userString: qsTr("sign")
        }
        readonly property QtObject signTypedData_v4: QtObject {
            readonly property string name: "eth_signTypedData_v4"
            readonly property string userString: qsTr("sign typed data")
        }

        readonly property QtObject sendTransaction: QtObject {
            readonly property string name: "eth_sendTransaction"
            readonly property string userString: qsTr("send transaction")
        }
        readonly property var all: [personalSign, signTypedData_v4, sendTransaction]
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

                    root.sessionRequestResult(request, "", false /*isSuccessful*/)

                    console.error(`Error accepting session request for topic: ${topic}, id: ${id}, accept: ${accept}, error: ${error}`)
                    return
                }

                let actionStr = accept ? qsTr("accepted") : qsTr("rejected")
                root.displayToastMessage("%1 %2 %3".arg(session.peer.metadata.url).arg(methodStr).arg(actionStr), false)

                root.sessionRequestResult(request, "", true /*isSuccessful*/)
            })
        }
    }

    Connections {
        target: root.store

        function onUserAuthenticated(topic, id, password, pin) {
            var request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for topic", topic, "id", id)
                return
            }
            d.executeSessionRequest(request, password, pin)
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
            var address = ""
            if (method === root.methods.personalSign.name) {
                if (event.params.request.params.length < 2) {
                    return null
                }
                address = event.params.request.params[1]
            } else if(method === root.methods.signTypedData_v4.name) {
                if (event.params.request.params.length < 2) {
                    return null
                }
                address = event.params.request.params[0]
            }
            return ModelUtils.getByKey(walletStore.ownAccounts, "address", address)
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (method === root.methods.personalSign.name || method === root.methods.signTypedData_v4.name) {
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
                var message = ""
                let messageParam = event.params.request.params[0]
                // There is no standard on how data is encoded. Therefore we support hex or utf8
                if (Helpers.isHex(messageParam)) {
                    message = Helpers.hexToString(messageParam)
                } else {
                    message = messageParam
                }
                return {message}
            } else if (method === root.methods.signTypedData_v4.name) {
                if (event.params.request.params.length < 2) {
                    return null
                }
                let jsonMessage = event.params.request.params[1]
                return {
                    message: jsonMessage
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

        function executeSessionRequest(request, password, pin) {
            if (request.method === root.methods.personalSign.name || request.method === root.methods.signTypedData_v4.name) {
                if (password !== "") {
                    //let originalMessage = request.data.message
                    // TODO #14756: clarify why prefixing the message fails the test app https://react-app.walletconnect.com/
                    //let finalMessage = "\x19Ethereum Signed Message:\n" + originalMessage.length + originalMessage
                    let finalMessage = request.data.message
                    var signedMessage = ""
                    if (request.method === root.methods.personalSign.name) {
                        signedMessage = store.signMessage(request.topic, request.id,
                                                              request.account.address, password, finalMessage)
                    } else if (request.method === root.methods.signTypedData_v4.name) {
                        signedMessage = store.signTypedDataV4(request.topic, request.id,
                                                              request.account.address, password, finalMessage)
                    }
                    let isSuccessful = signedMessage != ""
                    if (isSuccessful) {
                        // acceptSessionRequest will trigger an sdk.sessionRequestUserAnswerResult signal
                        sdk.acceptSessionRequest(request.topic, request.id, signedMessage)
                    } else {
                        root.sessionRequestResult(request, request.data.message, isSuccessful)
                    }
                } else if (pin !== "") {
                    console.debug("TODO #14927 sign message using keycard: ", request.data.message)
                } else {
                    console.error("No password or pin provided to sign message")
                }
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