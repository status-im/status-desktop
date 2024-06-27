import QtQuick 2.15

import StatusQ.Core.Utils 0.1

QObject {
    id: root

    required property var controller

    /// \c dappsJson serialized from status-go.wallet.GetDapps
    signal dappsListReceived(string dappsJson)
    signal userAuthenticated(string topic, string id, string password, string pin)
    signal userAuthenticationFailed(string topic, string id)

    function addWalletConnectSession(sessionJson) {
        return controller.addWalletConnectSession(sessionJson)
    }

    function deactivateWalletConnectSession(topic) {
        return controller.deactivateWalletConnectSession(topic)
    }

    function updateWalletConnectSessions(activeTopicsJson) {
        return controller.updateSessionsMarkedAsActive(activeTopicsJson)
    }

    function authenticateUser(topic, id, address) {
        let ok = controller.authenticateUser(topic, id, address)
        if(!ok) {
            root.userAuthenticationFailed()
        }
    }

    // Returns the hex encoded signature of the message or empty string if error
    function signMessage(topic, id, address, password, message) {
        return controller.signMessage(address, password, message)
    }

    // Returns the hex encoded signature of the typedDataJson or empty string if error
    function signTypedDataV4(topic, id, address, password, typedDataJson) {
        return controller.signTypedDataV4(address, password, typedDataJson)
    }

    // Remove leading zeros from hex number as expected by status-go
    function stripLeadingZeros(hexNumber) {
        let fixed = hexNumber.replace(/^0x0*/, '0x')
        return fixed == '0x' ? '0x0' : fixed;
    }

    // Strip leading zeros from numbers as expected by status-go
    function prepareTxForStatusGo(txObj) {
        let tx = {}
        if (txObj.data) { tx.data = txObj.data }
        if (txObj.from) { tx.from = txObj.from }
        if (txObj.gasLimit) { tx.gasLimit = stripLeadingZeros(txObj.gasLimit) }
        if (txObj.gasPrice) { tx.gasPrice = stripLeadingZeros(txObj.gasPrice) }
        if (txObj.nonce) { tx.nonce = stripLeadingZeros(txObj.nonce) }
        if (txObj.to) { tx.to = txObj.to }
        if (txObj.value) { tx.value = stripLeadingZeros(txObj.value) }
        return tx
    }
    // Returns the hex encoded signature of the transaction or empty string if error
    function signTransaction(topic, id, address, chainId, password, txObj) {
        let tx = prepareTxForStatusGo(txObj)
        return controller.signTransaction(address, chainId, password, JSON.stringify(tx))
    }

    // Returns the hash of the transaction or empty string if error
    function sendTransaction(topic, id, address, chainId, password, txObj) {
        let tx = prepareTxForStatusGo(txObj)
        return controller.sendTransaction(address, chainId, password, JSON.stringify(tx))
    }

    /// \c getDapps triggers an async response to \c dappsListReceived
    function getDapps() {
        return controller.getDapps()
    }

    // Handle async response from controller
    Connections {
        target: controller

        function onDappsListReceived(dappsJson) {
            root.dappsListReceived(dappsJson)
        }

        function onUserAuthenticationResult(topic, id, success, password, pin) {
            if (success) {
                root.userAuthenticated(topic, id, password, pin)
            } else {
                root.userAuthenticationFailed(topic, id)
            }
        }
    }
}