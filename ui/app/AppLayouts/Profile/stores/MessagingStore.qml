import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var privacyModule
    property var syncModule
    property var wakuModule

    property var mailservers: !!root.syncModule? root.syncModule.model : null
    property var wakunodes: !!root.wakuModule? root.wakuModule.model : null

    property bool useMailservers: !!root.syncModule? root.syncModule.useMailservers : false

    function toggleUseMailservers(value) {
        root.syncModule.useMailservers = value
    }

    // Module Properties
    property bool automaticMailserverSelection: !!root.syncModule? root.syncModule.automaticSelection : false
    property string activeMailserver: !!root.syncModule? root.syncModule.activeMailserver : ""

    function getMailserverNameForNodeAddress(nodeAddress) {
        return root.syncModule.getMailserverNameForNodeAddress(nodeAddress)
    }

    function setActiveMailserver(mailserverID) {
        root.syncModule.setActiveMailserver(mailserverID)
    }

    function saveNewMailserver(name, nodeAddress) {
        root.syncModule.saveNewMailserver(name, nodeAddress)
    }

    function saveNewWakuNode(nodeAddress) {
        root.wakuModule.saveNewWakuNode(nodeAddress)
    }

    function enableAutomaticMailserverSelection(checked) {
        if (automaticMailserverSelection === checked) {
            return
        }
        root.syncModule.enableAutomaticSelection(checked)
    }
}
