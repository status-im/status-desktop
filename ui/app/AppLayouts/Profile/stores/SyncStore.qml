import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var syncModule

    property var mailservers: syncModule.model

    // Module Properties
    property bool automaticMailserverSelection: syncModule.automaticSelection
    property string activeMailserver: syncModule.activeMailserver

    function getMailserverNameForNodeAddress(nodeAddress) {
        return root.syncModule.getMailserverNameForNodeAddress(nodeAddress)
    }

    function setActiveMailserver(nodeAddress) {
        root.syncModule.setActiveMailserver(nodeAddress)
    }

    function saveNewMailserver(name, nodeAddress) {
        root.syncModule.saveNewMailserver(name, nodeAddress)
    }

    function enableAutomaticMailserverSelection(checked) {
        root.syncModule.enableAutomaticSelection(checked)
    }
}
