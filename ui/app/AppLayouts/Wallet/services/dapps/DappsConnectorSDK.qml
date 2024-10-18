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

    readonly property string invalidDAppUrlError: "Invalid dappInfo: URL is missing"
    readonly property string invalidDAppTopicError: "Invalid dappInfo: failed to parse topic"

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
            let accountAddress = lookupAccountFromEvent(event, method)
            if(!accountAddress) {
                console.error("Error finding accountAddress for event", JSON.stringify(event))
                return null
            }
            let chainId = lookupNetworkFromEvent(event, method)
            if(!chainId) {
                console.error("Error finding network for event", JSON.stringify(event))
                return null
            }
            let data = extractMethodData(event, method)
            if(!data) {
                console.error("Error in event data lookup", JSON.stringify(event))
                return null
            }
            const interpreted = d.prepareData(method, data)
            let enoughFunds = !isTransactionMethod(method)
            let obj = sessionRequestComponent.createObject(null, {
                event,
                topic: event.topic,
                requestId: event.id,
                method,
                accountAddress,
                chainId,
                data,
                preparedData: interpreted.preparedData,
                maxFeesText: "?",
                maxFeesEthText: "?",
                haveEnoughFunds: enoughFunds
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

            let session = getActiveSession(root.dappInfo)

            if (session === null) {
                console.error("Connector.lookupSession: error finding session for requestId ", obj.requestId)
                return
            }
            obj.resolveDappInfoFromSession(session)

            if (d.isTransactionMethod(method)) {
                let tx = obj.data.tx
                if (tx === null) {
                    console.error("Error cannot resolve tx object")
                    return null
                }
                let BigOps = SQUtils.AmountsArithmetic
                let gasLimit = hexToGwei(tx.gasLimit)

                if (tx.gasPrice === null || tx.gasPrice === undefined) {
                    let maxFeePerGas = hexToGwei(tx.maxFeePerGas)
                    let maxPriorityFeePerGas = hexToGwei(tx.maxPriorityFeePerGas)
                    let totalMaxFees = BigOps.sum(maxFeePerGas, maxPriorityFeePerGas)
                    let maxFees = BigOps.times(gasLimit, totalMaxFees)
                    let maxFeesString = maxFees.toString()
                    obj.maxFeesText = maxFeesString
                    obj.maxFeesEthText = maxFeesString
                    obj.haveEnoughFunds = true
                } else {
                    let gasPrice = hexToGwei(tx.gasPrice)
                    let maxFees = BigOps.times(gasLimit, gasPrice)
                    let maxFeesString = maxFees.toString()
                    obj.maxFeesText = maxFeesString
                    obj.maxFeesEthText = maxFeesString
                    obj.haveEnoughFunds = true
                }
            }

            return obj
        }

        function getTxObject(method, data) {
            let tx
            if (method === SessionRequest.methods.signTransaction.name) {
                tx = SessionRequest.methods.signTransaction.getTxObjFromData(data)
            } else if (method === SessionRequest.methods.sendTransaction.name) {
                tx = SessionRequest.methods.sendTransaction.getTxObjFromData(data)
            } else {
                console.error("Not a transaction method")
            }
            return tx
        }

        // returns {
        //   preparedData,
        //   value // null or ETH Big number
        // }
        function prepareData(method, data) {
            let payload = null
            switch(method) {
                case SessionRequest.methods.personalSign.name: {
                    payload = SessionRequest.methods.personalSign.getMessageFromData(data)
                    break
                }
                case SessionRequest.methods.sign.name: {
                    payload = SessionRequest.methods.sign.getMessageFromData(data)
                    break
                }
                case SessionRequest.methods.signTypedData_v4.name: {
                    const stringPayload = SessionRequest.methods.signTypedData_v4.getMessageFromData(data)
                    payload = JSON.stringify(JSON.parse(stringPayload), null, 2)
                    break
                }
                case SessionRequest.methods.signTypedData.name: {
                    const stringPayload = SessionRequest.methods.signTypedData.getMessageFromData(data)
                    payload = JSON.stringify(JSON.parse(stringPayload), null, 2)
                    break
                }
                case SessionRequest.methods.signTransaction.name:
                case SessionRequest.methods.sendTransaction.name:
                    // For transactions we process the data in a different way as follows
                    break
                default:
                    console.error("Unhandled method", method)
                    break;
            }

            let value = SQUtils.AmountsArithmetic.fromNumber(0)
            if (d.isTransactionMethod(method)) {
                let txObj = d.getTxObject(method, data)
                let tx = Object.assign({}, txObj)
                if (tx.value) {
                    value = hexToEth(tx.value)
                    tx.value = value.toString()
                }
                if (tx.maxFeePerGas) {
                    tx.maxFeePerGas = hexToGwei(tx.maxFeePerGas).toString()
                }
                if (tx.maxPriorityFeePerGas) {
                    tx.maxPriorityFeePerGas = hexToGwei(tx.maxPriorityFeePerGas).toString()
                }
                if (tx.gasPrice) {
                    tx.gasPrice = hexToGwei(tx.gasPrice)
                }
                if (tx.gasLimit) {
                    tx.gasLimit = parseInt(root.store.hexToDec(tx.gasLimit))
                }
                if (tx.nonce) {
                    tx.nonce = parseInt(root.store.hexToDec(tx.nonce))
                }

                payload = JSON.stringify(tx, null, 2)
            }
            return {
                    preparedData: payload,
                    value: value
                }
        }

        function hexToEth(value) {
            return hexToEthDenomination(value, "eth")
        }
        function hexToGwei(value) {
            return hexToEthDenomination(value, "gwei")
        }
        function hexToEthDenomination(value, ethUnit) {
            let unitMapping = {
                "gwei": 9,
                "eth": 18
            }
            let BigOps = SQUtils.AmountsArithmetic
            let decValue = root.store.hexToDec(value)
            if (!!decValue) {
                return BigOps.div(BigOps.fromNumber(decValue), BigOps.fromNumber(1, unitMapping[ethUnit]))
            }
            return BigOps.fromNumber(0)
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
                    return address
                }
                address = event.params.request.params[1]
            } else if (method === SessionRequest.methods.sign.name) {
                if (event.params.request.params.length === 1) {
                    return address
                }
                address = event.params.request.params[0]
            } else if(method === SessionRequest.methods.signTypedData_v4.name ||
                      method === SessionRequest.methods.signTypedData.name)
            {
                if (event.params.request.params.length < 2) {
                    return address
                }
                address = event.params.request.params[0]
            } else if (method === SessionRequest.methods.signTransaction.name
                    || method === SessionRequest.methods.sendTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return address
                }
                address = event.params.request.params[0].from
            } else {
                console.error("Unsupported method to lookup account: ", method)
                return null
            }
            const account = SQUtils.ModelUtils.getFirstModelEntryIf(root.wcService.validAccounts, (account) => {
                return account.address.toLowerCase() === address.toLowerCase();
            })

            if (!account) {
                return address
            }

            return account.address
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (SessionRequest.getSupportedMethods().includes(method) === false) {
                return null
            }
            const chainId = DAppsHelpers.chainIdFromEip155(event.params.chainId)
            const network = SQUtils.ModelUtils.getByKey(root.walletStore.filteredFlatModel, "chainId", chainId)

            if (!network) {
                return null
            }

            return network.chainId
        }

        function extractMethodData(event, method) {
            if (method === SessionRequest.methods.personalSign.name ||
                method === SessionRequest.methods.sign.name)
            {
                if (event.params.request.params.length < 1) {
                    return null
                }
                let message = ""
                const messageIndex = (method === SessionRequest.methods.personalSign.name ? 0 : 1)
                const messageParam = event.params.request.tx.data

                // There is no standard on how data is encoded. Therefore we support hex or utf8
                if (DAppsHelpers.isHex(messageParam)) {
                    message = DAppsHelpers.hexToString(messageParam)
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
                const tx = event.params.request.params[0]
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

            if (password === "") {
                console.error("No password provided to sign message")
                return
            }

            if (request.method === SessionRequest.methods.sign.name) {
                store.signMessageUnsafe(request.topic,
                                        request.requestId,
                                        request.accountAddress,
                                        SessionRequest.methods.personalSign.getMessageFromData(request.data),
                                        password,
                                        pin)
            } else if (request.method === SessionRequest.methods.personalSign.name) {
                store.signMessage(request.topic,
                                  request.requestId,
                                  request.accountAddress,
                                  SessionRequest.methods.personalSign.getMessageFromData(request.data),
                                  password,
                                  pin)
            } else if (request.method === SessionRequest.methods.signTypedData_v4.name ||
                       request.method === SessionRequest.methods.signTypedData.name)
            {
                let legacy = request.method === SessionRequest.methods.signTypedData.name
                store.safeSignTypedData(request.topic,
                                        request.requestId,
                                        request.accountAddress,
                                        SessionRequest.methods.signTypedData.getMessageFromData(request.data),
                                        request.chainId,
                                        legacy,
                                        password,
                                        pin)
            } else if (request.method === SessionRequest.methods.signTransaction.name) {
                let txObj = SessionRequest.methods.signTransaction.getTxObjFromData(request.data)
                store.signTransaction(request.topic,
                                      request.requestId,
                                      request.accountAddress,
                                      request.chainId,
                                      txObj,
                                      password,
                                      pin)
            } else if (request.method === SessionRequest.methods.sendTransaction.name) {
                store.sendTransaction(request.topic,
                                      request.requestId,
                                      request.accountAddress,
                                      request.chainId,
                                      request.data.tx,
                                      password,
                                      pin)
            }
        }

        function acceptSessionRequest(topic, id, signature) {
            console.debug(`Connector DappsConnectorSDK.acceptSessionRequest; requestId: ${root.requestId}, signature: "${signature}"`)

            sessionRequestLoader.active = false
            controller.approveTransactionRequest(requestId, signature)

            root.wcService.displayToastMessage(qsTr("Successfully signed transaction from %1").arg(root.dappInfo.url), false)
        }

        function getActiveSession(dappInfos) {
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

            let session = root.wcService.connectorDAppsProvider.getActiveSession(dappInfos.url)
            if (!session) {
                console.error("Connector.lookupSession: error finding session for requestId ", root.requestId)

                return
            }

            return sessionTemplate(session.url, session.name, session.icon)
        }

        function authenticate(request) {
            return store.authenticateUser(request.topic, request.requestId, request.accountAddress)
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

        function onSigningResult(topic, id, data) {
            let isSuccessful = (data != "")
            if (isSuccessful) {
                // acceptSessionRequest will trigger an sdk.sessionRequestUserAnswerResult signal
                d.acceptSessionRequest(topic, id, data)
            } else {
                console.error("signing error")
            }
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

            onDisconnect: {
                connectDappLoader.active = false;
                controller.recallDAppPermission(root.dappInfo.url)
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

            readonly property var account: accountEntry.available ? accountEntry.item : {
                "address": "",
                "name": "",
                "emoji": "",
                "colorId": 0
            }

            readonly property var network: networkEntry.available ? networkEntry.item : {
                "chainId": 0,
                "chainName": "",
                "iconUrl": ""
            }

            loginType: account.migragedToKeycard ? Constants.LoginType.Keycard : root.loginType
            formatBigNumber: (number, symbol, noSymbolOption) => root.wcService.walletRootStore.currencyStore.formatBigNumber(number, symbol, noSymbolOption)

            visible: true

            dappName: request.dappName
            dappUrl: request.dappUrl
            dappIcon: request.dappIcon

            accountColor: Utils.getColorForId(account.colorId)
            accountName: account.name
            accountAddress: account.address
            accountEmoji: account.emoji

            networkName: network.chainName
            networkIconPath: Theme.svg(network.iconUrl)

            fiatFees: request.maxFeesText
            cryptoFees: request.maxFeesEthText
            estimatedTime: ""
            feesLoading: !request.maxFeesText || !request.maxFeesEthText
            hasFees: signingTransaction
            enoughFundsForTransaction: request.haveEnoughFunds
            enoughFundsForFees: request.haveEnoughFunds

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
                        return JSON.stringify(request.data, null, 2)
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

            ModelEntry {
                id: networkEntry
                sourceModel: root.wcService.flatNetworks
                key: "chainId"
                value: request.chainId
            }

            ModelEntry {
                id: accountEntry
                sourceModel: root.wcService.validAccounts
                key: "address"
                value: request.accountAddress
            }
        }
    }

    Component {
        id: sessionRequestComponent

        SessionRequestResolved {
            sourceId: Constants.DAppConnectors.StatusConnect
        }
    }

    SessionRequestsModel {
        id: requests
    }

    Connections {
        target: root.wcService

        function onRevokeSession(topic) {
            if (!topic) {
                console.warn(invalidDAppTopicError)
                return
            }

            controller.recallDAppPermission(topic)
            root.wcService.connectorDAppsProvider.revokeSession(topic)
        }
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
                        "method": SessionRequest.methods.sendTransaction.name,
                        "params": [
                            {
                                "from": txArgsParams.from,
                                "to": txArgsParams.to,
                                "value": txArgsParams.value,
                                "gasLimit": txArgsParams.gas,
                                "gasPrice": txArgsParams.gasPrice,
                                "maxFeePerGas": txArgsParams.maxFeePerGas,
                                "maxPriorityFeePerGas": txArgsParams.maxPriorityFeePerGas,
                                "nonce": txArgsParams.nonce,
                                "data": txArgsParams.data
                            }
                        ]
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

        onDappGrantDAppPermission: function(dappInfoString) {
            let dappItem = JSON.parse(dappInfoString)
            const { url, name, icon: iconUrl } = dappItem

            if (!url) {
                console.warn(invalidDAppUrlError)
                return
            }

            root.wcService.connectorDAppsProvider.addSession(url, name, iconUrl)
        }

        onDappRevokeDAppPermission: function(dappInfoString) {
            let dappItem = JSON.parse(dappInfoString)
            let session = {
                "url": dappItem.url,
                "name": dappItem.name,
                "iconUrl": dappItem.icon,
                "topic": dappItem.url
            }

            if (!session.url) {
                console.warn(invalidDAppUrlError)
                return
            }
            root.wcService.connectorDAppsProvider.revokeSession(JSON.stringify(session))
            root.wcService.displayToastMessage(qsTr("Disconnected from %1").arg(dappItem.url), false)
        }
    }

    approveSession: function(requestId, account, selectedChains) {
        controller.approveDappConnectRequest(requestId, account, JSON.stringify(selectedChains))
        const { url, name, icon: iconUrl } = root.dappInfo;
        //TODO: temporary solution until we have a proper way to handle accounts
        //The dappProvider should add a new session only when the backend has validated the connection
        //Currently the dapp info is limited to the url, name and icon
        root.wcService.connectorDAppsProvider.addSession(url, name, iconUrl, account)
        root.wcService.displayToastMessage(qsTr("Successfully authenticated %1").arg(url), false);
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
