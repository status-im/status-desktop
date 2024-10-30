import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

SQUtils.QObject {
    id: root

    required property var controller
    
    // Signals driven by the dApp
    signal connectRequested(string requestId, string dappJson)
    signal signRequested(string requestId, string requestJson)

    signal connected(string dappJson)
    signal disconnected(string dappJson)

    // Responses to user actions
    signal approveConnectResponse(string id, bool error)
    signal rejectConnectResponse(string id, bool error)

    signal approveTransactionResponse(string requestId, bool error)
    signal rejectTransactionResponse(string requestId, bool error)

    function approveConnection(id, account, chainId) {
        return controller.approveConnection(id, account, chainId)
    }

    function rejectConnection(id, error) {
        return controller.rejectConnection(id, error)
    }

    function approveTransaction(requestId, signature) {
        return controller.approveTransaction(requestId, signature)
    }

    function rejectTransaction(requestId, error) {
        return controller.rejectTransaction(requestId, error)
    }

    function disconnect(id) {
        return controller.disconnect(id)
    }

    function getDApps() {
        return controller.getDApps()
    }

    Connections {
        target: controller

        function onConnectRequested(requestId, dappJson) {
            root.connectRequested(requestId, dappJson)
        }

        function onSignRequested(requestId, requestJson) {
            root.signRequested(requestId, requestJson)
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

        function onApproveTransactionResponse(requestId, error) {
            root.approveTransactionResponse(requestId, error)
        }

        function onRejectTransactionResponse(requestId, error) {
            root.rejectTransactionResponse(requestId, error)
        }
    }
}