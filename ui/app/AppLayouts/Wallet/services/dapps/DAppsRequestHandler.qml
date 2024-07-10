import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0

import StatusQ.Core.Utils 0.1

import shared.stores 1.0
import utils 1.0

import "types"

QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var accountsModel
    required property var networksModel

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
    signal sessionRequestResult(/*model entry of SessionRequestResolved*/ var request, bool isSuccess)
    signal maxFeesUpdated(real maxFees, int maxFeesWei, bool haveEnoughFunds, string symbol)
    // Reports Constants.TransactionEstimatedTime values
    signal estimatedTimeUpdated(int estimatedTimeEnum)

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
            let methodStr = SessionRequest.methodToUserString(request.method)
            if (!methodStr) {
                console.error("Error finding user string for method", request.method)
                return
            }

            d.lookupSession(topic, function(session) {
                if (session === null)
                    return
                if (error) {
                    root.displayToastMessage(qsTr("Fail to %1 from %2").arg(methodStr).arg(session.peer.metadata.url), true)

                    root.sessionRequestResult(request, false /*isSuccessful*/)

                    console.error(`Error accepting session request for topic: ${topic}, id: ${id}, accept: ${accept}, error: ${error}`)
                    return
                }

                let actionStr = accept ? qsTr("accepted") : qsTr("rejected")
                root.displayToastMessage("%1 %2 %3".arg(session.peer.metadata.url).arg(methodStr).arg(actionStr), false)

                root.sessionRequestResult(request, true /*isSuccessful*/)
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
            let methodStr = SessionRequest.methodToUserString(request.method)
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
            if(!account) {
                console.error("Error finding account for event", JSON.stringify(event))
                return null
            }
            let network = lookupNetworkFromEvent(event, method)
            if(!network) {
                console.error("Error finding network for event", JSON.stringify(event))
                return null
            }
            let data = extractMethodData(event, method)
            if(!data) {
                console.error("Error in event data lookup", JSON.stringify(event))
                return null
            }
            let obj = sessionRequestComponent.createObject(null, {
                event,
                topic: event.topic,
                id: event.id,
                method,
                account,
                network,
                data,
                maxFeesText: "?",
                maxFeesEthText: "?",
                enoughFunds: false,
            })
            if (obj === null) {
                console.error("Error creating SessionRequestResolved for event")
                return null
            }

            // Check later to have a valid request object
            if (!SessionRequest.getSupportedMethods().includes(method)) {
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

                let estimatedTimeEnum = getEstimatedTimeInterval(data, method, obj.network.chainId)
                root.estimatedTimeUpdated(estimatedTimeEnum)

                // TODO #15192: update maxFees
                if (!event.params.request.params[0].gasLimit || !event.params.request.params[0].gasPrice) {
                    root.maxFeesUpdated(0, 0, true, "")
                    return
                }

                let gasLimit = parseFloat(parseInt(event.params.request.params[0].gasLimit, 16));
                let gasPrice = parseFloat(parseInt(event.params.request.params[0].gasPrice, 16));
                let maxFees = gasLimit * gasPrice
                root.maxFeesUpdated(maxFees/1000000000, maxFees, true, "Gwei")

            })

            return obj
        }

        /// Returns null if the account is not found
        function lookupAccountFromEvent(event, method) {
            var address = ""
            if (method === SessionRequest.methods.personalSign.name) {
                if (event.params.request.params.length < 2) {
                    return null
                }
                address = event.params.request.params[1]
            } else if (method === SessionRequest.methods.sign.name) {
                if (event.params.request.params.length === 1) {
                    return null
                }
                address = event.params.request.params[0]
            } else if(method === SessionRequest.methods.signTypedData_v4.name ||
                      method === SessionRequest.methods.signTypedData.name)
            {
                if (event.params.request.params.length < 2) {
                    return null
                }
                address = event.params.request.params[0]
            } else if (method === SessionRequest.methods.signTransaction.name
                    || method === SessionRequest.methods.sendTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                address = event.params.request.params[0].from
            }
            return ModelUtils.getFirstModelEntryIf(root.accountsModel, (account) => {
                return account.address.toLowerCase() === address.toLowerCase();
            })
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (SessionRequest.getSupportedMethods().includes(method) === false) {
                return null
            }
            let chainId = Helpers.chainIdFromEip155(event.params.chainId)
            return ModelUtils.getByKey(root.networksModel, "chainId", chainId)
        }

        function extractMethodData(event, method) {
            if (method === SessionRequest.methods.personalSign.name ||
                method === SessionRequest.methods.sign.name)
            {
                if (event.params.request.params.length < 1) {
                    return null
                }
                var message = ""
                let messageIndex = (method === SessionRequest.methods.personalSign.name ? 0 : 1)
                let messageParam = event.params.request.params[messageIndex]
                // There is no standard on how data is encoded. Therefore we support hex or utf8
                if (Helpers.isHex(messageParam)) {
                    message = Helpers.hexToString(messageParam)
                } else {
                    message = messageParam
                }
                return SessionRequest.methods.personalSign.buildDataObject(message)
            } else if (method === SessionRequest.methods.signTypedData_v4.name ||
                       method === SessionRequest.methods.signTypedData.name)
            {
                if (event.params.request.params.length < 2) {
                    return null
                }
                let jsonMessage = event.params.request.params[1]
                let methodObj = method === SessionRequest.methods.signTypedData_v4.name
                    ? SessionRequest.methods.signTypedData_v4
                    : SessionRequest.methods.signTypedData
                return methodObj.buildDataObject(jsonMessage)
            } else if (method === SessionRequest.methods.signTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                let tx = event.params.request.params[0]
                return SessionRequest.methods.signTransaction.buildDataObject(tx)
            } else if (method === SessionRequest.methods.sendTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                let tx = event.params.request.params[0]
                return SessionRequest.methods.sendTransaction.buildDataObject(tx)
            } else {
                return null
            }
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
            if (!SessionRequest.getSupportedMethods().includes(request.method)) {
                console.error("Unsupported method to execute: ", request.method)
                return
            }

            if (password !== "") {
                var actionResult = ""
                if (request.method === SessionRequest.methods.sign.name) {
                    actionResult = store.signMessageUnsafe(request.topic, request.id,
                                        request.account.address, password,
                                        SessionRequest.methods.personalSign.getMessageFromData(request.data))
                } else if (request.method === SessionRequest.methods.personalSign.name) {
                    actionResult = store.signMessage(request.topic, request.id,
                                        request.account.address, password,
                                        SessionRequest.methods.personalSign.getMessageFromData(request.data))
                } else if (request.method === SessionRequest.methods.signTypedData_v4.name ||
                           request.method === SessionRequest.methods.signTypedData.name)
                {
                    let legacy = request.method === SessionRequest.methods.signTypedData.name
                    actionResult = store.safeSignTypedData(request.topic, request.id,
                                        request.account.address, password,
                                        SessionRequest.methods.signTypedData.getMessageFromData(request.data),
                                        request.network.chainId, legacy)
                } else if (request.method === SessionRequest.methods.signTransaction.name) {
                    let txObj = SessionRequest.methods.signTransaction.getTxObjFromData(request.data)
                    actionResult = store.signTransaction(request.topic, request.id,
                                        request.account.address, request.network.chainId, password, txObj)
                } else if (request.method === SessionRequest.methods.sendTransaction.name) {
                    let txObj = SessionRequest.methods.sendTransaction.getTxObjFromData(request.data)
                    actionResult = store.sendTransaction(request.topic, request.id,
                                        request.account.address, request.network.chainId, password, txObj)
                }
                let isSuccessful = (actionResult != "")
                if (isSuccessful) {
                    // acceptSessionRequest will trigger an sdk.sessionRequestUserAnswerResult signal
                    sdk.acceptSessionRequest(request.topic, request.id, actionResult)
                } else {
                    root.sessionRequestResult(request, isSuccessful)
                }
            } else if (pin !== "") {
                console.debug("TODO #15097 sign message using keycard: ", request.data)
            } else {
                console.error("No password or pin provided to sign message")
            }
        }

        // Returns Constants.TransactionEstimatedTime
        function getEstimatedTimeInterval(data, method, chainId) {
            if (method != SessionRequest.methods.signTransaction.name
                && method != SessionRequest.methods.sendTransaction.name)
            {
                return ""
            }

            var tx = {}
            if (method === SessionRequest.methods.signTransaction.name) {
                tx = SessionRequest.methods.signTransaction.getTxObjFromData(data)
            } else if (method === SessionRequest.methods.sendTransaction.name) {
                tx = SessionRequest.methods.sendTransaction.getTxObjFromData(data)
            }

            // Empty string instructs getEstimatedTime to fetch the blockchain value
            var maxFeePerGas = ""
            if (!!tx.maxFeePerGas) {
                maxFeePerGas = tx.maxFeePerGas
            } else if (!!tx.gasPrice) {
                maxFeePerGas = tx.gasPrice
            }

            return root.store.getEstimatedTime(chainId, maxFeePerGas)
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