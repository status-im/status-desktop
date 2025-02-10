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
    required property int authorizationState
    required property int pinSettingState
    required property int keycardPinInfoPageDelay

    required property var isSeedPhraseValid

    property bool displayKeycardPromoBanner

    signal loginWithKeycardRequested
    signal keycardFactoryResetRequested
    signal keycardPinCreated(string pin)
    signal authorizationRequested()
    signal seedphraseSubmitted(string seedphrase)

    signal loadMnemonicRequested
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

            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onEmptyKeycardDetected: root.stackView.replace(seedphrasePage)
            onNotEmptyKeycardDetected: root.stackView.replace(keycardNotEmptyPage)
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
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Enter recovery phrase of lost Keycard")

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
            pinSettingState: root.pinSettingState
            authorizationState: root.authorizationState
            onKeycardPinCreated: (pin) => {
                root.keycardPinCreated(pin)
            }
            onKeycardPinSuccessfullySet: {
                root.authorizationRequested()
            }
            onKeycardAuthorized: {
                root.loadMnemonicRequested()
                root.stackView.push(addKeypairPage)
            }
        }
    }

    Component {
        id: addKeypairPage

        KeycardAddKeyPairDelayedPage {
            readonly property bool backAvailableHint: false

            addKeyPairState: root.addKeyPairState

            onFinished: root.finished()
        }
    }
}
