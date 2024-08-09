import QtQuick 2.15

import StatusQ.Core.Utils 0.1

QObject {
    id: root

    required property var controller
    /// \c dappsJson serialized from status-go.wallet.GetDapps
    signal dappsListReceived(string dappsJson)
    signal activeSessionsReceived(var activeSessionsJsonObj, bool success)
    signal userAuthenticated(string topic, string id, string password, string pin, string payload)
    signal userAuthenticationFailed(string topic, string id)

    signal signingResult(string topic, string id, string data)

    function addWalletConnectSession(sessionJson) {
        return controller.addWalletConnectSession(sessionJson)
    }

    function deactivateWalletConnectSession(topic) {
        return controller.deactivateWalletConnectSession(topic)
    }

    function updateWalletConnectSessions(activeTopicsJson) {
        return controller.updateSessionsMarkedAsActive(activeTopicsJson)
    }

    function authenticateUser(topic, id, address, payload) {
        let ok = controller.authenticateUser(topic, id, address, payload)
        if(!ok) {
            root.userAuthenticationFailed()
        }
    }

    function signMessageUnsafe(topic, id, address, message, password, pin = "") {
        controller.signMessageUnsafe(topic, id, address, message, password, pin)
    }

    function signMessage(topic, id, address, message, password, pin = "") {
        controller.signMessage(topic, id, address, message, password, pin)
    }

    function safeSignTypedData(topic, id, address, typedDataJson, chainId, legacy, password, pin = "") {
        controller.safeSignTypedData(topic, id, address, typedDataJson, chainId, legacy, password, pin)
    }

    // Remove leading zeros from hex number as expected by status-go
    function stripLeadingZeros(hexNumber) {
        let fixed = hexNumber.replace(/^0x0*/, '0x')
        return fixed == '0x' ? '0x0' : fixed;
    }

    // Strip leading zeros from numbers as expected by status-go
    function prepareTxForStatusGo(txObj) {
        let tx = Object.assign({}, txObj)
        if (txObj.gasLimit) {
            tx.gasLimit = stripLeadingZeros(txObj.gasLimit)
        }
        if (txObj.gas) {
            tx.gas = stripLeadingZeros(txObj.gas)
        }
        if (txObj.gasPrice) {
            tx.gasPrice = stripLeadingZeros(txObj.gasPrice)
        }
        if (txObj.nonce) {
            tx.nonce = stripLeadingZeros(txObj.nonce)
        }
        if (txObj.maxFeePerGas) {
            tx.maxFeePerGas = stripLeadingZeros(txObj.maxFeePerGas)
        }
        if (txObj.maxPriorityFeePerGas) {
            tx.maxPriorityFeePerGas = stripLeadingZeros(txObj.maxPriorityFeePerGas)
        }
        if (txObj.value) {
            tx.value = stripLeadingZeros(txObj.value)
        }
        return tx
    }

    // Empty maxFeePerGas will fetch the current chain's maxFeePerGas
    // Returns ui/imports/utils -> Constants.TransactionEstimatedTime values
    function getEstimatedTime(chainId, maxFeePerGasHex) {
        return controller.getEstimatedTime(chainId, maxFeePerGasHex)
    }

    // Returns nim's SuggestedFeesDto; see src/app_service/service/transaction/dto.nim
    // Returns all value initialized to 0 if error
    function getSuggestedFees(chainId) {
        return JSON.parse(controller.getSuggestedFeesJson(chainId))
    }

    function signTransaction(topic, id, address, chainId, password, txObj) {
        let tx = prepareTxForStatusGo(txObj)
        controller.signTransaction(topic, id, address, chainId, JSON.stringify(tx), password, pin)
    }

    function sendTransaction(topic, id, address, chainId, txObj, password, pin = "") {
        let tx = prepareTxForStatusGo(txObj)
        controller.sendTransaction(topic, id, address, chainId, JSON.stringify(tx), password, pin)
    }

    /// \c getDapps triggers an async response to \c dappsListReceived
    function getDapps() {
        return controller.getDapps()
    }
    
    /// \c getActiveSessions triggers an async response to \c activeSessionsReceived
    /// \returns true if the request was sent successfully
    function getActiveSessions() {
        return controller.getActiveSessions()
    }

    function hexToDec(hex) {
        return controller.hexToDecBigString(hex)
    }

    // Return just the modified fields { "maxFeePerGas": "0x<...>", "maxPriorityFeePerGas": "0x<...>" }
    function convertFeesInfoToHex(feesInfoJson) {
        return controller.convertFeesInfoToHex(feesInfoJson)
    }

    // Handle async response from controller
    Connections {
        target: controller

        function onDappsListReceived(dappsJson) {
            root.dappsListReceived(dappsJson)
        }

        function onActiveSessionsReceived(activeSessionsJson) {
            try {
                const jsonObj = JSON.parse(activeSessionsJson)
                root.activeSessionsReceived(jsonObj, true)
            } catch (e) {
                console.error("Failed to parse activeSessionsJson", e)
                root.activeSessionsReceived({}, false)
                return
            }
        }

        function onUserAuthenticationResult(topic, id, success, password, pin, payload) {
            if (success) {
                root.userAuthenticated(topic, id, password, pin, payload)
            } else {
                root.userAuthenticationFailed(topic, id)
            }
        }

        function onSigningResultReceived(topic, id, data) {
            root.signingResult(topic, id, data)
        }
    }
}
