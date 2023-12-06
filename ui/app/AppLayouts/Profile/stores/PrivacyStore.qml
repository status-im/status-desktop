import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var privacyModule

    // Module Properties
    property bool mnemonicBackedUp: privacyModule.mnemonicBackedUp

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

    function validatePassword(password) {
        return root.privacyModule.validatePassword(password)
    }

    function tryStoreToKeyChain() {
        root.privacyModule.tryStoreToKeyChain()
    }

    function tryRemoveFromKeyChain() {
        root.privacyModule.tryRemoveFromKeyChain()
    }

    function backupData() {
        return root.privacyModule.backupData()
    }

    function mnemonicWasShown() {
        root.privacyModule.mnemonicWasShown()
    }
}
