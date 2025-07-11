import QtQuick
import QtQuick.Controls

import AppLayouts.Onboarding2.pages
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
        isSeedPhraseValid: root.isSeedPhraseValid

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

            onSetPinRequested: root.setPinRequested(pin)
            onFinished: root.finished()
        }
    }
}
