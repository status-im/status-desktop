import QtQuick
import QtQuick.Controls

import StatusQ.Core.Backpressure

import AppLayouts.Onboarding2.pages
import AppLayouts.Onboarding.enums

OnboardingStackView {
    id: root

    required property int keycardState
    required property int authorizationState
    required property int restoreKeysExportState
    required property int remainingPinAttempts
    required property int remainingPukAttempts

    required property int keycardPinInfoPageDelay

    property bool displayKeycardPromoBanner

    signal authorizationRequested(string pin)
    signal keycardFactoryResetRequested
    signal unblockWithSeedphraseRequested
    signal unblockWithPukRequested
    signal createProfileWithEmptyKeycardRequested
    signal exportKeysRequested
    signal finished

    initialItem: {
        if (root.keycardState === Onboarding.KeycardState.Empty)
            return keycardEmptyPage

        if (root.keycardState === Onboarding.KeycardState.NotEmpty)
            return keycardEnterPinPage

        return keycardIntroPage
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
            onEmptyKeycardDetected: root.replace(keycardEmptyPage)
            onNotEmptyKeycardDetected: root.replace(keycardEnterPinPage)
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

            state: {
                switch (root.authorizationState) {
                case Onboarding.AuthorizationState.Authorized:
                    return KeycardEnterPinPage.State.Success
                case Onboarding.AuthorizationState.InProgress:
                    return KeycardEnterPinPage.State.InProgress
                case Onboarding.AuthorizationState.WrongPin:
                    return KeycardEnterPinPage.State.WrongPin
                }

                return KeycardEnterPinPage.State.Idle
            }

            remainingAttempts: root.remainingPinAttempts
            unblockWithPukAvailable: root.remainingPukAttempts > 0

            onAuthorizationRequested: root.authorizationRequested(pin)
            onKeycardFactoryResetRequested: root.keycardFactoryResetRequested()
            onUnblockWithSeedphraseRequested: root.unblockWithSeedphraseRequested()

            Connections {
                target: root
                enabled: page.visible

                function onAuthorizationStateChanged() {
                    if (root.authorizationState !== Onboarding.AuthorizationState.Authorized)
                        return

                    const doNext = () => {
                        root.exportKeysRequested()
                        root.replace(keycardExtractingKeysPage)
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
}
