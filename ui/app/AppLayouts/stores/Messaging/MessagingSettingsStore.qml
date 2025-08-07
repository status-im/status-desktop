import QtQuick 2.13
import utils 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

StatusQUtils.QObject {
    id: root

    // **
    // ** Public API for UI region:
    // **

    readonly property var mailservers: d.syncModule.model
    readonly property string activeMailserverId: d.wakuModule.activeMailserver
    readonly property bool useMailservers: d.syncModule.useMailservers

    // Privacy module related
    readonly property bool messagesFromContactsOnly: d.privacyModule.messagesFromContactsOnly
    readonly property int urlUnfurlingMode: d.privacyModule.urlUnfurlingMode

    function toggleUseMailservers(value) {
        d.syncModule.useMailservers = value
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
