import QtQuick
import utils

QtObject {
    id: root

    property var keycardModule

    function runSetupKeycardPopup(keyUid) {
        root.keycardModule.runSetupKeycardPopup(keyUid)
    }

    function runStopUsingKeycardPopup(keyUid) {
        root.keycardModule.runStopUsingKeycardPopup(keyUid)
    }

    function runCreateNewKeycardWithNewSeedPhrasePopup() {
        root.keycardModule.runCreateNewKeycardWithNewSeedPhrasePopup()
    }

    function runImportOrRestoreViaSeedPhrasePopup() {
        root.keycardModule.runImportOrRestoreViaSeedPhrasePopup()
    }

    function runImportFromKeycardToAppPopup() {
        root.keycardModule.runImportFromKeycardToAppPopup()
    }

    function runUnlockKeycardPopupForKeycardWithUid(keyUid) {
        root.keycardModule.runUnlockKeycardPopupForKeycardWithUid(keyUid)
    }

    function runDisplayKeycardContentPopup() {
        root.keycardModule.runDisplayKeycardContentPopup()
    }

    function runFactoryResetPopup() {
        root.keycardModule.runFactoryResetPopup()
    }

    function runRenameKeycardPopup(keyUid) {
        root.keycardModule.runRenameKeycardPopup(keyUid)
    }

    function runChangePinPopup(keyUid) {
        root.keycardModule.runChangePinPopup(keyUid)
    }

    function runCreateBackupCopyOfAKeycardPopup(keyUid) {
        root.keycardModule.runCreateBackupCopyOfAKeycardPopup(keyUid)
    }

    function runCreatePukPopup(keyUid) {
        root.keycardModule.runCreatePukPopup(keyUid)
    }

    function runCreateNewPairingCodePopup(keyUid) {
        root.keycardModule.runCreateNewPairingCodePopup(keyUid)
    }

    function prepareKeycardDetailsModel(keyUid) {
        root.keycardModule.prepareKeycardDetailsModel(keyUid)
    }

    function remainingKeypairCapacity() {
        return root.keycardModule.remainingKeypairCapacity()
    }

    function remainingAccountCapacity() {
        return root.keycardModule.remainingAccountCapacity()
    }
}
