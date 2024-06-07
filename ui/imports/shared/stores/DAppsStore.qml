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