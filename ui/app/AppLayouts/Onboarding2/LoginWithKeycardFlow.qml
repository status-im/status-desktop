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
    required property int authorizationState
    required property int restoreKeysExportState
    required property int remainingPinAttempts
    required property int remainingPukAttempts

    required property int keycardPinInfoPageDelay

    property bool displayKeycardPromoBanner

    signal keycardPinCreated(string pin)
    signal seedphraseSubmitted(string seedphrase)
    signal authorizationRequested(string pin)
    signal keycardFactoryResetRequested
    signal unblockWithSeedphraseRequested
    signal unblockWithPukRequested
    signal createProfileWithEmptyKeycardRequested
    signal exportKeysRequested
    signal finished

    function init() {
        root.stackView.push(d.initialComponent())
    }

    QtObject {
        id: d

        function initialComponent() {
            if (root.keycardState === Onboarding.KeycardState.Empty)
                return keycardEmptyPage

            if (root.keycardState === Onboarding.KeycardState.NotEmpty)
                return keycardEnterPinPage

            return keycardIntroPage
        }
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            displayPromoBanner: root.displayKeycardPromoBanner
            unblockUsingSeedphraseAvailable: true
            unblockWithPukAvailable: root.remainingPukAttempts > 0 && (root.remainingPinAttempts === 1 || root.remainingPinAttempts === 2)

            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onUnblockWithSeedphraseRequested: root.unblockWithSeedphraseRequested()
            onUnblockWithPukRequested: root.unblockWithPukRequested()
            onEmptyKeycardDetected: root.stackView.replace(keycardEmptyPage)
            onNotEmptyKeycardDetected: root.stackView.replace(keycardEnterPinPage)
        }
    }

    Component {
        id: keycardEmptyPage

        KeycardEmptyPage {
            onCreateProfileWithEmptyKeycardRequested: root.createProfileWithEmptyKeycardRequested()
        }
    }

    Component {
        id: keycardEnterPinPage

        KeycardEnterPinPage {
            id: page

            authorizationState: root.authorizationState
            remainingAttempts: root.remainingPinAttempts
            unblockWithPukAvailable: root.remainingPukAttempts > 0

            onAuthorizationRequested: root.authorizationRequested(pin)
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onUnblockWithSeedphraseRequested: root.unblockWithSeedphraseRequested()

            Connections {
                target: root
                enabled: page.visible

                function onAuthorizationStateChanged() {
                    if (root.authorizationState !== Onboarding.ProgressState.Success)
                        return

                    const doNext = () => {
                        root.exportKeysRequested()
                        root.stackView.replace(keycardExtractingKeysPage)
                    }

                    Backpressure.debounce(page, root.keycardPinInfoPageDelay,
                                          doNext)()
                }
            }
        }
    }

    Component {
        id: keycardExtractingKeysPage

        KeycardExtractingKeysPage {
            id: page

            Connections {
                target: root
                enabled: page.visible

                function onRestoreKeysExportStateChanged() {
                    if (root.restoreKeysExportState !== Onboarding.ProgressState.Success)
                        return

                    Backpressure.debounce(page, root.keycardPinInfoPageDelay,
                                          root.finished)()
                }
            }
        }
    }

    Component {
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Unblock Keycard using the recovery phrase")
            btnContinueText: qsTr("Unblock Keycard")
            authorizationState: root.authorizationState
            isSeedPhraseValid: root.isSeedPhraseValid
            onSeedphraseSubmitted: (seedphrase) => {
                root.seedphraseSubmitted(seedphrase)
                root.stackView.push(keycardCreatePinPage)
            }
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinPage {
            id: createPinPage

            onKeycardPinCreated: (pin) => {
                createPinPage.loading = true
                Backpressure.debounce(root, root.keycardPinInfoPageDelay, () => {
                    root.keycardPinCreated(pin)
                    root.finished()
                })()
            }
        }
    }
}
