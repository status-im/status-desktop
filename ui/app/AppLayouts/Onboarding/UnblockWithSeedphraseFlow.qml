import QtQuick
import QtQuick.Controls

import AppLayouts.Onboarding.pages
import AppLayouts.Onboarding.enums

OnboardingStackView {
    id: root

    required property var isSeedPhraseValid
    required property int pinSettingState
    required property int keycardPinInfoPageDelay

    signal seedphraseSubmitted(string seedphrase)
    signal setPinRequested(string pin)
    signal finished

    initialItem: SeedphrasePage {
        title: qsTr("Unblock Keycard using the recovery phrase")
        btnContinueText: qsTr("Unblock Keycard")

        onSeedphraseProvided: seedphrase => {
            const valid = root.isSeedPhraseValid(seedphrase.join(" "))
            setSeedPhraseError(valid ? "" : qsTr("Invalid recovery phrase"))
        }

        onSeedphraseSubmitted: (seedphrase) => {
            root.seedphraseSubmitted(seedphrase)
            root.push(keycardCreatePinPage)
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinDelayedPage {
            pinSettingState: root.pinSettingState
            authorizationState: Onboarding.AuthorizationState.Authorized // authorization not needed
            keycardPinInfoPageDelay: root.keycardPinInfoPageDelay

            onSetPinRequested: (pin) => root.setPinRequested(pin)
            onFinished: root.finished()
        }
    }
}
