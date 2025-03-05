import QtQuick 2.15

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

OnboardingStackView {
    id: root

    required property int keycardState
    required property int addKeyPairState
    required property int authorizationState
    required property int pinSettingState
    required property int keycardPinInfoPageDelay

    required property var isSeedPhraseValid

    property bool displayKeycardPromoBanner

    signal loginWithKeycardRequested
    signal keycardFactoryResetRequested
    signal setPinRequested(string pin)
    signal authorizationRequested()
    signal seedphraseSubmitted(string seedphrase)

    signal loadMnemonicRequested
    signal createProfileWithoutKeycardRequested

    signal finished

    initialItem: {
        if (root.keycardState === Onboarding.KeycardState.Empty)
            return seedphrasePage

        if (root.keycardState === Onboarding.KeycardState.NotEmpty)
            return keycardNotEmptyPage

        return keycardIntroPage
    }

    Component {
        id: keycardIntroPage

        KeycardIntroPage {
            keycardState: root.keycardState
            displayPromoBanner: root.displayKeycardPromoBanner

            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onEmptyKeycardDetected: root.replace(seedphrasePage)
            onNotEmptyKeycardDetected: root.replace(keycardNotEmptyPage)
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

            isSeedPhraseValid: root.isSeedPhraseValid
            onSeedphraseSubmitted: (seedphrase) => {
                root.seedphraseSubmitted(seedphrase)
                root.push(keycardCreatePinPage)
            }
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinDelayedPage {
            readonly property bool backAvailableHint: !success && !pinSettingInProgress

            authorizationState: root.authorizationState
            pinSettingState: root.pinSettingState

            onSetPinRequested: (pin) => root.setPinRequested(pin)
            onAuthorizationRequested: root.authorizationRequested()

            onFinished: {
                root.loadMnemonicRequested()
                root.push(addKeypairPage)
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
