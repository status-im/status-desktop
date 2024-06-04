import QtQuick 2.15

import StatusQ.Core.Utils 0.1

QObject {
    id: root

    required property var controller

    /// \c dappsJson serialized from status-go.wallet.GetDapps
    signal dappsListReceived(string dappsJson)
    signal userAuthenticated(string topic, string id)
    signal userAuthenticationFailed(string topic, string id)
    signal sessionRequestExecuted(var payload, bool success)

    function addWalletConnectSession(sessionJson) {
        controller.addWalletConnectSession(sessionJson)
    }

    function authenticateUser(topic, id, address) {
        let ok = controller.authenticateUser(topic, id, address)
        if(!ok) {
            root.userAuthenticationFailed()
        }
    }

    function signMessage(message) {
        // TODO #14927 implement me
        root.sessionRequestExecuted(message, true)
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

        function onUserAuthenticationResult(topic, id, success) {
            if (success) {
                root.userAuthenticated(topic, id)
            } else {
                root.userAuthenticationFailed(topic, id)
            }
        }
    }
}