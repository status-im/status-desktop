import QtQuick 2.13
import utils 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

StatusQUtils.QObject {
    id: root

    // **
    // ** Public API for UI region:
    // **

    readonly property var mailservers: d.syncModule.model
    readonly property var wakunodes: d.wakuModule.model
    readonly property bool useMailservers: d.syncModule.useMailservers

    // Privacy module related
    readonly property bool messagesFromContactsOnly: d.privacyModule.messagesFromContactsOnly
    readonly property int urlUnfurlingMode: d.privacyModule.urlUnfurlingMode

    // Module Properties
    readonly property bool automaticMailserverSelection: d.syncModule.automaticSelection
    readonly property string activeMailserverId: d.syncModule.activeMailserverId
    readonly property string pinnedMailserverId: d.syncModule.pinnedMailserverId

    function toggleUseMailservers(value) {
        d.syncModule.useMailservers = value
    }

    function setPinnedMailserverId(mailserverID) {
        d.syncModule.setPinnedMailserverId(mailserverID)
    }

    function saveNewMailserver(name, nodeAddress) {
        d.syncModule.saveNewMailserver(name, nodeAddress)
    }

    function saveNewWakuNode(nodeAddress) {
        d.wakuModule.saveNewWakuNode(nodeAddress)
    }

    function enableAutomaticMailserverSelection(checked) {
        if (automaticMailserverSelection === checked) {
            return
        }
        d.syncModule.enableAutomaticSelection(checked)
    }

    function setMessagesFromContactsOnly(value) {
        d.privacyModule.messagesFromContactsOnly = value
    }

    function setUrlUnfurlingMode(value) {
        d.privacyModule.urlUnfurlingMode = value
    }

    // **
    // ** Stores' internal API region:
    // **

    QtObject {
        id: d
        readonly property var profileSectionModuleInst: profileSectionModule
        readonly property var privacyModule: d.profileSectionModuleInst.privacyModule
        readonly property var syncModule: d.profileSectionModuleInst.syncModule
        readonly property var wakuModule: d.profileSectionModuleInst.wakuModule
    }
}
