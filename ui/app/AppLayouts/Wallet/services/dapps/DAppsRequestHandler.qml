import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0
import utils 1.0

import "types"

SQUtils.QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var accountsModel
    required property var networksModel
    required property CurrenciesStore currenciesStore
    required property WalletStore.WalletAssetsStore assetsStore

    property alias requestsModel: requests

    function rejectSessionRequest(request, userRejected) {
        let error = userRejected ? false : true
        sdk.rejectSessionRequest(request.topic, request.id, error)
    }

    /// Beware, it will fail if called multiple times before getting an answer
    function authenticate(request, payload) {
        return store.authenticateUser(request.topic, request.id, request.account.address, payload)
    }

    signal sessionRequest(SessionRequestResolved request)
    signal displayToastMessage(string message, bool error)
    signal sessionRequestResult(/*model entry of SessionRequestResolved*/ var request, bool isSuccess)
    signal maxFeesUpdated(var /* Big */ fiatMaxFees, var /* Big */ ethMaxFees, bool haveEnoughFunds, bool haveEnoughFees, string symbol, var feesInfo)
    // Reports Constants.TransactionEstimatedTime values
    signal estimatedTimeUpdated(int estimatedTimeEnum)

    Connections {
        target: sdk

        function onSessionRequestEvent(event) {
            const res = d.resolveAsync(event)
            if (res.code == d.resolveAsyncResult.error) {
                let error = true
                sdk.rejectSessionRequest(event.topic, event.id, error)
                return
            }
            if (res.code == d.resolveAsyncResult.ignored) {
                return
            }
            if (!res.obj) {
                console.error("Unexpected res.obj value!")
                return
            }
            requests.enqueue(res.obj)
        }

        function onSessionRequestUserAnswerResult(topic, id, accept, error) {
            let request = requests.findRequest(topic, id)
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

        function onUserAuthenticated(topic, id, password, pin, payload) {
            var request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for topic", topic, "id", id)
                return
            }
            d.executeSessionRequest(request, password, pin, payload)
        }

        function onUserAuthenticationFailed(topic, id) {
            let request = requests.findRequest(topic, id)
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

    SQUtils.QObject {
        id: d

        readonly property QtObject resolveAsyncResult: QtObject {
            readonly property int error: 0
            readonly property int ok: 1
            readonly property int ignored: 2
        }

        // returns {
        //   obj: obj or nil
        //   code: resolveAsyncResult codes
        // }
        function resolveAsync(event) {
            const method = event.params.request.method
            const res = lookupAccountFromEvent(event, method)
            if(!res.success) {
                console.info("Error finding account for event", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.error }
            }
            if (!res.account) {
                console.info("Ignoring request for an account not in the current profile.")
                return { obj: null, code: resolveAsyncResult.ignored }
            }
            const account = res.account

            let network = lookupNetworkFromEvent(event, method)
            if(!network) {
                console.error("Error finding network for event", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.error }
            }

            let data = extractMethodData(event, method)
            if(!data) {
                console.error("Error in event data lookup", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.error }
            }

            const interpreted = d.prepareData(method, data)

            let enoughFunds = !d.isTransactionMethod(method)
            let obj = sessionRequestComponent.createObject(null, {
                event,
                topic: event.topic,
                id: event.id,
                method,
                account,
                network,
                data,
                preparedData: interpreted.preparedData,
                maxFeesText: "?",
                maxFeesEthText: "?",
                enoughFunds: enoughFunds,
            })
            if (obj === null) {
                console.error("Error creating SessionRequestResolved for event")
                return { obj: null, code: resolveAsyncResult.error }
            }

            // Check later to have a valid request object
            if (!SessionRequest.getSupportedMethods().includes(method)) {
                console.error("Unsupported method", method)
                return { obj: null, code: resolveAsyncResult.error }
            }

            d.lookupSession(obj.topic, function(session) {
                if (session === null) {
                    console.error("DAppsRequestHandler.lookupSession: error finding session for topic", obj.topic)
                    return
                }
                obj.resolveDappInfoFromSession(session)
                root.sessionRequest(obj)

                if (!d.isTransactionMethod(method)) {
                    return
                }

                let estimatedTimeEnum = getEstimatedTimeInterval(data, method, obj.network.chainId)
                root.estimatedTimeUpdated(estimatedTimeEnum)

                const mainNet = lookupMainnetNetwork()
                let mainChainId = obj.network.chainId
                if (!!mainNet) {
                    mainChainId = mainNet.chainId
                } else {
                    console.error("Error finding mainnet network")
                }
                let st = getEstimatedFeesStatus(data, method, obj.network.chainId, mainChainId)

                let fundsStatus = checkFundsStatus(st.feesInfo.maxFees, st.feesInfo.l1GasFee, account.address, obj.network.chainId, mainNet.chainId, interpreted.value)

                root.maxFeesUpdated(st.fiatMaxFees, st.maxFeesEth, fundsStatus.haveEnoughFunds,
                                    fundsStatus.haveEnoughForFees, st.symbol, st.feesInfo)
            })

            return {
                obj: obj,
                code: resolveAsyncResult.ok
            }
        }

        /// returns {
        ///   account
        ///   success
        /// }
        /// if account is null and success is true it means that the account was not found
        function lookupAccountFromEvent(event, method) {
            let address = ""
            if (method === SessionRequest.methods.personalSign.name) {
                if (event.params.request.params.length < 2) {
                    return { account: null, success: false }
                }
                address = event.params.request.params[1]
            } else if (method === SessionRequest.methods.sign.name) {
                if (event.params.request.params.length === 1) {
                    return { account: null, success: false }
                }
                address = event.params.request.params[0]
            } else if(method === SessionRequest.methods.signTypedData_v4.name ||
                      method === SessionRequest.methods.signTypedData.name)
            {
                if (event.params.request.params.length < 2) {
                    return { account: null, success: false }
                }
                address = event.params.request.params[0]
            } else if (d.isTransactionMethod(method)) {
                if (event.params.request.params.length == 0) {
                    return { account: null, success: false }
                }
                address = event.params.request.params[0].from
            } else {
                console.error("Unsupported method to lookup account: ", method)
                return { account: null, success: false }
            }
            const account = SQUtils.ModelUtils.getFirstModelEntryIf(root.accountsModel, (account) => {
                return account.address.toLowerCase() === address.toLowerCase();
            })

            if (!account) {
                return { account: null, success: true }
            }

            // deep copy to avoid operations on the original object
            try {
                const accountCopy = JSON.parse(JSON.stringify(account))
                return { account: accountCopy, success: true }
            }
            catch (e) {
                console.error("Error parsing account", e)
                return { account: null, success: false }
            }
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (SessionRequest.getSupportedMethods().includes(method) === false) {
                return null
            }
            const chainId = DAppsHelpers.chainIdFromEip155(event.params.chainId)
            const network = SQUtils.ModelUtils.getByKey(root.networksModel, "chainId", chainId)

            if (!network) {
                return null
            }

            // deep copy to avoid operations on the original object
            try {
                return JSON.parse(JSON.stringify(network))
            } catch (e) {
                console.error("Error parsing network", network)
                return null
            }
        }

        /// Returns null if the network is not found
        function lookupMainnetNetwork() {
            return SQUtils.ModelUtils.getByKey(root.networksModel, "layer", 1)
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
                const messageParam = event.params.request.params[messageIndex]
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
                const jsonMessage = event.params.request.params[1]
                const methodObj = method === SessionRequest.methods.signTypedData_v4.name
                      ? SessionRequest.methods.signTypedData_v4
                      : SessionRequest.methods.signTypedData
                return methodObj.buildDataObject(jsonMessage)
            } else if (method === SessionRequest.methods.signTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                const tx = event.params.request.params[0]
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

        function executeSessionRequest(request, password, pin, payload) {
            if (!SessionRequest.getSupportedMethods().includes(request.method)) {
                console.error("Unsupported method to execute: ", request.method)
                return
            }

            if (password !== "") {
                let actionResult = ""
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
                } else if (d.isTransactionMethod(request.method)) {
                    let txObj = d.getTxObject(request.method, request.data)
                    if (!!payload) {
                        let feesInfoJson = payload
                        let hexFeesJson = root.store.convertFeesInfoToHex(feesInfoJson)
                        if (!!hexFeesJson) {
                            let feesInfo = JSON.parse(hexFeesJson)
                            if (feesInfo.maxFeePerGas) {
                                txObj.maxFeePerGas = feesInfo.maxFeePerGas
                            }
                            if (feesInfo.maxPriorityFeePerGas) {
                                txObj.maxPriorityFeePerGas = feesInfo.maxPriorityFeePerGas
                            }
                        }
                        delete txObj.gasLimit
                        delete txObj.gasPrice
                    }
                    // Remove nonce from txObj to be auto-filled by the wallet
                    delete txObj.nonce

                    if (request.method === SessionRequest.methods.signTransaction.name) {
                        actionResult = store.signTransaction(request.topic, request.id,
                                            request.account.address, request.network.chainId, password, txObj)
                    } else if (request.method === SessionRequest.methods.sendTransaction.name) {
                        actionResult = store.sendTransaction(request.topic, request.id,
                                            request.account.address, request.network.chainId, password, txObj)
                    }
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
            let tx = {}
            let maxFeePerGas = ""
            if (d.isTransactionMethod(method)) {
                tx = d.getTxObject(method, data)
                // Empty string instructs getEstimatedTime to fetch the blockchain value
                if (!!tx.maxFeePerGas) {
                    maxFeePerGas = tx.maxFeePerGas
                } else if (!!tx.gasPrice) {
                    maxFeePerGas = tx.gasPrice
                }
            }

            return root.store.getEstimatedTime(chainId, maxFeePerGas)
        }

        // Returns {
        //      maxFees -> Big number in Gwei
        //      maxFeePerGas
        //      maxPriorityFeePerGas
        //      gasPrice
        // }
        function getEstimatedMaxFees(data, method, chainId, mainNetChainId) {
            let tx = {}
            if (d.isTransactionMethod(method)) {
                tx = d.getTxObject(method, data)
            }

            let BigOps = SQUtils.AmountsArithmetic
            let gasLimit = BigOps.fromString("21000")
            let gasPrice, maxFeePerGas, maxPriorityFeePerGas
            let l1GasFee = BigOps.fromNumber(0)

            // Beware, the tx values are standard blockchain hex big number values; the fees values are nim's float64 values, hence the complex conversions
            if (!!tx.maxFeePerGas && !!tx.maxPriorityFeePerGas) {
                let maxFeePerGasDec = root.store.hexToDec(tx.maxFeePerGas)
                const gasPriceInWei = BigOps.fromString(maxFeePerGasDec)
                gasPrice = hexToGwei(tx.maxFeePerGas)
                // Source fees info from the incoming transaction for when we process it
                maxFeePerGas = root.store.hexToDec(tx.maxFeePerGas)
                let maxPriorityFeePerGasDec = hexToGwei(tx.maxPriorityFeePerGas)
                maxPriorityFeePerGas = maxPriorityFeePerGasDec
            } else {
                let fees = root.store.getSuggestedFees(chainId)
                maxPriorityFeePerGas = fees.maxPriorityFeePerGas
                if (fees.eip1559Enabled) {
                    if (!!fees.maxFeePerGasM) {
                        gasPrice = BigOps.fromNumber(fees.maxFeePerGasM)
                        maxFeePerGas = fees.maxFeePerGasM
                    } else if(!!tx.maxFeePerGas) {
                        let maxFeePerGasDec = root.store.hexToDec(tx.maxFeePerGas)
                        gasPrice = BigOps.fromString(maxFeePerGasDec)
                        maxFeePerGas = maxFeePerGasDec
                    } else {
                        console.error("Error fetching maxFeePerGas from fees or tx objects")
                        return
                    }
                } else {
                    if (!!fees.gasPrice) {
                        gasPrice = BigOps.fromNumber(fees.gasPrice)
                    } else {
                        console.error("Error fetching suggested fees")
                        return
                    }
                }
                l1GasFee = BigOps.fromNumber(fees.l1GasFee)
            }

            let maxFees = BigOps.times(gasLimit, gasPrice)
            return {maxFees, maxFeePerGas, maxPriorityFeePerGas, gasPrice, l1GasFee}
        }

        // Returned values are Big numbers
        function getEstimatedFeesStatus(data, method, chainId, mainNetChainId) {
            let BigOps = SQUtils.AmountsArithmetic

            let feesInfo = getEstimatedMaxFees(data, method, chainId, mainNetChainId)

            let totalMaxFees = BigOps.sum(feesInfo.maxFees, feesInfo.l1GasFee)
            let maxFeesEth = BigOps.div(totalMaxFees, BigOps.fromNumber(1, 9))

            let maxFeesEthStr = maxFeesEth.toString()
            let fiatMaxFeesStr = root.currenciesStore.getFiatValue(maxFeesEthStr, Constants.ethToken)
            let fiatMaxFees = BigOps.fromString(fiatMaxFeesStr)
            let symbol = root.currenciesStore.currentCurrency

            return {fiatMaxFees, maxFeesEth, symbol, feesInfo}
        }

        function getBalanceInEth(balances, address, chainId) {
            const BigOps = SQUtils.AmountsArithmetic
            let accEth = SQUtils.ModelUtils.getFirstModelEntryIf(balances, (balance) => {
                return balance.account.toLowerCase() === address.toLowerCase() && balance.chainId === chainId
            })
            if (!accEth) {
                console.error("Error balance lookup for account ", address, " on chain ", chainId)
                return null
            }
            let accountFundsWei = BigOps.fromString(accEth.balance)
            return BigOps.div(accountFundsWei, BigOps.fromNumber(1, 18))
        }

        // Returns {haveEnoughForFees, haveEnoughFunds} and true in case of error not to block request
        function checkFundsStatus(maxFees, l1GasFee, address, chainId, mainNetChainId, valueEth) {
            let BigOps = SQUtils.AmountsArithmetic

            let haveEnoughForFees = true
            let haveEnoughFunds = true

            let token = SQUtils.ModelUtils.getByKey(root.assetsStore.groupedAccountAssetsModel, "tokensKey", Constants.ethToken)
            if (!token || !token.balances) {
                console.error("Error token balances lookup for ETH")
                return {haveEnoughForFees, haveEnoughFunds}
            }

            let chainBalance = getBalanceInEth(token.balances, address, chainId)
            if (!chainBalance) {
                console.error("Error fetching chain balance")
                return {haveEnoughForFees, haveEnoughFunds}
            }
            haveEnoughFunds = BigOps.cmp(chainBalance, valueEth) >= 0
            if (haveEnoughFunds) {
                chainBalance = BigOps.sub(chainBalance, valueEth)

                if (chainId == mainNetChainId) {
                    const finalFees = BigOps.sum(maxFees, l1GasFee)
                    let feesEth = BigOps.div(finalFees, BigOps.fromNumber(1, 9))
                    haveEnoughForFees = BigOps.cmp(chainBalance, feesEth) >= 0
                } else {
                    const feesChain = BigOps.div(maxFees, BigOps.fromNumber(1, 9))
                    const haveEnoughOnChain = BigOps.cmp(chainBalance, feesChain) >= 0

                    const mainBalance = getBalanceInEth(token.balances, address, mainNetChainId)
                    if (!mainBalance) {
                        console.error("Error fetching mainnet balance")
                        return {haveEnoughForFees, haveEnoughFunds}
                    }
                    const feesMain = BigOps.div(l1GasFee, BigOps.fromNumber(1, 9))
                    const haveEnoughOnMain = BigOps.cmp(mainBalance, feesMain) >= 0

                    haveEnoughForFees = haveEnoughOnChain && haveEnoughOnMain
                }
            } else {
                haveEnoughForFees = false
            }

            return {haveEnoughForFees, haveEnoughFunds}
        }

        function isTransactionMethod(method) {
            return method === SessionRequest.methods.signTransaction.name
                || method === SessionRequest.methods.sendTransaction.name
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
