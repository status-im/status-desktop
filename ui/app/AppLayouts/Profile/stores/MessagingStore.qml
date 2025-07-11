import QtQuick
import utils

QtObject {
    id: root

    property var privacyModule
    property var syncModule
    property var wakuModule

    property var mailservers: syncModule.model
    property var wakunodes: wakuModule.model

    property bool useMailservers: syncModule.useMailservers

    function toggleUseMailservers(value) {
        root.syncModule.useMailservers = value
    }

    // Module Properties
    property bool automaticMailserverSelection: syncModule.automaticSelection
    property string activeMailserverId: syncModule.activeMailserverId
    property string pinnedMailserverId: syncModule.pinnedMailserverId


    function setPinnedMailserverId(mailserverID) {
        root.syncModule.setPinnedMailserverId(mailserverID)
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
