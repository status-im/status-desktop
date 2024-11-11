import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

SQUtils.QObject {
    id: root

    required property var controller
    
    // Signals driven by the dApp
    signal connectRequested(string requestId, string dappJson)
    signal sendTransaction(string requestId, string requestJson)
    signal personalSign(string requestId, string dappJson)

    signal connected(string dappJson)
    signal disconnected(string dappJson)

    // Responses to user actions
    signal approveConnectResponse(string id, bool error)
    signal rejectConnectResponse(string id, bool error)

    signal approveTransactionResponse(string topic, string requestId, bool error)
    signal rejectTransactionResponse(string topic, string requestId, bool error)
    signal approvePersonalSignResponse(string topic, string requestId, bool error)
    signal rejectPersonalSignResponse(string topic, string requestId, bool error)

    function approveConnection(id, account, chainId) {
        return controller.approveConnection(id, account, chainId)
    }

    function rejectConnection(id, error) {
        return controller.rejectConnection(id, error)
    }

    function approveTransaction(topic, requestId, signature) {
        return controller.approveTransaction(topic, requestId, signature)
    }

    function rejectTransaction(topic, requestId, error) {
        return controller.rejectTransaction(topic, requestId, error)
    }

    function disconnect(id) {
        return controller.disconnect(id)
    }

    function getDApps() {
        return controller.getDApps()
    }

    function approvePersonalSign(topic, requestId, signature) {
        return controller.approvePersonalSigning(topic, requestId, signature)
    }

    function rejectPersonalSign(topic, requestId) {
        return controller.rejectPersonalSigning(topic, requestId)
    }

    Connections {
        target: controller

        function onConnectRequested(requestId, dappJson) {
            root.connectRequested(requestId, dappJson)
        }

        function onSendTransaction(requestId, requestJson) {
            root.sendTransaction(requestId, requestJson)
        }

        function onPersonalSign(requestId, dappJson) {
            root.personalSign(requestId, dappJson)
        }

        function onConnected(dappJson) {
            root.connected(dappJson)
        }

        function onDisconnected(dappJson) {
            root.disconnected(dappJson)
        }

        function onApproveConnectResponse(id, error) {
            root.approveConnectResponse(id, error)
        }

        function onRejectConnectResponse(id, error) {
            root.rejectConnectResponse(id, error)
        }

        function onApproveTransactionResponse(topic, requestId, error) {
            root.approveTransactionResponse(topic, requestId, error)
        }

        function onRejectTransactionResponse(topic, requestId, error) {
            root.rejectTransactionResponse(topic, requestId, error)
        }

        function onApprovePersonalSignResponse(topic, requestId, error) {
            root.approvePersonalSignResponse(topic, requestId, error)
        }

        function onRejectPersonalSignResponse(topic, requestId, error) {
            root.rejectPersonalSignResponse(topic, requestId, error)
        }
    }
}