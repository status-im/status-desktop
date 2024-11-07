pragma Singleton

import QtQml 2.15

import AppLayouts.Wallet.services.dapps 1.0
import StatusQ.Core.Utils 0.1 as SQUtils
import utils 1.0

QtObject {

    /// Supported methods
    /// userString is used in the context `dapp.url #{userString} <accepted/rejected>`
    /// requestDisplay is used in the context `dApp wants you to ${requestDisplay} with <Account Name Here>`
    readonly property QtObject methods: QtObject {
        readonly property QtObject personalSign: QtObject {
            readonly property string name: Constants.personal_sign
            readonly property string userString: qsTr("sign")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject sign: QtObject {
            readonly property string name: "eth_sign"
            readonly property string userString: qsTr("sign")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject signTypedData_v4: QtObject {
            readonly property string name: "eth_signTypedData_v4"
            readonly property string userString: qsTr("sign typed data")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject signTypedData: QtObject {
            readonly property string name: "eth_signTypedData"
            readonly property string userString: qsTr("sign typed data")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject signTransaction: QtObject {
            readonly property string name: "eth_signTransaction"
            readonly property string userString: qsTr("sign transaction")
            readonly property string requestDisplay: qsTr("sign this transaction")

            function buildDataObject(tx) { return {tx} }
            function getTxObjFromData(data) { return data.tx }
        }

        readonly property QtObject sendTransaction: QtObject {
            readonly property string name: "eth_sendTransaction"
            readonly property string userString: qsTr("transaction")
            readonly property string requestDisplay: qsTr("sign this transaction")

            function buildDataObject(tx) { return {tx}}
            function getTxObjFromData(data) { return data.tx }
        }
        readonly property var all: [personalSign, sign, signTypedData_v4, signTypedData, sendTransaction]
    }

    enum ErrorCode {
        NoError,
        InvalidAccount,
        InvalidChainId,
        InvalidData,
        InvalidMessage,
        InvalidMethod,
        UnsupportedMethod,
        InvalidRequest,
        RuntimeError,
        Ignored
    }
    /* 
    Function parsing the session request event
    Throws exception if the event is invalid
    returns { request: [Object], error: [ErrorCode] }
        request: {
            event,
            topic,
            requestId,
            method,
            account,
            chainId,
            data,
            preparedData,
            expiryTimestamp,
            transaction: {
                value,
                maxFeePerGas,
                maxPriorityFeePerGas,
                gasPrice,
                gasLimit,
                nonce
            }
        }
    */
    function parse(event, hexToDec) {
        if (!event) {
            console.warn("SessionRequest - parse - invalid event")
            return { request: null, error: SessionRequest.InvalidRequest }
        }
        if (!hexToDec) {
            hexToDec = (hex) => { return parseInt(hex, 16) }
        }
        let request = {}
        let error = SessionRequest.NoError

        request.event = event
        request.topic = event.topic
        request.requestId = event.id
        request.method = event.params.request.method
        if (!request.method) {
            console.warn("SessionRequest - build - invalid method")
            return { request: null, error: SessionRequest.InvalidMethod }
        }
        if (getSupportedMethods().includes(request.method) === false) {
            console.warn("Unsupported method:", request.method)
            return { request: null, error: SessionRequest.UnsupportedMethod }
        }
        const { accountAddress, success } = getAccountFromEvent(event)
        if (!accountAddress || !success) {
            console.warn("SessionRequest - build - failed to get account from event")
            return { request: null, error: SessionRequest.InvalidAccount }
        }
        request.account = accountAddress
        request.data = getData(event)
        if (!request.data) {
            console.warn("SessionRequest - build - failed to get data from event")
            return { request: null, error: SessionRequest.InvalidData }
        }
        const message = getMessage(event, hexToDec)
        if (!message || !message.signData) {
            console.warn("SessionRequest - build - failed to get message from event")
            return { request: null, error: SessionRequest.InvalidMessage }
        }
        request.preparedData = message.signData
        request.value = message.value
        request.transaction = message.transaction
        request.chainId = getChainId(event)
        if (!request.chainId) {
            console.warn("SessionRequest - build - failed to get chainId from event")
            return { request: null, error: SessionRequest.InvalidChainId }
        }
        request.expiryTimestamp = getExpiryDate(event)
        return { request, error}
    }

    function getSupportedMethods() {
        return methods.all.map(function(method) {
            return method.name
        })
    }

    function methodToUserString(method) {
        for (let i = 0; i < methods.all.length; i++) {
            if (methods.all[i].name === method) {
                return methods.all[i].userString
            }
        }
        return ""
    }

    /// returns {
    ///   accountAddress
    ///   success
    /// }
    /// if account is null and success is true it means that the account was not found
    function getAccountFromEvent(event) {
        const method = event.params.request.method
        let address = ""
        if (method === methods.personalSign.name) {
            if (event.params.request.params.length < 2) {
                return { accountAddress: "", success: false }
            }
            address = event.params.request.params[1]
        } else if (method === methods.sign.name) {
            if (event.params.request.params.length === 1) {
                return { accountAddress: "", success: false }
            }
            address = event.params.request.params[0]
        } else if(method === methods.signTypedData_v4.name ||
                    method === methods.signTypedData.name)
        {
            if (event.params.request.params.length < 2) {
                return { accountAddress: "", success: false }
            }
            address = event.params.request.params[0]
        } else if (isTransactionMethod(method)) {
            if (event.params.request.params.length == 0) {
                return { accountAddress: "", success: false }
            }
            address = event.params.request.params[0].from
        } else {
            console.error("Unsupported method to lookup account: ", method)
            return { accountAddress: "", success: false }
        }
        return { accountAddress: address, success: true }
    }

    function getChainId(event) {
        return DAppsHelpers.chainIdFromEip155(event.params.chainId)
    }

    function getData(event) {
        const method = event.params.request.method
        if (method === methods.personalSign.name ||
            method === methods.sign.name)
        {
            if (event.params.request.params.length < 1) {
                return null
            }
            let message = ""
            const messageIndex = (method === methods.personalSign.name ? 0 : 1)
            const messageParam = event.params.request.params[messageIndex]
            // There is no standard on how data is encoded. Therefore we support hex or utf8
            if (DAppsHelpers.isHex(messageParam)) {
                message = DAppsHelpers.hexToString(messageParam)
            } else {
                message = messageParam
            }
            return methods.personalSign.buildDataObject(message)
        } else if (method === methods.signTypedData_v4.name ||
                    method === methods.signTypedData.name)
        {
            if (event.params.request.params.length < 2) {
                return null
            }
            const jsonMessage = event.params.request.params[1]
            const methodObj = method === methods.signTypedData_v4.name
                    ? methods.signTypedData_v4
                    : methods.signTypedData
            return methodObj.buildDataObject(jsonMessage)
        } else if (method === methods.signTransaction.name) {
            if (event.params.request.params.length == 0) {
                return null
            }
            const tx = event.params.request.params[0]
            return methods.signTransaction.buildDataObject(tx)
        } else if (method === methods.sendTransaction.name) {
            if (event.params.request.params.length == 0) {
                return null
            }
            const tx = event.params.request.params[0]
            return methods.sendTransaction.buildDataObject(tx)
        } else {
            return null
        }
    }

    // returns {
    //   signData,
    //   transaction: {
    //     value,
    //     maxFeePerGas,
    //     maxPriorityFeePerGas,
    //     gasPrice,
    //     gasLimit,
    //     nonce
    //   },
    //   value // null or ETH Big number
    // }
    function getMessage(event, hexToDec) {
        const data = getData(event)
        const method = event.params.request.method
        return prepareData(method, data, hexToDec)
    }

    // returns {
    //   signData,
    //   transaction: {
    //     value,
    //     maxFeePerGas,
    //     maxPriorityFeePerGas,
    //     gasPrice,
    //     gasLimit,
    //     nonce
    //   },
    //   value // null or ETH Big number
    // }
    function prepareData(method, data, hexToDec) {
        let payload = null
        switch(method) {
            case methods.personalSign.name: {
                payload = methods.personalSign.getMessageFromData(data)
                break
            }
            case methods.sign.name: {
                payload = methods.sign.getMessageFromData(data)
                break
            }
            case methods.signTypedData_v4.name: {
                const stringPayload = methods.signTypedData_v4.getMessageFromData(data)
                payload = JSON.stringify(JSON.parse(stringPayload), null, 2)
                break
            }
            case methods.signTypedData.name: {
                const stringPayload = methods.signTypedData.getMessageFromData(data)
                payload = JSON.stringify(JSON.parse(stringPayload), null, 2)
                break
            }
            case methods.signTransaction.name:
            case methods.sendTransaction.name:
                // For transactions we process the data in a different way as follows
                break
            default:
                console.error("Unhandled method", method)
                break;
        }

        let value = SQUtils.AmountsArithmetic.fromNumber(0)
        let txObj = getTxObject(method, data)
        if (isTransactionMethod(method)) {
            payload = parseTransaction(txObj, hexToDec)
            if (payload.hasOwnProperty("value")) {
                value = payload.value
            }
        }
        return {
                signData: payload,
                transaction: txObj,
                value: value
            }
    }
    
    /// Parses the transaction object and converts the values to human readable format
    function parseTransaction(tx, hexToDec) {
        let parsedTransaction = Object.assign({}, tx)
        if (parsedTransaction.hasOwnProperty("value")) {
            parsedTransaction.value = hexToEth(parsedTransaction.value, hexToDec).toString()
        }
        if (parsedTransaction.hasOwnProperty("maxFeePerGas")) {
            parsedTransaction.maxFeePerGas = hexToGwei(parsedTransaction.maxFeePerGas, hexToDec).toString()
        }
        if (parsedTransaction.hasOwnProperty("maxPriorityFeePerGas")) {
            parsedTransaction.maxPriorityFeePerGas = hexToGwei(parsedTransaction.maxPriorityFeePerGas, hexToDec).toString()
        }
        if (parsedTransaction.hasOwnProperty("gasPrice")) {
            parsedTransaction.gasPrice = hexToGwei(parsedTransaction.gasPrice, hexToDec)
        }
        if (parsedTransaction.hasOwnProperty("gasLimit")) {
            parsedTransaction.gasLimit = parseInt(hexToDec(parsedTransaction.gasLimit))
        }
        if (parsedTransaction.hasOwnProperty("nonce")) {
            parsedTransaction.nonce = parseInt(hexToDec(parsedTransaction.nonce))
        }
        return parsedTransaction
    }

    function hexToEth(value, hexToDec) {
        return hexToEthDenomination(value, "eth", hexToDec)
    }
    function hexToGwei(value, hexToDec) {
        return hexToEthDenomination(value, "gwei", hexToDec)
    }
    function hexToEthDenomination(value, ethUnit, hexToDec) {
        let unitMapping = {
            "gwei": 9,
            "eth": 18
        }
        let BigOps = SQUtils.AmountsArithmetic
        let decValue = hexToDec(value)
        if (!!decValue) {
            return BigOps.div(BigOps.fromNumber(decValue), BigOps.fromNumber(1, unitMapping[ethUnit]))
        }
        return BigOps.fromNumber(0)
    }

    function getTxObject(method, data) {
        let tx
        if (method === methods.signTransaction.name) {
            tx = methods.signTransaction.getTxObjFromData(data)
        } else if (method === methods.sendTransaction.name) {
            tx = methods.sendTransaction.getTxObjFromData(data)
        }
        return tx
    }

    function isTransactionMethod(method) {
        return method === methods.signTransaction.name
            || method === methods.sendTransaction.name
    }

    function getExpiryDate(event) {
        return event.params.request.expiryTimestamp
    }
}