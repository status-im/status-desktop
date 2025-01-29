import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import Models 1.0
import Storybook 1.0

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2.pages 1.0

import utils 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: driver

        // keycard
        property int keycardState: Onboarding.KeycardState.NoPCSCService
        property int keycardRemainingPinAttempts: 3
        property int keycardRemainingPukAttempts: 3

        function setPin(pin: string) { // -> bool
            logs.logEvent("setPin", ["pin"], arguments)
            const valid = pin === ctrlPin.text
            if (!valid)
                keycardRemainingPinAttempts-- // SIMULATION: decrease the remaining PIN attempts
            if (keycardRemainingPinAttempts <= 0) { // SIMULATION: "block" the keycard
                keycardState = Onboarding.KeycardState.BlockedPIN
                keycardRemainingPinAttempts = 0
            }
            return valid
        }

        function setPuk(puk) { // -> bool
            logs.logEvent("setPuk", ["puk"], arguments)
            const valid = puk === ctrlPuk.text
            if (!valid)
                keycardRemainingPukAttempts--
            if (keycardRemainingPukAttempts <= 0) { // SIMULATION: "block" the keycard
                keycardState = Onboarding.KeycardState.BlockedPUK
                keycardRemainingPukAttempts = 0
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

        keycardState: driver.keycardState

        tryToSetPinFunction: (pin) => driver.setPin(pin)
        keycardRemainingPinAttempts: driver.keycardRemainingPinAttempts
        keycardRemainingPukAttempts: driver.keycardRemainingPukAttempts

        biometricsAvailable: ctrlBiometrics.checked
        isBiometricsLogin: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store
        onBiometricsRequested: biometricsPopup.open()
        onLoginRequested: (keyUid, method, data) => {
                              logs.logEvent("onLoginRequested", ["keyUid", "method", "data"], arguments)

                              // SIMULATION: emit an error in case of wrong password
                              if (method === Onboarding.LoginMethod.Password && data.password !== ctrlPassword.text) {
                                  driver.accountLoginError("The impossible has happened", Math.random() < 0.5)
                              }
                          }
        onOnboardingCreateProfileFlowRequested: logs.logEvent("onOnboardingCreateProfileFlowRequested")
        onOnboardingLoginFlowRequested: logs.logEvent("onOnboardingLoginFlowRequested")
        onUnblockWithSeedphraseRequested: logs.logEvent("onUnblockWithSeedphraseRequested")
        onUnblockWithPukRequested: logs.logEvent("onUnblockWithPukRequested")
        onLostKeycard: logs.logEvent("onLostKeycard")
        onKeycardFactoryResetRequested: logs.logEvent("onKeycardFactoryResetRequested")

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
        selectedProfileIsKeycard: loginScreen.selectedProfileIsKeycard
        onAccountLoginError: (error, wrongPassword) => driver.accountLoginError(error, wrongPassword)
        onObtainingPasswordSuccess: (password) => driver.obtainingPasswordSuccess(password)
        onObtainingPasswordError: (errorDescription, errorType, wrongFingerprint) => driver.obtainingPasswordError(errorDescription, errorType, wrongFingerprint)
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
                    text: "PUK:"
                }
                TextField {
                    id: ctrlPuk
                    text: "111111111111"
                    inputMask: "999999999999"
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
                    onActivated: driver.keycardState = currentValue
                    Component.onCompleted: currentIndex = Qt.binding(() => indexOfValue(driver.keycardState))
                }
            }
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=801-42615&m=dev
