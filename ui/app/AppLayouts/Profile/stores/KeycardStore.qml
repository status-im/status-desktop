import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var keycardModule

    function runSetupKeycardPopup() {
        root.keycardModule.runSetupKeycardPopup()
    }

    function runGenerateSeedPhrasePopup() {
        root.keycardModule.runGenerateSeedPhrasePopup()
    }

    function runImportOrRestoreViaSeedPhrasePopup() {
        root.keycardModule.runImportOrRestoreViaSeedPhrasePopup()
    }

    function runImportFromKeycardToAppPopup() {
        root.keycardModule.runImportFromKeycardToAppPopup()
    }

    function runUnlockKeycardPopupForKeycardWithUid(keycardUid) {
        root.keycardModule.runUnlockKeycardPopupForKeycardWithUid(keycardUid)
    }

    function runDisplayKeycardContentPopup() {
        root.keycardModule.runDisplayKeycardContentPopup()
    }

    function runFactoryResetPopup() {
        root.keycardModule.runFactoryResetPopup()
    }

    function runRenameKeycardPopup() {
        root.keycardModule.runRenameKeycardPopup()
    }

    function runChangePinPopup() {
        root.keycardModule.runChangePinPopup()
    }

    function runCreateBackupCopyOfAKeycardPopup() {
        root.keycardModule.runCreateBackupCopyOfAKeycardPopup()
    }

    function runCreatePukPopup() {
        root.keycardModule.runCreatePukPopup()
    }

    function runCreateNewPairingCodePopup() {
        root.keycardModule.runCreateNewPairingCodePopup()
    }

    function getKeycardDetailsAsJson(keycardUid) {
        let jsonObj = root.keycardModule.getKeycardDetailsAsJson(keycardUid)
        try {
            let obj = JSON.parse(jsonObj)
            return obj
        }
        catch (e) {
            console.debug("error parsing keycard details for keycard uid: ", keycardUid, " error: ", e.message)
            return {
                keycardUid: keycardUid,
                pubKey: "",
                keyUid: "",
                locked: false,
                name: "",
                image: "",
                icon: "",
                pairType: Constants.keycard.keyPairType.unknown,
                derivedFrom: "",
                accounts: [],
            }
        }
    }
}
