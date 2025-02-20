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
        property int keycardRemainingPinAttempts: Constants.onboarding.defaultPinAttempts
        property int keycardRemainingPukAttempts: Constants.onboarding.defaultPukAttempts
    }

    LoginScreen {
        id: loginScreen
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        loginAccountsModel: LoginAccountsModel {}

        keycardState: driver.keycardState

        keycardRemainingPinAttempts: driver.keycardRemainingPinAttempts
        keycardRemainingPukAttempts: driver.keycardRemainingPukAttempts

        isBiometricsLogin: ctrlTouchIdUser.checked

        onBiometricsRequested: biometricsPopup.open()
        onDismissBiometricsRequested: biometricsPopup.close()

        onLoginRequested: (keyUid, method, data) => {
                              logs.logEvent("onLoginRequested", ["keyUid", "method", "data"], arguments)

                              // SIMULATION: emit an error in case of wrong password/PIN
                              if (method === Onboarding.LoginMethod.Password && data.password !== ctrlPassword.text) {
                                  setAccountLoginError("", true)
                              } else if (method === Onboarding.LoginMethod.Keycard && data.pin !== ctrlPin.text) {
                                  driver.keycardRemainingPinAttempts-- // SIMULATION: decrease the remaining PIN attempts
                                  if (driver.keycardRemainingPinAttempts <= 0) { // SIMULATION: "block" the keycard
                                      driver.keycardState = Onboarding.KeycardState.BlockedPIN
                                      driver.keycardRemainingPinAttempts = 0
                                  }
                                  setAccountLoginError("", true)
                              }
                          }

        onSelectedProfileKeyIdChanged: driver.keycardState = Onboarding.KeycardState.NoPCSCService

        onOnboardingCreateProfileFlowRequested: logs.logEvent("onOnboardingCreateProfileFlowRequested")
        onOnboardingLoginFlowRequested: logs.logEvent("onOnboardingLoginFlowRequested")
        onUnblockWithSeedphraseRequested: logs.logEvent("onUnblockWithSeedphraseRequested")
        onUnblockWithPukRequested: logs.logEvent("onUnblockWithPukRequested")
        onLostKeycardFlowRequested: () => {
                           logs.logEvent("onLostKeycardFlowRequested")
                       }
    }

    BiometricsPopup {
        id: biometricsPopup

        x: root.Window.width - width

        onObtainingPasswordSuccess: {
            loginScreen.setBiometricResponse(loginScreen.selectedProfileIsKeycard
                                             ? ctrlPin.text : ctrlPassword.text)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 230
        SplitView.preferredHeight: 230

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Label {
                    text: "Selected profile ID: %1".arg(loginScreen.selectedProfileKeyId || "N/A")
                }
                ToolSeparator {}
                Button {
                    focusPolicy: Qt.NoFocus
                    text: loginScreen.selectedProfileIsKeycard ? "Simulate wrong PIN" : "Simulate wrong password"
                    onClicked: {
                        if (loginScreen.selectedProfileIsKeycard) {
                            driver.keycardRemainingPinAttempts-- // SIMULATION: decrease the remaining PIN attempts
                            if (driver.keycardRemainingPinAttempts <= 0) { // SIMULATION: "block" the keycard
                                driver.keycardState = Onboarding.KeycardState.BlockedPIN
                                driver.keycardRemainingPinAttempts = 0
                            }
                        }

                        loginScreen.setAccountLoginError("", true)
                    }
                    enabled: loginScreen.selectedProfileIsKeycard ? driver.keycardState === Onboarding.KeycardState.NotEmpty : true
                }
                Button {
                    focusPolicy: Qt.NoFocus
                    text: "Simulate other login error"
                    onClicked: loginScreen.setAccountLoginError("The impossible error has just happened", false)
                    enabled: loginScreen.selectedProfileIsKeycard ? driver.keycardState === Onboarding.KeycardState.NotEmpty : true
                }
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
                    id: ctrlTouchIdUser
                    text: "Touch ID login"
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
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Keycard state:"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 2

                    ButtonGroup {
                        id: keycardStateButtonGroup
                    }

                    Repeater {
                        model: Onboarding.getModelFromEnum("KeycardState")

                        RoundButton {
                            focusPolicy: Qt.NoFocus
                            text: modelData.name
                            checkable: true
                            checked: driver.keycardState === modelData.value

                            ButtonGroup.group: keycardStateButtonGroup

                            onClicked: {
                                driver.keycardState = modelData.value
                            }
                        }
                    }
                }
            }
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=801-42615&m=dev
