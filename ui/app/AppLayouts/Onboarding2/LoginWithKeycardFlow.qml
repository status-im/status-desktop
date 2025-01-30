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
    signal reloadKeycardRequested
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

        function reload() {
            root.reloadKeycardRequested()
            root.stackView.replace(d.initialComponent(),
                                   StackView.PopTransition)
        }
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            displayPromoBanner: root.displayKeycardPromoBanner
            unblockUsingSeedphraseAvailable: true
            unblockWithPukAvailable: root.remainingPukAttempts > 0 && (root.remainingPinAttempts === 1 || root.remainingPinAttempts === 2)

            onReloadKeycardRequested: d.reload()
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
            onCreateProfileWithEmptyKeycardRequested:
                root.createProfileWithEmptyKeycardRequested()

            onReloadKeycardRequested: d.reload()
        }
    }

    Component {
        id: keycardEnterPinPage

        KeycardEnterPinPage {
            authorizationState: root.authorizationState
            restoreKeysExportState: root.restoreKeysExportState
            onAuthorizationRequested: root.authorizationRequested(pin)
            remainingAttempts: root.remainingPinAttempts
            unblockWithPukAvailable: root.remainingPukAttempts > 0
            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay
            pinCorrectText: qsTr("PIN correct. Exporting keys.")

            onExportKeysRequested: root.exportKeysRequested()
            onExportKeysDone: root.finished()

            onReloadKeycardRequested: d.reload()
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onUnblockWithSeedphraseRequested: root.unblockWithSeedphraseRequested()
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
