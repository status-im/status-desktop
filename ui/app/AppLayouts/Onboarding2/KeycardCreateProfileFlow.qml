import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

import utils 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property int keycardState
    required property int pinSettingState
    required property int authorizationState
    required property int addKeyPairState
    required property int keycardPinInfoPageDelay

    required property var generateMnemonic
    required property var isSeedPhraseValid

    property bool displayKeycardPromoBanner

    signal loginWithKeycardRequested
    signal keycardFactoryResetRequested
    signal loadMnemonicRequested
    signal setPinRequested(string pin)
    signal seedphraseSubmitted(string seedphrase)

    signal authorizationRequested

    signal finished(bool withNewSeedphrase)

    function init() {
        root.stackView.push(d.initialComponent())
    }

    QtObject {
        id: d

        property bool withNewSeedphrase
        property string mnemonic

        function initialComponent() {
            if (root.keycardState === Onboarding.KeycardState.Empty)
                return createKeycardProfilePage

            if (root.keycardState === Onboarding.KeycardState.NotEmpty)
                return keycardNotEmptyPage

            return keycardIntroPage
        }
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            displayPromoBanner: root.displayKeycardPromoBanner
            factoryResetAvailable: true

            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onEmptyKeycardDetected: root.stackView.replace(createKeycardProfilePage)
            onNotEmptyKeycardDetected: root.stackView.replace(keycardNotEmptyPage)
        }
    }

    Component {
        id: createKeycardProfilePage

        CreateKeycardProfilePage {
            onCreateKeycardProfileWithNewSeedphrase: {
                d.withNewSeedphrase = true
                root.stackView.push(keycardCreatePinPage)
            }
            onCreateKeycardProfileWithExistingSeedphrase: {
                d.withNewSeedphrase = false
                root.stackView.push(seedphrasePage)
            }
        }
    }

    Component {
        id: keycardNotEmptyPage

        KeycardNotEmptyPage {
            onLoginWithThisKeycardRequested: root.loginWithKeycardRequested()
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
        }
    }

    Component {
        id: backupSeedIntroPage

        BackupSeedphraseIntro {
            onBackupSeedphraseRequested: root.stackView.push(backupSeedAcksPage)
        }
    }

    Component {
        id: backupSeedAcksPage

        BackupSeedphraseAcks {
            onBackupSeedphraseContinue: root.stackView.push(backupSeedRevealPage)
        }
    }

    Component {
        id: backupSeedRevealPage
        BackupSeedphraseReveal {
            Component.onCompleted: d.mnemonic = root.generateMnemonic()
            mnemonic: d.mnemonic

            onBackupSeedphraseConfirmed: {
                root.seedphraseSubmitted(d.mnemonic)
                root.stackView.push(backupSeedVerifyPage)
            }
        }
    }

    Component {
        id: backupSeedVerifyPage
        BackupSeedphraseVerify {
            mnemonic: d.mnemonic
            countToVerify: 4
            onBackupSeedphraseVerified: root.stackView.push(backupSeedOutroPage)
        }
    }

    Component {
        id: backupSeedOutroPage

        BackupSeedphraseOutro {
            onBackupSeedphraseRemovalConfirmed: {
                root.loadMnemonicRequested()
                root.stackView.push(addKeypairPage)
            }
        }
    }

    Component {
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Create profile on empty Keycard using a recovery phrase")

            isSeedPhraseValid: root.isSeedPhraseValid
            onSeedphraseSubmitted: (seedphrase) => {
                root.seedphraseSubmitted(seedphrase)
                root.stackView.push(keycardCreatePinPage)
            }
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinDelayedPage {
            readonly property bool backAvailableHint: !success && !pinSettingInProgress

            pinSettingState: root.pinSettingState
            authorizationState: root.authorizationState

            onSetPinRequested: (pin) => root.setPinRequested(pin)
            onAuthorizationRequested: root.authorizationRequested()

            onFinished: {
                if (d.withNewSeedphrase) {
                    root.stackView.replace(backupSeedIntroPage)
                } else {
                    root.loadMnemonicRequested()
                    root.stackView.push(addKeypairPage)
                }
            }
        }
    }

    Component {
        id: addKeypairPage

        KeycardAddKeyPairDelayedPage {
            readonly property bool backAvailableHint: false

            addKeyPairState: root.addKeyPairState

            onFinished: root.finished(d.withNewSeedphrase)
        }
    }
}
