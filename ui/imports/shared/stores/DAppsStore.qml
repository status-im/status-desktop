import QtQuick 2.15

QtObject {
    id: root

    required property var controller

    /// \c dappsJson serialized from status-go.wallet.GetDapps
    signal dappsListReceived(string dappsJson)

    function addWalletConnectSession(sessionJson) {
        controller.addWalletConnectSession(sessionJson)
    }

    /// \c getDapps triggers an async response to \c dappsListReceived
    function getDapps() {
        return controller.getDapps()
    }

    // Handle async response from controller
    property Connections _connections: Connections {
        target: controller

        function onDappsListReceived(dappsJson) {
            root.dappsListReceived(dappsJson)
        }
    }
}