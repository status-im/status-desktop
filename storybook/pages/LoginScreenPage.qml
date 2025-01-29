import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding2.stores 1.0

import utils 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    OnboardingStore {
        id: store

        // keycard
        property int keycardState: Onboarding.KeycardState.NoPCSCService
        property int keycardRemainingPinAttempts: ctrlUnlockWithPuk.checked ? 1 : 5

        function setPin(pin: string) { // -> bool
            logs.logEvent("OnboardingStore.setPin", ["pin"], arguments)
            const valid = pin === ctrlPin.text
            if (!valid)
                keycardRemainingPinAttempts-- // SIMULATION: decrease the remaining PIN attempts
            if (keycardRemainingPinAttempts <= 0) { // SIMULATION: "lock" the keycard
                keycardState = Onboarding.KeycardState.Locked
                keycardRemainingPinAttempts = ctrlUnlockWithPuk.checked ? 1 : 5
            }
            return valid
        }

        // password signals
        signal accountLoginError(string error, bool wrongPassword)

        // biometrics signals
        signal obtainingPasswordSuccess(string password)
        signal obtainingPasswordError(string errorDescription, string errorType /* Constants.keychain.errorType.* */, bool wrongFingerprint)
    }

    LoginScreen {
        id: loginScreen
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        loginAccountsModel: LoginAccountsModel {}
        onboardingStore: store
        biometricsAvailable: ctrlBiometrics.checked
        isBiometricsLogin: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store
        onBiometricsRequested: biometricsPopup.open()
        onLoginRequested: (keyUid, method, data) => {
                              logs.logEvent("onLoginRequested", ["keyUid", "method", "data"], arguments)

                              // SIMULATION: emit an error in case of wrong password
                              if (method === Onboarding.LoginMethod.Password && data.password !== ctrlPassword.text) {
                                  onboardingStore.accountLoginError("The impossible has happened", Math.random() < 0.5)
                              }
                          }
        onOnboardingCreateProfileFlowRequested: logs.logEvent("onOnboardingCreateProfileFlowRequested")
        onOnboardingLoginFlowRequested: logs.logEvent("onOnboardingLoginFlowRequested")
        onUnlockWithSeedphraseRequested: logs.logEvent("onUnlockWithSeedphraseRequested")
        onUnlockWithPukRequested: logs.logEvent("onUnlockWithPukRequested")
        onLostKeycard: logs.logEvent("onLostKeycard")

        // mocks
        QtObject {
            id: localAccountSettings
            readonly property string storeToKeychainValue: ctrlTouchIdUser.checked ? Constants.keychain.storedValue.store : ""
        }
        onSelectedProfileKeyIdChanged: biometricsPopup.visible = Qt.binding(() => ctrlBiometrics.checked && ctrlTouchIdUser.checked)
    }

    BiometricsPopup {
        id: biometricsPopup
        visible: ctrlBiometrics.checked && ctrlTouchIdUser.checked
        x: root.Window.width - width
        password: ctrlPassword.text
        pin: ctrlPin.text
        onAccountLoginError: (error, wrongPassword) => store.accountLoginError(error, wrongPassword)
        onObtainingPasswordSuccess: (password) => store.obtainingPasswordSuccess(password)
        onObtainingPasswordError: (errorDescription, errorType, wrongFingerprint) => store.obtainingPasswordError(errorDescription, errorType, wrongFingerprint)
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 180
        SplitView.preferredHeight: 180

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            Label {
                text: "Selected user ID: %1".arg(loginScreen.selectedProfileKeyId || "N/A")
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Password:\t"
                }
                TextField {
                    id: ctrlPassword
                    text: "0123456789"
                    placeholderText: "Example password"
                    selectByMouse: true
                }
                Switch {
                    id: ctrlBiometrics
                    text: "Biometrics available"
                    checked: true
                }
                Switch {
                    id: ctrlTouchIdUser
                    text: "Touch ID login"
                    enabled: ctrlBiometrics.checked
                    checked: ctrlBiometrics.checked
                }
                Switch {
                    id: ctrlUnlockWithPuk
                    text: "Unlock with PUK available"
                    checked: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Keycard PIN:\t"
                }
                TextField {
                    id: ctrlPin
                    text: "111111"
                    inputMask: "999999"
                    selectByMouse: true
                }
                Label {
                    text: "State:"
                }
                ComboBox {
                    Layout.preferredWidth: 300
                    id: ctrlKeycardState
                    focusPolicy: Qt.NoFocus
                    textRole: "name"
                    valueRole: "value"
                    model: Onboarding.getModelFromEnum("KeycardState")
                    onActivated: store.keycardState = currentValue
                    Component.onCompleted: currentIndex = Qt.binding(() => indexOfValue(store.keycardState))
                }
            }
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=801-42615&m=dev
