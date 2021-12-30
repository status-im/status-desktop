import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var privacyModule

    // Module Properties
    property bool mnemonicBackedUp: privacyModule.mnemonicBackedUp
    property bool messagesFromContactsOnly: privacyModule.messagesFromContactsOnly

    function getLinkPreviewWhitelist() {
        return root.privacyModule.getLinkPreviewWhitelist()
    }

    function changePassword(password, newPassword) {
        root.privacyModule.changePassword(password, newPassword)
    }

    function getMnemonic() {
        return root.privacyModule.getMnemonic()
    }

    function removeMnemonic() {
        root.privacyModule.removeMnemonic()
    }

    function getMnemonicWordAtIndex(index) {
        return root.privacyModule.getMnemonicWordAtIndex(index)
    }
}
