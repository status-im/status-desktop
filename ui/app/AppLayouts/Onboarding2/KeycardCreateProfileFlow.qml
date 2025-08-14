import QtQuick

import AppLayouts.Onboarding2.pages
import AppLayouts.Onboarding.enums


OnboardingStackView {
    id: root

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

    initialItem: d.initialComponent()

    QtObject {
        id: d

        property bool withNewSeedphrase
        property string mnemonic
        property bool pinAlreadySet

        function initialComponent() {
            if (root.keycardState === Onboarding.KeycardState.Empty)
                return createKeycardProfilePage

            if (root.keycardState === Onboarding.KeycardState.NotEmpty)
                return keycardNotEmptyPage

            return keycardIntroPage
        }

        function handleCreatePINPage() {
            if (d.pinAlreadySet) { // skip the create PIN page and move forward
                if (d.withNewSeedphrase) {
                    root.push(backupSeedIntroPage)
                } else {
                    root.loadMnemonicRequested()
                    root.push(addKeypairPage)
                }
            } else {
                root.push(keycardCreatePinPage)
            }
        }
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            displayPromoBanner: root.displayKeycardPromoBanner
            factoryResetAvailable: true

            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onEmptyKeycardDetected: root.replace(createKeycardProfilePage)
            onNotEmptyKeycardDetected: root.replace(keycardNotEmptyPage)
        }
    }

    Component {
        id: createKeycardProfilePage

        CreateKeycardProfilePage {
            onCreateKeycardProfileWithNewSeedphrase: {
                d.withNewSeedphrase = true
                d.handleCreatePINPage()
            }
            onCreateKeycardProfileWithExistingSeedphrase: {
                d.withNewSeedphrase = false
                root.push(seedphrasePage)
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
            onBackupSeedphraseRequested: root.push(backupSeedRevealPage)
        }
    }

    Component {
        id: backupSeedRevealPage
        BackupSeedphraseReveal {
            Component.onCompleted: d.mnemonic = root.generateMnemonic()
            mnemonic: d.mnemonic

            onBackupSeedphraseConfirmed: {
                root.seedphraseSubmitted(d.mnemonic)
                root.push(backupSeedVerifyPage)
            }
        }
    }

    Component {
        id: backupSeedVerifyPage
        BackupSeedphraseVerify {
            mnemonic: d.mnemonic
            countToVerify: 4
            onBackupSeedphraseVerified: root.push(backupSeedOutroPage)
        }
    }

    Component {
        id: backupSeedOutroPage

        BackupSeedphraseOutro {
            onBackupSeedphraseRemovalConfirmed: {
                root.loadMnemonicRequested()
                root.push(addKeypairPage)
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
                d.handleCreatePINPage()
            }
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinDelayedPage {
            readonly property bool backAvailableHint: !success && !pinSettingInProgress

            pinSettingState: root.pinSettingState
            authorizationState: root.authorizationState
            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onSetPinRequested: (pin) => root.setPinRequested(pin)
            onAuthorizationRequested: root.authorizationRequested()

            onFinished: {
                d.pinAlreadySet = true
                if (d.withNewSeedphrase) {
                    root.replace(backupSeedIntroPage)
                } else {
                    root.loadMnemonicRequested()
                    root.push(addKeypairPage)
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
