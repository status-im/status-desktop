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

    function runUnlockKeycardPopup() {
        root.keycardModule.runUnlockKeycardPopup()
    }

    function runDisplayKeycardContentPopup() {
        root.keycardModule.runDisplayKeycardContentPopup()
    }

    function runFactoryResetPopup() {
        root.keycardModule.runFactoryResetPopup()
    }
}
