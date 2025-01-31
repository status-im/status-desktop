import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property int keycardState
    required property int pinSettingState
    required property int authorizationState
    required property int addKeyPairState
    required property int keycardPinInfoPageDelay

    required property var getSeedWords
    required property var isSeedPhraseValid

    property bool displayKeycardPromoBanner

    signal loginWithKeycardRequested
    signal keycardFactoryResetRequested
    signal loadMnemonicRequested
    signal keycardPinCreated(string pin)
    signal seedphraseSubmitted(string seedphrase)

    signal keypairAddTryAgainRequested
    signal reloadKeycardRequested
    signal createProfileWithoutKeycardRequested
    signal authorizationRequested

    signal finished(bool withNewSeedphrase)

    function init() {
        root.stackView.push(d.initialComponent())
    }

    QtObject {
        id: d

        property bool withNewSeedphrase
        property var seedWords

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

            onReloadKeycardRequested: {
                root.reloadKeycardRequested()
                root.stackView.replace(d.initialComponent(),
                                       StackView.PopTransition)
            }

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
                root.stackView.push(keycardCreatePinPage)
            }
        }
    }

    Component {
        id: keycardNotEmptyPage

        KeycardNotEmptyPage {
            onReloadKeycardRequested: {
                root.reloadKeycardRequested()
                root.stackView.replace(d.initialComponent(),
                                       StackView.PopTransition)
            }

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
            Component.onCompleted: {
                try {
                    const seedwords = root.getSeedWords()
                    d.seedWords = JSON.parse(seedwords)
                    root.seedphraseSubmitted(d.seedWords)
                } catch (e) {
                    console.error('Failed to get seedwords', e)
                }
            }
            seedWords: d.seedWords

            onBackupSeedphraseConfirmed: root.stackView.push(backupSeedVerifyPage)
        }
    }

    Component {
        id: backupSeedVerifyPage
        BackupSeedphraseVerify {
            seedWordsToVerify: {
                const randomIndexes = SQUtils.Utils.nSamples(4, d.seedWords.length)
                return randomIndexes.map(i => ({ seedWordNumber: i+1,
                                                 seedWord: d.seedWords[i]
                                               }))
            }

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
            id: seedphrasePage
            title: qsTr("Create profile on empty Keycard using a recovery phrase")

            authorizationState: root.authorizationState
            isSeedPhraseValid: root.isSeedPhraseValid
            onSeedphraseSubmitted: (seedphrase) => {
                root.seedphraseSubmitted(seedphrase)
                root.authorizationRequested()
            }
            onKeycardAuthorized: {
                if (!d.withNewSeedphrase) {
                    root.loadMnemonicRequested()
                    root.stackView.push(addKeypairPage)
                }
            }
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinPage {
            id: createPinPage

            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay
            pinSettingState: root.pinSettingState
            authorizationState: root.authorizationState
            onKeycardPinCreated: (pin) => {
                root.keycardPinCreated(pin)
            }
            onKeycardPinSuccessfullySet: {
                if (d.withNewSeedphrase) {
                    // Need to authorize before getting a seedphrase
                    root.authorizationRequested()
                } else {
                    root.stackView.push(seedphrasePage)
                }
            }
            onKeycardAuthorized: {
                if (d.withNewSeedphrase) {
                    root.stackView.push(backupSeedIntroPage)
                }
            }
        }
    }

    Component {
        id: addKeypairPage

        KeycardAddKeyPairPage {
            readonly property bool backAvailableHint: false

            addKeyPairState: root.addKeyPairState

            onKeypairAddContinueRequested: root.finished(d.withNewSeedphrase)

            onKeypairAddTryAgainRequested: {
                root.stackView.replace(addKeypairPage)
                root.keypairAddTryAgainRequested()
            }

            onReloadKeycardRequested: {
                root.reloadKeycardRequested()

                const page = root.stackView.find(
                               item => item instanceof CreateKeycardProfilePage)

                root.stackView.replace(page, d.initialComponent(),
                                       StackView.PopTransition)
            }

            onCreateProfilePageRequested: root.createProfileWithoutKeycardRequested()
        }
    }
}
