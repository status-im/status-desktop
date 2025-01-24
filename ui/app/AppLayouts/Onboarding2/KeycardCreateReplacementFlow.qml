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
    required property int addKeyPairState
    required property int keycardPinInfoPageDelay

    required property var isSeedPhraseValid

    property bool displayKeycardPromoBanner

    signal loginWithKeycardRequested
    signal keycardFactoryResetRequested
    signal keyPairTransferRequested
    signal keycardPinCreated(string pin)
    signal seedphraseSubmitted(string seedphrase)

    signal keypairAddTryAgainRequested
    signal reloadKeycardRequested
    signal createProfileWithoutKeycardRequested

    signal finished

    function init() {
        root.stackView.push(d.initialComponent())
    }

    QtObject {
        id: d

        function initialComponent() {
            if (root.keycardState === Onboarding.KeycardState.Empty)
                return seedphrasePage

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

            onReloadKeycardRequested: {
                root.reloadKeycardRequested()
                root.stackView.replace(d.initialComponent(),
                                       StackView.PopTransition)
            }

            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onEmptyKeycardDetected: root.stackView.replace(seedphrasePage)
            onNotEmptyKeycardDetected: root.stackView.replace(keycardNotEmptyPage)
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
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Enter recovery phrase of lost Keycard")

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
                    root.keyPairTransferRequested()
                    root.stackView.push(addKeypairPage)
                })()
            }
        }
    }

    Component {
        id: addKeypairPage

        KeycardAddKeyPairPage {
            readonly property bool backAvailableHint: false

            addKeyPairState: root.addKeyPairState

            onKeypairAddContinueRequested: root.finished()

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
