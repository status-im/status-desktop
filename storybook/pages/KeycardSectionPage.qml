import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        KeycardView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            keycardStore: KeycardStore {
                property var keycardModule: QtObject {
                    property var keycardModel: ListModel {
                        ListElement {
                            keycardUid: "123"
                            name: "my keycard name"
                            locked: true
                            pairType: 0
                            icon: "data:image/jpeg;base64,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"
                            image: "data:image/jpeg;base64,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"
                            accounts: []
                        }
                    }

                    signal displayKeycardSharedModuleFlow()
                    signal destroyKeycardSharedModuleFlow()
                    signal keycardUidChanged()
                    signal keycardProfileChanged()
                    signal keycardDetailsChanged()
                }

                function runSetupKeycardPopup() {
                    logs.logEvent("keycardStore::runSetupKeycardPopup")
                }

                function runGenerateSeedPhrasePopup() {
                    logs.logEvent("keycardStore::runGenerateSeedPhrasePopup")
                }

                function runImportOrRestoreViaSeedPhrasePopup() {
                    logs.logEvent("keycardStore::runImportOrRestoreViaSeedPhrasePopup")
                }

                function runImportFromKeycardToAppPopup() {
                    logs.logEvent("keycardStore::runImportFromKeycardToAppPopup")
                }

                function runUnlockKeycardPopupForKeycardWithUid(keycardUid) {
                    logs.logEvent("keycardStore::runUnlockKeycardPopupForKeycardWithUid")
                }

                function runDisplayKeycardContentPopup() {
                    logs.logEvent("keycardStore::runDisplayKeycardContentPopup")
                }

                function runFactoryResetPopup() {
                    logs.logEvent("keycardStore::runFactoryResetPopup")
                }

                function runRenameKeycardPopup(keycardUid, keyUid) {
                    logs.logEvent("keycardStore::runRenameKeycardPopup")
                }

                function runChangePinPopup() {
                    logs.logEvent("keycardStore::runChangePinPopup")
                }

                function runCreateBackupCopyOfAKeycardPopup() {
                    logs.logEvent("keycardStore::runCreateBackupCopyOfAKeycardPopup")
                }

                function runCreatePukPopup() {
                    logs.logEvent("store::runCreatePukPopup")
                }

                function runCreateNewPairingCodePopup() {
                    logs.logEvent("store::runCreateNewPairingCodePopup")
                }

                function getKeycardDetailsAsJson(keycardUid) {
                    logs.logEvent("store::getKeycardDetailsAsJson", ["keycardUid"], arguments)
                    return JSON.stringify({
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
                    })
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        // model editor will go here
    }
}


