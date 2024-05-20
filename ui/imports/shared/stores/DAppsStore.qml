import QtQuick 2.15

QtObject {
    required property var module

    function addWalletConnectSession(sessionJson) {
        module.addWalletConnectSession(sessionJson)
    }
}