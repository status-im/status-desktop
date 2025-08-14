import QtQuick
import utils

QtObject {
    id: root

    property var privacyModule

    // Module Properties
    readonly property bool mnemonicBackedUp: privacyModule.mnemonicBackedUp
    readonly property string keyUid: userProfile.keyUid

    // The following properties wrap Privacy and Security View related properties:
    readonly property bool isStatusNewsViaRSSEnabled: appSettings.newsRSSEnabled

    function setNewsRSSEnabled(isStatusNewsViaRSSEnabled) {
        appSettings.newsRSSEnabled = isStatusNewsViaRSSEnabled
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
