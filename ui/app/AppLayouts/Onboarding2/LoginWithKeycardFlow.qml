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
    required property var tryToSetPinFunction
    required property int remainingPinAttempts
    required property int remainingPukAttempts
    required property var isSeedPhraseValid

    required property int keycardPinInfoPageDelay

    property bool displayKeycardPromoBanner

    signal keycardPinEntered(string pin)
    signal keycardPinCreated(string pin)
    signal seedphraseSubmitted(string seedphrase)
    signal reloadKeycardRequested
    signal keycardFactoryResetRequested
    signal unblockWithPukRequested
    signal createProfileWithEmptyKeycardRequested
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
            onUnblockWithSeedphraseRequested: root.stackView.push(seedphrasePage)
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
            tryToSetPinFunction: root.tryToSetPinFunction
            remainingAttempts: root.remainingPinAttempts
            unblockWithPukAvailable: root.remainingPukAttempts > 0

            onKeycardPinEntered: (pin) => {
                Backpressure.debounce(root, root.keycardPinInfoPageDelay, () => {
                    root.keycardPinEntered(pin)
                    root.finished()
                })()
            }

            onReloadKeycardRequested: d.reload()
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onUnblockWithSeedphraseRequested: root.stackView.push(seedphrasePage)
        }
    }

    Component {
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Unblock Keycard using the recovery phrase")
            btnContinueText: qsTr("Unblock Keycard")
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
            onKeycardPinCreated: (pin) => {
                Backpressure.debounce(root, root.keycardPinInfoPageDelay, () => {
                    root.keycardPinCreated(pin)
                    root.finished()
                })()
            }
        }
    }
}
