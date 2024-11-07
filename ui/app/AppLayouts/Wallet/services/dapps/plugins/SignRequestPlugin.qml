import QtQuick 2.15
import QtQml 2.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0
import utils 1.0

/// Plugin that listens for session requests and manages the lifecycle of the request.
SQUtils.QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    /// Expected to have the following roles:
    /// - topic
    /// - name
    /// - url
    /// - iconUrl
    /// - rawSessions
    required property var dappsModel
    /// Expected to have the following roles:
    /// - tokensKey
    /// - balances
    required property var groupedAccountAssetsModel
    /// Expected to have the following roles:
    /// - layer
    /// - chainId
    required property var networksModel
    /// Expected to have the following roles:
    /// - address
    required property var accountsModel
    /// App currency
    required property string currentCurrency
    // SessionRequestsModel where the requests are stored
    // This component will append and remove requests from this model
    required property SessionRequestsModel requests
    // Function to transform the eth value to fiat
    property var getFiatValue: (maxFeesEthStr, token /*Constants.ethToken*/) => console.error("getFiatValue not implemented")

    // Signals
    /// Signal emitted when a session request is accepted
    signal accepted(string topic, string id, string data)
    /// Signal emitted when a session request is rejected
    signal rejected(string topic, string id, bool hasError)
    /// Signal emitted when a session request is completed
    /// Completed mean that we have the ACK from the SDK
    signal signCompleted(string topic, string id, bool userAccepted, string error)

    function requestReceived(event, dappName, dappUrl, dappIcon, connectorId) {
        d.onSessionRequestEvent(event, dappName, dappUrl, dappIcon, connectorId)
    }

    function requestResolved(topic, id) {
        root.requests.removeRequest(topic, id)
    }

    function requestExpired(sessionId) {
        d.onSessionRequestExpired(sessionId)
    }

    onRejected: (topic, id, hasError) => {
        root.sdk.rejectSessionRequest(topic, id, hasError)
    }

    onAccepted: (topic, id, data) => {
        root.sdk.acceptSessionRequest(topic, id, data)
    }

    Component {
        id: sessionRequestComponent

        SessionRequestWithAuth {
            id: request
            store: root.store

            function signedHandler(topic, id, data) {
                if (topic != request.topic || id != request.requestId) {
                    return
                }
                root.store.signingResult.disconnect(request.signedHandler)

                let hasErrors = (data == "")
                if (!hasErrors) {
                    root.accepted(topic, id, data)
                } else {
                    request.reject(true)
                }
            }

            onActiveChanged: {
                if (active === false) {
                    d.unsubscribeForFeeUpdates(request.topic, request.requestId)
                }
                if (active === true) {
                    d.subscribeForFeeUpdates(request.topic, request.requestId)
                }
            }

            onRejected: (hasError) => {
                root.rejected(request.topic, request.requestId, hasError)
                d.unsubscribeForFeeUpdates(request.topic, request.requestId)
            }

            onAuthFailed: () => {
                root.rejected(request.topic, request.requestId, true /*hasError*/)
                d.unsubscribeForFeeUpdates(request.topic, request.requestId)
            }

            onExecute: (password, pin) => {
                d.unsubscribeForFeeUpdates(request.topic, request.requestId)
                root.store.signingResult.connect(request.signedHandler)
                let executed = false
                try {
                    executed = d.executeSessionRequest(request, password, pin, request.feesInfo)
                } catch (e) {
                    console.error("Error executing session request", e)
                }
                
                if (!executed) {
                    root.rejected(request.topic, request.requestId, true /*hasError*/)
                    root.store.signingResult.disconnect(request.signedHandler)
                }
            }
        }
    }

    Connections {
        target: root.sdk

        function onSessionRequestEvent(sessionRequest) {
            const { id, topic } = sessionRequest
            const dapp = SQUtils.ModelUtils.getFirstModelEntryIf(root.dappsModel, (dapp) => {
                if (dapp.topic === topic) {
                    return true
                }
                return !!SQUtils.ModelUtils.getFirstModelEntryIf(dapp.rawSessions, (session) => {
                    if (session.topic === topic) {
                        return true
                    }
                })
            })

            if (!dapp) {
                console.warn("Error finding dapp for topic", topic, "id", id)
                root.sdk.rejectSessionRequest(topic, id, true)
                return
            }

            root.requestReceived(sessionRequest, dapp.name, dapp.url, dapp.iconUrl, dapp.connectorId)
        }

        function onSessionRequestExpired(sessionId) {
            root.requestExpired(sessionId)
        }

        function onSessionRequestUserAnswerResult(topic, id, accept, error) {
            let request = root.requests.findRequest(topic, id)

            if (request === null) {
                console.error("Error finding event for topic", topic, "id", id)
                return
            }
            Qt.callLater(() => root.requestResolved(topic, id))

            if (error) {
                root.signCompleted(topic, id, accept, error)
                console.error(`Error accepting session request for topic: ${topic}, id: ${id}, accept: ${accept}, error: ${error}`)
                return
            }

            root.signCompleted(topic, id, accept, "")
        }
    }

    QtObject {
        id: d

        function onSessionRequestEvent(event, dappName, dappUrl, dappIcon, connectorId) {
            try {
                const res = d.resolve(event, dappName, dappUrl, dappIcon, connectorId)
                if (res.conde === SessionRequest.Ignored) {
                    return
                }
                if (res.code !== SessionRequest.NoError) {
                    root.rejected(event.topic, event.id, true)
                    return
                }
                root.requests.enqueue(res.obj)
            } catch (e) {
                console.error("Error processing session request event", e)
                root.rejected(event.topic, event.id, true)
            }
        }

        function onSessionRequestExpired(sessionId) {
            // Expired event coming from WC
            // Handling as a failsafe in case the event is not processed by the SDK
            let request = root.requests.findById(sessionId)
            if (request === null) {
                console.error("Error finding event for session id", sessionId)
                return
            }

            if (request.isExpired()) {
                return //nothing to do. The request is already expired
            }

            request.setExpired()
            d.unsubscribeForFeeUpdates(request.topic, request.requestId)
        }
        // returns {
        //   obj: obj or nil
        //   code: SessionRequest.ErrorCode
        // }
        function resolve(event, dappName, dappUrl, dappIcon, connectorId) {
            const {request, error} = SessionRequestResolver.resolveEvent(event, root.accountsModel, root.networksModel, root.store.hexToDec)
            if (error !== SessionRequest.NoError) {
                return { obj: null, code: error }
            }
            if (!request) {
                return { obj: null, code: SessionRequest.RuntimeError }
            }
            const mainNet = lookupMainnetNetwork()
            if (!mainNet) {
                console.error("Mainnet network not found")
                return { obj: null, code: SessionRequest.RuntimeError }
            }

            updateFeesOnPreparedData(request)

            let obj = sessionRequestComponent.createObject(null, {
                event: request.event,
                topic: request.topic,
                requestId: request.requestId,
                method: request.method,
                accountAddress: request.account,
                chainId: request.chainId,
                data: request.data,
                preparedData: JSON.stringify(request.preparedData),
                expirationTimestamp: request.expiryTimestamp,
                dappName,
                dappUrl,
                dappIcon,
                sourceId: connectorId,
                value: request.value
            })
            if (obj === null) {
                console.error("Error creating SessionRequestResolved for event")
                return { obj: null, code: SessionRequest.RuntimeError }
            }

            if (!request.transaction) {
                obj.haveEnoughFunds = true
                return { obj: obj, code: SessionRequest.NoError }
            }

            updateFeesParamsToPassedObj(obj)

            return {
                obj: obj,
                code: SessionRequest.NoError
            }
        }


        // Updates the fees to a SessionRequestResolved
        function updateFeesParamsToPassedObj(requestItem) {
            if (!(requestItem instanceof SessionRequestResolved)) {
                return
            }
            if (!SessionRequest.isTransactionMethod(requestItem.method)) {
                return
            }

            const mainNet = lookupMainnetNetwork()
            if (!mainNet) {
                console.error("Mainnet network not found")
                return { obj: null, code: SessionRequest.RuntimeError }
            }

            const tx = SessionRequest.getTxObject(requestItem.method, requestItem.data)
            requestItem.estimatedTimeCategory =  root.store.getEstimatedTime(requestItem.chainId, tx.maxFeePerGas || tx.gasPrice || "")

            let st = getEstimatedFeesStatus(tx, requestItem.method, requestItem.chainId, mainNet.chainId)
            let fundsStatus = checkFundsStatus(st.feesInfo.maxFees, st.feesInfo.l1GasFee, requestItem.accountAddress, requestItem.chainId, mainNet.chainId, requestItem.value)
            requestItem.fiatMaxFees = st.fiatMaxFees
            requestItem.ethMaxFees = st.maxFeesEth
            requestItem.haveEnoughFunds = fundsStatus.haveEnoughFunds
            requestItem.haveEnoughFees = fundsStatus.haveEnoughForFees
            requestItem.feesInfo = st.feesInfo
        }

        // Updates the fee in the transaction preview on a JS Object built by SessionRequest
        function updateFeesOnPreparedData(request) {
            if (!request.transaction && !request.preparedData instanceof Object) {
                return
            }

            let fees = root.store.getSuggestedFees(request.chainId)
            if (!request.preparedData.maxFeePerGas 
                && request.preparedData.hasOwnProperty("maxFeePerGas")
                && fees.eip1559Enabled) {
                request.preparedData.maxFeePerGas = d.getFeesForFeesMode(fees)
            }

            if (!request.preparedData.maxPriorityFeePerGas 
                && request.preparedData.hasOwnProperty("maxPriorityFeePerGas")
                && fees.eip1559Enabled) {
                request.preparedData.maxPriorityFeePerGas = fees.maxPriorityFeePerGas
            }

            if (!request.preparedData.gasPrice 
                && request.preparedData.hasOwnProperty("gasPrice")
                && !fees.eip1559Enabled) {
                request.preparedData.gasPrice = fees.gasPrice
            }
        }

        /// Returns null if the network is not found
        function lookupMainnetNetwork() {
            return SQUtils.ModelUtils.getByKey(root.networksModel, "layer", 1)
        }

        function executeSessionRequest(request, password, pin, payload) {
            if (!SessionRequest.getSupportedMethods().includes(request.method)) {
                console.error("Unsupported method to execute: ", request.method)
                return false
            }

            if (password === "") {
                console.error("No password provided to sign message")
                return false
            }

            if (request.method === SessionRequest.methods.sign.name) {
                root.store.signMessageUnsafe(request.topic,
                                        request.requestId,
                                        request.accountAddress,
                                        SessionRequest.methods.personalSign.getMessageFromData(request.data),
                                        password,
                                        pin)
            } else if (request.method === SessionRequest.methods.personalSign.name) {
                root.store.signMessage(request.topic,
                                  request.requestId,
                                  request.accountAddress,
                                  SessionRequest.methods.personalSign.getMessageFromData(request.data),
                                  password,
                                  pin)
            } else if (request.method === SessionRequest.methods.signTypedData_v4.name ||
                       request.method === SessionRequest.methods.signTypedData.name)
            {
                let legacy = request.method === SessionRequest.methods.signTypedData.name
                root.store.safeSignTypedData(request.topic,
                                        request.requestId,
                                        request.accountAddress,
                                        SessionRequest.methods.signTypedData.getMessageFromData(request.data),
                                        request.chainId,
                                        legacy,
                                        password,
                                        pin)
            } else if (SessionRequest.isTransactionMethod(request.method)) {
                let txObj = SessionRequest.getTxObject(request.method, request.data)
                if (!!payload) {
                    let hexFeesJson = root.store.convertFeesInfoToHex(JSON.stringify(payload))
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
                    root.store.signTransaction(request.topic,
                                          request.requestId,
                                          request.accountAddress,
                                          request.chainId,
                                          txObj,
                                          password,
                                          pin)
                } else if (request.method === SessionRequest.methods.sendTransaction.name) {
                    root.store.sendTransaction(
                                request.topic,
                                request.requestId,
                                request.accountAddress,
                                request.chainId,
                                txObj,
                                password,
                                pin)
                }
            }

            return true
        }

        // Returns {
        //      maxFees -> Big number in Gwei
        //      maxFeePerGas
        //      maxPriorityFeePerGas
        //      gasPrice
        // }
        function getEstimatedMaxFees(tx, method, chainId, mainNetChainId) {
            const BigOps = SQUtils.AmountsArithmetic
            const gasLimit = BigOps.fromString("21000")
            const parsedTransaction = SessionRequest.parseTransaction(tx, root.store.hexToDec)
            let gasPrice = BigOps.fromString(parsedTransaction.maxFeePerGas)
            let maxFeePerGas = BigOps.fromString(parsedTransaction.maxFeePerGas)
            let maxPriorityFeePerGas = BigOps.fromString(parsedTransaction.maxPriorityFeePerGas)
            let l1GasFee = BigOps.fromNumber(0)

            if (!maxFeePerGas || !maxPriorityFeePerGas || !gasPrice) {
                const suggesteFees = getSuggestedFees(chainId)
                maxFeePerGas = suggesteFees.maxFeePerGas
                maxPriorityFeePerGas = suggesteFees.maxPriorityFeePerGas
                gasPrice = suggesteFees.gasPrice
                l1GasFee = suggesteFees.l1GasFee
            }

            let maxFees = BigOps.times(gasLimit, gasPrice)
            return {maxFees, maxFeePerGas, maxPriorityFeePerGas, gasPrice, l1GasFee}
        }

        function getSuggestedFees(chainId) {
            const BigOps = SQUtils.AmountsArithmetic
            const fees = root.store.getSuggestedFees(chainId)
            const maxPriorityFeePerGas = fees.maxPriorityFeePerGas
            let maxFeePerGas
            let gasPrice
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
            const l1GasFee = BigOps.fromNumber(fees.l1GasFee)
            return {maxFeePerGas, maxPriorityFeePerGas, gasPrice, l1GasFee}
        }

        // Returned values are Big numbers
        function getEstimatedFeesStatus(tx, method, chainId, mainNetChainId) {
            const BigOps = SQUtils.AmountsArithmetic

            const feesInfo = getEstimatedMaxFees(tx, method, chainId, mainNetChainId)

            const totalMaxFees = BigOps.sum(feesInfo.maxFees, feesInfo.l1GasFee)
            const maxFeesEth = BigOps.div(totalMaxFees, BigOps.fromNumber(1, 9))

            const maxFeesEthStr = maxFeesEth.toString()
            const fiatMaxFeesStr = root.getFiatValue(maxFeesEthStr, Constants.ethToken)
            const fiatMaxFees = BigOps.fromString(fiatMaxFeesStr)
            const symbol = root.currentCurrency

            return {fiatMaxFees, maxFeesEth, symbol, feesInfo}
        }

        function getBalanceInEth(balances, address, chainId) {
            const BigOps = SQUtils.AmountsArithmetic
            const accEth = SQUtils.ModelUtils.getFirstModelEntryIf(balances, (balance) => {
                return balance.account.toLowerCase() === address.toLowerCase() && balance.chainId == chainId
            })
            if (!accEth) {
                console.error("Error balance lookup for account ", address, " on chain ", chainId)
                return null
            }
            const accountFundsWei = BigOps.fromString(accEth.balance)
            return BigOps.div(accountFundsWei, BigOps.fromNumber(1, 18))
        }

        // Returns {haveEnoughForFees, haveEnoughFunds} and true in case of error not to block request
        function checkFundsStatus(maxFees, l1GasFee, address, chainId, mainNetChainId, value) {
            const BigOps = SQUtils.AmountsArithmetic
            let valueEth = BigOps.fromString(value)
            let haveEnoughForFees = true
            let haveEnoughFunds = true

            let token = SQUtils.ModelUtils.getByKey(root.groupedAccountAssetsModel, "tokensKey", Constants.ethToken)
            if (!token || !token.balances) {
                console.error("Error token balances lookup for ETH", SQUtils.ModelUtils.modelToArray(root.groupedAccountAssetsModel))
                console.error("Looking for tokensKey: ", Constants.ethToken)
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

        property int selectedFeesMode: Constants.FeesMode.Medium

        function getFeesForFeesMode(feesObj) {
            if (!(feesObj.hasOwnProperty("maxFeePerGasL") &&
                  feesObj.hasOwnProperty("maxFeePerGasM") &&
                  feesObj.hasOwnProperty("maxFeePerGasH"))) {
                throw new Error("inappropriate fees object provided")
            }

            switch (d.selectedFeesMode) {
            case Constants.FeesMode.Low:
                return feesObj.maxFeePerGasL
            case Constants.FeesMode.Medium:
                return feesObj.maxFeePerGasM
            case Constants.FeesMode.High:
                return feesObj.maxFeePerGasH
            default:
                throw new Error("unknown selected mode")
            }
        }

        property var feesSubscriptions: []

        function findSubscriptionIndex(topic, id) {
            for (let i = 0; i < d.feesSubscriptions.length; i++) {
                const subscription = d.feesSubscriptions[i]
                if (subscription.topic == topic && subscription.id == id) {
                    return i
                }
            }
            return -1
        }

        function findChainIndex(chainId) {
            for (let i = 0; i < feesSubscription.chainIds.length; i++) {
                if (feesSubscription.chainIds[i] == chainId) {
                    return i
                }
            }
            return -1
        }

        function subscribeForFeeUpdates(topic, id) {
            const request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for subscribing for fees for topic", topic, "id", id)
                return
            }

            const index = d.findSubscriptionIndex(topic, id)
            if (index >= 0) {
                return
            }

            d.feesSubscriptions.push({
                                         topic: topic,
                                         id: id,
                                         chainId: request.chainId
                                     })

            for (let i = 0; i < feesSubscription.chainIds.length; i++) {
                if (feesSubscription.chainIds == request.chainId) {
                    return
                }
            }

            feesSubscription.chainIds.push(request.chainId)
            feesSubscription.restart()
        }

        function unsubscribeForFeeUpdates(topic, id) {
            const index = d.findSubscriptionIndex(topic, id)
            if (index == -1) {
                return
            }

            const chainId = d.feesSubscriptions[index].chainId
            d.feesSubscriptions.splice(index, 1)

            const chainIndex = d.findChainIndex(chainId)
            if (index == -1) {
                return
            }

            let found = false
            for (let i = 0; i < d.feesSubscriptions.length; i++) {
                if (d.feesSubscriptions[i].chainId == chainId) {
                    found = true
                    break
                }
            }

            if (found) {
                return
            }

            feesSubscription.chainIds.splice(chainIndex, 1)
            if (feesSubscription.chainIds.length == 0) {
                feesSubscription.stop()
            }
        }
    }

    Timer {
        id: feesSubscription

        property var chainIds: []

        interval: 5000
        repeat: true
        running: Qt.application.state === Qt.ApplicationActive

        onTriggered: {
            for (let i = 0; i < chainIds.length; i++) {
                for (let j = 0; j < d.feesSubscriptions.length; j++) {
                    let subscription = d.feesSubscriptions[j]
                    if (subscription.chainId == chainIds[i]) {
                        let request = requests.findRequest(subscription.topic, subscription.id)
                        if (request === null) {
                            console.error("Error updating fees for topic", subscription.topic, "id", subscription.id)
                            continue
                        }
                        d.updateFeesParamsToPassedObj(request)
                    }
                }
            }
        }
    }
}