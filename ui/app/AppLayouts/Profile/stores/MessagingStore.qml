import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var privacyModule
    property var syncModule

    property int profilePicturesVisibility: privacyModule.profilePicturesVisibility
    property int profilePicturesShowTo: privacyModule.profilePicturesShowTo

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

    function setActiveMailserver(nodeAddress) {
        root.syncModule.setActiveMailserver(nodeAddress)
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

    function setProfilePicturesVisibility(value) {
        return root.privacyModule.setProfilePicturesVisibility(value)
    }

    function setProfilePicturesShowTo(value) {
        return root.privacyModule.setProfilePicturesShowTo(value)
    }
}
