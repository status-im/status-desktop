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

    required property WalletConnectService wcService
    required property var walletStore
    required property DAppsStore store
    required property int loginType

    property var controller
    property var dappInfo: null
    property var txArgs: null
    property bool sdkReady: true
    property bool active: true
    property string requestId: ""
    property alias requestsModel: requests

    projectId: ""

    implicitWidth: 1
    implicitHeight: 1

    // TODO Refactor this code to avoid code duplication from Wallet Connect DAppsRequestHandler
    // https://github.com/status-im/status-desktop/issues/15711
    QtObject {
        id: d

        function sessionRequestEvent(event) {
            let obj = d.resolveAsync(event)
            if (obj === null) {
                let error = true
                controller.rejectTransactionSigning(root.requestId)
                return
            }
            sessionRequestLoader.request = obj
            requests.enqueue(obj)
        }

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
            let enoughFunds = !isTransactionMethod(method)
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
                enoughFunds: enoughFunds,
                estimatedTimeText: "?"
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

            let session = getActiveSessions(root.dappInfo)

            if (session === null) {
                console.error("DAppsRequestHandler.lookupSession: error finding session for topic", obj.topic)
                return
            }
            obj.resolveDappInfoFromSession(session)

            return obj
        }

        function isTransactionMethod(method) {
            return method === SessionRequest.methods.signTransaction.name
                || method === SessionRequest.methods.sendTransaction.name
        }

        /// Returns null if the account is not found
        function lookupAccountFromEvent(event, method) {
            var address = ""
            if (method === SessionRequest.methods.personalSign.name) {
                if (event.params.request.params.length < 2) {
                    return null
                }
                address = event.params.request.params[0]
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
                address = event.params.request.params[0]
            }
            return SQUtils.ModelUtils.getFirstModelEntryIf(root.wcService.validAccounts, (account) => {
                return account.address.toLowerCase() === address.toLowerCase();
            })
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (SessionRequest.getSupportedMethods().includes(method) === false) {
                return null
            }
            let chainId = Helpers.chainIdFromEip155(event.params.chainId)
            return SQUtils.ModelUtils.getByKey(networksModule.flatNetworks, "chainId", chainId)
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
                let messageParam = event.params.request.tx.data

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
                    acceptSessionRequest(request.topic, request.method, request.id, actionResult)
                } else {
                    root.sessionRequestResult(request, isSuccessful)
                }
            } else if (pin !== "") {
                console.debug("TODO #15097 sign message using keycard: ", request.data)
            } else {
                console.error("No password or pin provided to sign message")
            }
        }

        function acceptSessionRequest(topic, method, id, signature) {
            console.debug(`WC DappsConnectorSDK.acceptSessionRequest; topic: "${topic}", id: ${root.requestId}, signature: "${signature}"`)

            sessionRequestLoader.active = false
            controller.approveTransactionRequest(requestId, signature)

            root.wcService.displayToastMessage(qsTr("Successfully signed transaction from %1").arg(root.dappInfo.url), false)
        }

        function getActiveSessions(dappInfos) {
            let sessionTemplate = (dappUrl, dappName, dappIcon) => {
                return {
                    "peer": {
                        "metadata": {
                            "description": "-",
                            "icons": [
                                dappIcon
                            ],
                            "name": dappName,
                            "url": dappUrl
                        }
                    },
                    "topic": dappUrl
                };
            }

            return sessionTemplate(dappInfos.url, dappInfos.name, dappInfos.icon)
        }

        function authenticate(request) {
            return store.authenticateUser(request.topic, request.id, request.account.address)
        }
    }

    Connections {
        target: root.store

        function onUserAuthenticated(topic, id, password, pin) {
            var request = requests.findRequest(topic, id)
            if (request === null) {
                console.error(">Error finding event for topic", topic, "id", id)
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
                root.displayToastMessage(qsTr("Failed to authenticate %1").arg(session.peer.metadata.url), true)
            })
        }
    }

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
            flatNetworks: root.walletStore.filteredFlatModel
            accounts: root.wcService.validAccounts

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

    Loader {
        id: sessionRequestLoader

        active: false

        onLoaded: item.open()

        property SessionRequestResolved request: null

        property var dappInfo: null

        sourceComponent: DAppSignRequestModal {
            id: dappRequestModal
            objectName: "connectorDappsRequestModal"
            loginType: request.account.migragedToKeycard ? Constants.LoginType.Keycard : root.loginType
            visible: true

            dappName: request.dappName
            dappUrl: request.dappUrl
            dappIcon: request.dappIcon

            accountColor: request.account.color
            accountName: request.account.name
            accountAddress: request.account.address
            accountEmoji: request.account.emoji

            networkName: request.network.chainName
            networkIconPath: Style.svg(request.network.iconUrl)

            currentCurrency: ""
            fiatFees: request.maxFeesText
            cryptoFees: request.maxFeesEthText
            estimatedTime: ""
            feesLoading: !request.maxFeesText || !request.maxFeesEthText
            hasFees: signingTransaction
            enoughFundsForTransaction: request.enoughFunds
            enoughFundsForFees: request.enoughFunds

            signingTransaction: request.method === SessionRequest.methods.signTransaction.name || request.method === SessionRequest.methods.sendTransaction.name

            requestPayload: {
                switch(request.method) {
                    case SessionRequest.methods.personalSign.name:
                        return SessionRequest.methods.personalSign.getMessageFromData(request.data)
                    case SessionRequest.methods.sign.name: {
                        return SessionRequest.methods.sign.getMessageFromData(request.data)
                    }
                    case SessionRequest.methods.signTypedData_v4.name: {
                        const stringPayload = SessionRequest.methods.signTypedData_v4.getMessageFromData(request.data)
                        return JSON.stringify(JSON.parse(stringPayload), null, 2)
                    }
                    case SessionRequest.methods.signTypedData.name: {
                        const stringPayload = SessionRequest.methods.signTypedData.getMessageFromData(root.payloadData)
                        return JSON.stringify(JSON.parse(stringPayload), null, 2)
                    }
                    case SessionRequest.methods.signTransaction.name: {
                        const jsonPayload = SessionRequest.methods.signTransaction.getTxObjFromData(request.data)
                        return JSON.stringify(jsonPayload, null, 2)
                    }
                    case SessionRequest.methods.sendTransaction.name: {
                        const jsonPayload = SessionRequest.methods.sendTransaction.getTxObjFromData(request.data)
                        return JSON.stringify(jsonPayload, null, 2)
                    }
                }
            }

            onClosed: {
                Qt.callLater( () => {
                    sessionRequestLoader.active = false
                })
            }

            onAccepted: {
                if (!request) {
                    console.error("Error signing: request is null")
                    return
                }

                d.authenticate(request)
            }

            onRejected: {
                sessionRequestLoader.active = false
                controller.rejectTransactionSigning(root.requestId)
                root.wcService.displayToastMessage(qsTr("Failed to sign transaction from %1").arg(request.dappUrl), true)
            }
        }
    }

    Component {
        id: sessionRequestComponent

        SessionRequestResolved {
        }
    }

    SessionRequestsModel {
        id: requests
    }

    Connections {
        target: controller

        onDappValidatesTransaction: function(requestId, dappInfoString) {
            var dappInfo = JSON.parse(dappInfoString)
            root.dappInfo = dappInfo
            var txArgsParams = JSON.parse(dappInfo.txArgs)
            root.txArgs = txArgsParams
            let event = {
                "id": root.requestId,
                "topic": dappInfo.url,
                "params": {
                    "chainId": `eip155:${dappInfo.chainId}`,
                    "request": {
                        "method": SessionRequest.methods.personalSign.name,
                        "tx": {
                            "data": txArgsParams.data,
                        },
                        "params": [
                            txArgsParams.from,
                            txArgsParams.to,
                        ],
                    }
                }
            }

            d.sessionRequestEvent(event)

            sessionRequestLoader.active = true
            root.requestId = requestId
        }

        onDappRequestsToConnect: function(requestId, dappInfoString) {
            var dappInfo = JSON.parse(dappInfoString)
            root.dappInfo = dappInfo
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
                            "methods": [SessionRequest.methods.personalSign.name]
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
        root.wcService.displayToastMessage(qsTr("Successfully authenticated %1").arg(root.dappInfo.url), false)
    }

    rejectSession: function(requestId) {
        controller.rejectDappConnectRequest(requestId)
        root.wcService.displayToastMessage(qsTr("Failed to authenticate %1").arg(root.dappInfo.url), true)
    }

    // We don't expect requests for these. They are here only to spot errors
    pair: function(pairLink) { console.error("ConnectorSDK.pair: not implemented") }
    getPairings: function(callback) { console.error("ConnectorSDK.getPairings: not implemented") }
    disconnectPairing: function(topic) { console.error("ConnectorSDK.disconnectPairing: not implemented") }
    buildApprovedNamespaces: function(params, supportedNamespaces) { console.error("ConnectorSDK.buildApprovedNamespaces: not implemented") }
}
