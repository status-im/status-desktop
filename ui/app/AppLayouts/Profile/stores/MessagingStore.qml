import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var privacyModule
    property var syncModule

    property var mailservers: syncModule.model

    property bool useMailservers: syncModule.useMailservers

    function toggleUseMailservers(value) {
        root.syncModule.useMailservers = value
    }

    // Module Properties
    property bool automaticMailserverSelection: syncModule.automaticSelection
    property string activeMailserver: syncModule.activeMailserver

    function getMailserverNameForNodeAddress(nodeAddress) {
        return root.syncModule.getMailserverNameForNodeAddress(nodeAddress)
    }

    function setActiveMailserver(mailserverID) {
        root.syncModule.setActiveMailserver(mailserverID)
    }

    function saveNewMailserver(name, nodeAddress) {
        root.syncModule.saveNewMailserver(name, nodeAddress)
    }

    function enableAutomaticMailserverSelection(checked) {
        if (automaticMailserverSelection === checked) {
            return
        }
        root.syncModule.enableAutomaticSelection(checked)
    }

    function getLinkPreviewWhitelist() {
        return root.privacyModule.getLinkPreviewWhitelist()
    }
}
